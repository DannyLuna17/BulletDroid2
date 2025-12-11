import 'dart:convert';
import '../core/app_configuration.dart';
import '../core/config.dart';
import '../core/config_settings.dart';
import '../blocks/base/block_factory.dart';
import '../blocks/base/block_instance.dart';

class LoliParser {
  static Config parseConfig(String loliCode) {
    // Parse either a full .loli config with [SETTINGS]/[SCRIPT] sections
    // or a plain LoliScript file
    if (loliCode.contains('[SETTINGS]') && loliCode.contains('[SCRIPT]')) {
      return _parseFullLoliConfig(loliCode);
    } else {
      // Parse as pure LoliScript
      return _parseLoliScript(loliCode);
    }
  }

  /// Parse a full .loli config with [SETTINGS] and [SCRIPT] sections
  static Config _parseFullLoliConfig(String loliCode) {
    // Find the positions of [SETTINGS] and [SCRIPT]
    final settingsStart = loliCode.indexOf('[SETTINGS]');
    final scriptStart = loliCode.indexOf('[SCRIPT]');

    if (settingsStart == -1 || scriptStart == -1) {
      throw FormatException(
          'Invalid .loli config format: missing [SETTINGS] or [SCRIPT] sections');
    }

    // Extract settings JSON
    final settingsJson = loliCode
        .substring(settingsStart + '[SETTINGS]'.length, scriptStart)
        .trim();

    // Extract script content
    final scriptContent =
        loliCode.substring(scriptStart + '[SCRIPT]'.length).trim();

    if (settingsJson.isEmpty || scriptContent.isEmpty) {
      throw FormatException(
          'Invalid .loli config: empty SETTINGS or SCRIPT content');
    }

    ConfigSettings settings;
    ConfigMetadata metadata;

    try {
      final sanitizedJson = _sanitizeJsonString(settingsJson);

      final settingsMap = jsonDecode(sanitizedJson) as Map<String, dynamic>;
      settings = ConfigSettings.fromLegacyJson(settingsMap);

      // Create metadata from settings
      metadata = ConfigMetadata(
        name: settings.name.isNotEmpty ? settings.name : 'Parsed Config',
        author: settings.author.isNotEmpty ? settings.author : 'Unknown',
        category: 'Legacy',
        description: settings.additionalInfo,
        version: settings.version.isNotEmpty ? settings.version : '1.0.0',
      );
    } catch (e) {
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Warning: Failed to parse settings JSON: $e');
      }
      settings = ConfigSettings();
      metadata = ConfigMetadata(
        name: 'Parsed Config',
        author: 'Unknown',
        category: 'Legacy',
        description: 'Config with invalid settings',
      );
    }

    // Parse script content into blocks
    final blocks = _parseLoliScriptBlocks(scriptContent);

    return Config(
      metadata: metadata,
      blocks: blocks,
      settings: settings,
    );
  }

  /// Parse pure LoliScript without settings
  static Config _parseLoliScript(String loliCode) {
    final blocks = _parseLoliScriptBlocks(loliCode);

    // Create default metadata
    final metadata = ConfigMetadata(
      name: 'Parsed Config',
      author: 'LunaLib',
      category: 'Parsed',
      description: 'Config parsed from LoliCode',
    );

    return Config(
      metadata: metadata,
      blocks: blocks,
      settings: ConfigSettings(),
    );
  }

  /// Parse LoliScript blocks from script content
  static List<BlockInstance> _parseLoliScriptBlocks(String scriptContent) {
    final lines = scriptContent.split('\n');
    final blocks = <BlockInstance>[];

    var i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();

      if (line.isEmpty || line.startsWith('##')) {
        i++;
        continue;
      }

      if (line.startsWith('BLOCK:')) {
        // Extract just the block type (first word after BLOCK:)
        final fullBlockType = line.substring(6).trim();
        final blockType = fullBlockType.split(RegExp(r'\s+')).first;
        final blockContent = StringBuffer();

        final sameLineContent =
            fullBlockType.substring(blockType.length).trim();
        if (sameLineContent.isNotEmpty) {
          blockContent.writeln(sameLineContent);
        }

        // Move to next line
        i++;

        // Collect block content until ENDBLOCK (without preprocessing)
        while (i < lines.length) {
          final blockLine = lines[i];
          if (blockLine.trim() == 'ENDBLOCK') {
            break;
          }
          blockContent.writeln(blockLine);
          i++;
        }

        // Create and parse the block
        try {
          final block = BlockFactory.createBlock(blockType);
          block.fromLoliCode(blockContent.toString());
          blocks.add(block);
        } catch (e) {
          // Skip unsupported blocks
          if (AppConfiguration.debugMode) {
            // ignore: avoid_print
            print(
                'Skipping unsupported block type: ${blockType.split(' ').first}');
          }
        }
      } else {
        final blockInfo = _identifyBlockType(line);

        if (blockInfo != null) {
          final tempBuffer = <String>[];

          tempBuffer.add(lines[i]);
          i++;

          while (i < lines.length) {
            final nextLine = lines[i];
            final trimmedNext = nextLine.trim();

            // Check if this line belongs to the current block
            bool belongsToBlock = false;

            if (blockInfo == 'Request') {
              // These keywords belong to REQUEST blocks
              belongsToBlock = trimmedNext.startsWith('HEADER ') ||
                  trimmedNext.startsWith('CONTENT ') ||
                  trimmedNext.startsWith('CONTENTTYPE ') ||
                  trimmedNext.startsWith('COOKIE ') ||
                  trimmedNext.startsWith('USERNAME ') ||
                  trimmedNext.startsWith('PASSWORD ') ||
                  trimmedNext.startsWith('BOUNDARY ') ||
                  trimmedNext.startsWith('STRINGCONTENT ') ||
                  trimmedNext.startsWith('FILECONTENT ') ||
                  trimmedNext.startsWith('RAWDATA ') ||
                  trimmedNext.startsWith('SECPROTO ') ||
                  trimmedNext.startsWith('->') ||
                  trimmedNext == 'STANDARD' ||
                  trimmedNext == 'MULTIPART' ||
                  trimmedNext == 'BASICAUTH' ||
                  trimmedNext == 'RAW';

              if (!belongsToBlock &&
                  trimmedNext.isEmpty &&
                  (i + 1) < lines.length) {
                var j = i + 1;
                while (j < lines.length && lines[j].trim().isEmpty) {
                  j++;
                }
                if (j < lines.length) {
                  final lookAhead = lines[j].trim();
                  belongsToBlock = lookAhead.startsWith('HEADER ') ||
                      lookAhead.startsWith('CONTENT ') ||
                      lookAhead.startsWith('CONTENTTYPE ') ||
                      lookAhead.startsWith('COOKIE ') ||
                      lookAhead.startsWith('USERNAME ') ||
                      lookAhead.startsWith('PASSWORD ') ||
                      lookAhead.startsWith('BOUNDARY ') ||
                      lookAhead.startsWith('STRINGCONTENT ') ||
                      lookAhead.startsWith('FILECONTENT ') ||
                      lookAhead.startsWith('RAWDATA ') ||
                      lookAhead.startsWith('SECPROTO ') ||
                      lookAhead.startsWith('->') ||
                      lookAhead == 'STANDARD' ||
                      lookAhead == 'MULTIPART' ||
                      lookAhead == 'BASICAUTH' ||
                      lookAhead == 'RAW';
                }
              }
            } else if (blockInfo == 'Keycheck') {
              // These keywords belong to KEYCHECK blocks
              belongsToBlock = trimmedNext.startsWith('KEYCHAIN ') ||
                  trimmedNext.startsWith('KEY ') ||
                  trimmedNext.startsWith('STRINGKEY ') ||
                  trimmedNext.startsWith('INTKEY ') ||
                  trimmedNext.startsWith('BOOLKEY ') ||
                  (nextLine.startsWith(' ') || nextLine.startsWith('\t'));
            }

            // If line doesn't belong to block or is a new block, stop collecting
            if (!belongsToBlock &&
                (_identifyBlockType(trimmedNext) != null ||
                    trimmedNext.startsWith('BLOCK:'))) {
              break;
            }

            // Add the line even if it's empty (for REQUEST blocks with blank lines)
            if (belongsToBlock ||
                (blockInfo == 'Request' && trimmedNext.isEmpty)) {
              tempBuffer.add(nextLine);
              i++;
            } else {
              break;
            }
          }

          // Preprocess the collected lines to handle indentation
          String contentToUse;
          if (blockInfo == 'Keycheck' || blockInfo == 'Request') {
            // Don't preprocess Keycheck or Request blocks because they need their structure preserved
            contentToUse = tempBuffer.join('\n');
          } else {
            contentToUse = _preprocessLines(tempBuffer.join('\n'));
          }

          // Create and parse the block
          try {
            final block = BlockFactory.createBlock(blockInfo);
            block.fromLoliCode(contentToUse);
            blocks.add(block);
          } catch (e) {
            // Fall back to LoliCode block
            final loliCodeBlock = BlockFactory.createBlock('LoliCode');
            loliCodeBlock.fromLoliCode(contentToUse);
            blocks.add(loliCodeBlock);
          }
          continue;
        } else {
          // Handle standalone LoliCode statements
          final loliCodeBlock = BlockFactory.createBlock('LoliCode');
          final statementBuffer = StringBuffer();

          // Collect statements until next block or end
          final tempBuffer = <String>[];
          while (i < lines.length) {
            final currentLine = lines[i].trim();

            if (currentLine.startsWith('HEADER ') ||
                currentLine.startsWith('CONTENT ') ||
                currentLine.startsWith('CONTENTTYPE ') ||
                currentLine.startsWith('COOKIE ')) {
              if (AppConfiguration.debugMode) {
                // ignore: avoid_print
                print(
                    'Warning: Found REQUEST-related keyword outside of REQUEST block: $currentLine');
              }
              i++;
              continue;
            }

            if (currentLine.startsWith('BLOCK:') ||
                _identifyBlockType(currentLine) != null ||
                currentLine.isEmpty) {
              break;
            }
            tempBuffer.add(lines[i]);
            i++;
          }

          // Preprocess only standalone LoliCode statements
          if (tempBuffer.isNotEmpty) {
            final preprocessedStatements =
                _preprocessLines(tempBuffer.join('\n'));
            statementBuffer.write(preprocessedStatements);
            loliCodeBlock.fromLoliCode(statementBuffer.toString());
            blocks.add(loliCodeBlock);
          }
          continue;
        }
      }

      i++;
    }
    return blocks;
  }

  /// Preprocess lines to handle indentation-based continuation
  static String _preprocessLines(String scriptContent) {
    final lines = scriptContent.split('\n');
    final processedLines = <String>[];
    var currentLine = '';

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip empty lines and comments without affecting current line building
      if (line.trim().isEmpty || line.trim().startsWith('##')) {
        if (currentLine.isNotEmpty) {
          processedLines.add(currentLine);
          currentLine = '';
        }
        processedLines.add(line);
        continue;
      }

      // Check if line starts with space or tab (continuation)
      if (line.startsWith(' ') || line.startsWith('\t')) {
        if (currentLine.isNotEmpty) {
          currentLine += ' ' + line.trim();
        } else {
          currentLine = line.trim();
        }
      } else {
        if (currentLine.isNotEmpty) {
          processedLines.add(currentLine);
        }
        currentLine = line;
      }
    }

    if (currentLine.isNotEmpty) {
      processedLines.add(currentLine);
    }

    return processedLines.join('\n');
  }

  static String configToLoliCode(Config config) {
    final buffer = StringBuffer();

    // Add metadata as comments
    buffer.writeln('// Config: ${config.metadata.name}');
    buffer.writeln('// Author: ${config.metadata.author}');
    buffer.writeln('// Category: ${config.metadata.category}');
    if (config.metadata.description.isNotEmpty) {
      buffer.writeln('// Description: ${config.metadata.description}');
    }
    buffer.writeln();

    // Add blocks
    for (final block in config.blocks) {
      if (block.id == 'LoliCode') {
        buffer.writeln(block.toLoliCode());
      } else {
        // Regular blocks need BLOCK wrapper
        buffer.writeln('BLOCK:${block.id}');
        if (block.label.isNotEmpty) {
          buffer.writeln('LABEL:${block.label}');
        }
        if (block.disabled) {
          buffer.writeln('DISABLED');
        }
        if (block.safe) {
          buffer.writeln('SAFE');
        }
        buffer.write(block.toLoliCode());
        buffer.writeln('ENDBLOCK');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  static bool isValidLoliCode(String loliCode) {
    try {
      parseConfig(loliCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  static List<String> extractBlockTypes(String loliCode) {
    final blockTypes = <String>[];
    final lines = loliCode.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('BLOCK:')) {
        final blockType = trimmed.substring(6);
        if (!blockTypes.contains(blockType)) {
          blockTypes.add(blockType);
        }
      }
    }

    return blockTypes;
  }

  static String? _identifyBlockType(String line) {
    var trimmed = line.trim().toUpperCase();

    // Handle label prefix (e.g., "#GET REQUEST GET" or "#Label REQUEST")
    if (trimmed.startsWith('#')) {
      final labelEnd = trimmed.indexOf(' ');
      if (labelEnd != -1) {
        trimmed = trimmed.substring(labelEnd + 1).trimLeft();
      }
    }

    if (trimmed.startsWith('FUNCTION ')) {
      return 'Function';
    } else if (trimmed.startsWith('REQUEST ')) {
      return 'Request';
    } else if (trimmed.startsWith('PARSE ')) {
      return 'Parse';
    } else if (trimmed.startsWith('KEYCHECK')) {
      return 'Keycheck';
    }

    return null;
  }

  /// Sanitize JSON string by fixing invalid escape sequences
  static String _sanitizeJsonString(String jsonString) {
    final invalidEscapePattern = RegExp(r'\\([^"\\/bfnrtu])');

    final sanitizedJson =
        jsonString.replaceAllMapped(invalidEscapePattern, (match) {
      final invalidChar = match.group(1);
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print(
            'Warning: Sanitizing invalid JSON escape sequence: \\$invalidChar -> \\\\$invalidChar');
      }
      return '\\\\$invalidChar';
    });

    return sanitizedJson;
  }
}
