import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid2/bullet_droid.dart';
import 'dart:convert';
import 'dart:io';

import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/configs/models/config_summary.dart';

import 'package:bullet_droid/features/configs/presentation/widgets/custom_input_value_field.dart';
import 'package:bullet_droid/shared/providers/custom_input_provider.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';

import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/utils/logging.dart';

class ConfigDetailsScreen extends ConsumerStatefulWidget {
  final String configId;

  const ConfigDetailsScreen({super.key, required this.configId});

  @override
  ConsumerState<ConfigDetailsScreen> createState() =>
      _ConfigDetailsScreenState();
}

class _ConfigDetailsScreenState extends ConsumerState<ConfigDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Config? _config;
  bool _isLoading = true;
  String? _error;

  // Confirmation state for delete action
  bool _showDeleteConfirmation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final configs = ref.read(configsProvider).configs;
      final configSummary = configs.firstWhere((c) => c.id == widget.configId);

      // Load full config from file
      final config = await ConfigLoader.loadFromFile(configSummary.filePath);

      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(configsProvider).configs;
    final configSummary = configs.firstWhere(
      (c) => c.id == widget.configId,
      orElse: () => ConfigSummary(
        id: widget.configId,
        name: 'Unknown Config',
        author: 'Unknown',
        filePath: '',
      ),
    );

    return Scaffold(
      backgroundColor: GeistColors.white,
      appBar: AppBar(
        backgroundColor: GeistColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GeistText.headingLarge(
          configSummary.name,
          color: GeistTextColor.primary,
          fontWeight: FontWeight.w600,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: GeistColors.black,
          unselectedLabelColor: GeistColors.gray500,
          indicatorColor: GeistColors.black,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Custom Inputs'),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: GeistSpacing.md),
            child: GeistButton(
              text: _showDeleteConfirmation ? 'Confirm' : 'Delete',
              variant: _showDeleteConfirmation
                  ? GeistButtonVariant.filled
                  : GeistButtonVariant.ghost,
              size: GeistButtonSize.small,
              icon: Icon(
                _showDeleteConfirmation ? Icons.check : Icons.delete,
                size: 16,
              ),
              onPressed: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GeistColors.black),
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(GeistSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: GeistColors.errorColor,
                    ),
                    SizedBox(height: GeistSpacing.lg),
                    GeistText.headingMedium(
                      'Error loading config',
                      color: GeistTextColor.primary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: GeistSpacing.sm),
                    GeistText.bodyMedium(
                      _error!,
                      color: GeistTextColor.secondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: GeistSpacing.lg),
                    GeistButton(
                      text: 'Retry',
                      variant: GeistButtonVariant.outline,
                      icon: Icon(Icons.refresh),
                      onPressed: _loadConfig,
                    ),
                  ],
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(config: _config!, summary: configSummary),
                _CustomInputsTab(config: _config!, configId: widget.configId),
              ],
            ),
    );
  }

  void _confirmDelete(BuildContext context) {
    if (_showDeleteConfirmation) {
      // Confirm deletion
      ref.read(configsProvider.notifier).deleteConfig(widget.configId);
      setState(() {
        _showDeleteConfirmation = false;
      });
      context.showSuccessToast('Config deleted');
      context.pop();
    } else {
      // Show confirmation state
      setState(() {
        _showDeleteConfirmation = true;
      });
    }
  }
}

class _OverviewTab extends StatelessWidget {
  final Config config;
  final ConfigSummary summary;

  const _OverviewTab({required this.config, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return ListView(
      padding: EdgeInsets.all(isMobile ? GeistSpacing.md : GeistSpacing.lg),
      children: [
        // Config Information Card
        Container(
          decoration: BoxDecoration(
            color: GeistColors.white,
            borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
            border: Border.all(color: GeistColors.gray200),
            boxShadow: [
              BoxShadow(
                color: GeistColors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(GeistSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeistText.headingMedium(
                  'Configuration',
                  color: GeistTextColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: GeistSpacing.lg),
                _buildTwoColumnInfo(context, [
                  ('Name', config.settings.name),
                  (
                    'Author',
                    config.settings.author == ""
                        ? "Unknown"
                        : config.settings.author,
                  ),
                  (
                    'Version',
                    config.settings.version.isEmpty
                        ? 'N/A'
                        : config.settings.version,
                  ),
                  (
                    'Wordlist 1',
                    config.settings.allowedWordlist1.isNotEmpty
                        ? config.settings.allowedWordlist1
                        : 'Any',
                  ),
                  (
                    'Wordlist 2',
                    config.settings.allowedWordlist2.isNotEmpty
                        ? config.settings.allowedWordlist2
                        : 'Any',
                  ),
                  ('Blocks', config.blocks.length.toString()),
                ]),
                if (config.settings.additionalInfo.isNotEmpty) ...[
                  SizedBox(height: GeistSpacing.sm),
                  GeistText.bodyMedium(
                    'Description',
                    color: GeistTextColor.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: GeistSpacing.xs),
                  GeistText.bodyMedium(
                    config.settings.additionalInfo,
                    color: GeistTextColor.secondary,
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: GeistSpacing.lg),

        // Blocks Section
        Container(
          decoration: BoxDecoration(
            color: GeistColors.white,
            borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
            border: Border.all(color: GeistColors.gray200),
            boxShadow: [
              BoxShadow(
                color: GeistColors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(GeistSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeistText.headingMedium(
                  'Blocks',
                  color: GeistTextColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: GeistSpacing.md),
                _BlocksSection(config: config, configId: summary.id),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnInfo(
    BuildContext context,
    List<(String, String)> items,
  ) {
    final rows = <Widget>[];

    for (int i = 0; i < items.length; i += 2) {
      final leftItem = items[i];
      final rightItem = i + 1 < items.length ? items[i + 1] : null;

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: GeistSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                flex: 1,
                child: _buildSingleInfoItem(leftItem.$1, leftItem.$2),
              ),
              SizedBox(width: GeistSpacing.lg),
              // Right column
              Expanded(
                flex: 1,
                child: rightItem != null
                    ? _buildSingleInfoItem(rightItem.$1, rightItem.$2)
                    : Container(), // Empty container if odd number of items
              ),
            ],
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _buildSingleInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GeistSpacing.xs / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText.bodyMedium(
            label,
            color: GeistTextColor.tertiary,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: GeistSpacing.xs / 2),
          GeistText.bodyMedium(
            value,
            color: GeistTextColor.primary,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

class _BlocksSection extends ConsumerStatefulWidget {
  final Config config;
  final String configId;

  const _BlocksSection({required this.config, required this.configId});

  @override
  ConsumerState<_BlocksSection> createState() => _BlocksSectionState();
}

class _BlocksSectionState extends ConsumerState<_BlocksSection> {
  bool _isEditMode = false;
  late TextEditingController _plainTextController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _plainTextController = TextEditingController();
    _plainTextController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _plainTextController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isEditMode) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _toggleEditMode() {
    if (_isEditMode && _hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      setState(() {
        _isEditMode = !_isEditMode;
        if (_isEditMode) {
          _initializePlainText();
        }
        _hasUnsavedChanges = false;
      });
    }
  }

  void _initializePlainText() {
    // Generate plain text without metadata comments
    final plainText = _generateBlocksOnlyLoliCode();
    _plainTextController.text = plainText;
    _hasUnsavedChanges = false;
  }

  String _generateBlocksOnlyLoliCode() {
    final buffer = StringBuffer();

    for (final block in widget.config.blocks) {
      if (block.id == 'LoliCode') {
        // Raw LoliCode blocks don't need BLOCK wrapper
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

  void _saveChanges() async {
    try {
      // Parse the plain text back to config
      final plainText = _plainTextController.text.trim();

      if (plainText.isEmpty) {
        _showErrorMessage('Configuration cannot be empty');
        return;
      }

      // Basic validation
      if (!_validateLoliCode(plainText)) {
        return;
      }

      // Parse the plain text back to config using LoliParser
      final parsedConfig = LoliParser.parseConfig(plainText);

      // Update the widget's config with the parsed blocks
      widget.config.blocks.clear();
      widget.config.blocks.addAll(parsedConfig.blocks);

      // Save to file system
      await _saveConfigToFile();

      context.showSuccessToast('Changes saved successfully');

      setState(() {
        _hasUnsavedChanges = false;
        _isEditMode = false;
      });
    } catch (e) {
      _showErrorMessage('Error saving changes: $e');
    }
  }

  Future<void> _saveConfigToFile() async {
    try {
      final configsNotifier = ref.read(configsProvider.notifier);
      final configs = ref.read(configsProvider).configs;
      final configSummary = configs.firstWhere((c) => c.id == widget.configId);

      final originalContent = await File(configSummary.filePath).readAsString();

      final settingsStart = originalContent.indexOf('[SETTINGS]');
      final scriptStart = originalContent.indexOf('[SCRIPT]');

      if (settingsStart == -1 || scriptStart == -1) {
        throw Exception(
          'Invalid .loli config format: missing [SETTINGS] or [SCRIPT] sections',
        );
      }

      final settingsSection = originalContent
          .substring(settingsStart, scriptStart)
          .trim();

      // Generate the new script section with updated blocks (without metadata comments)
      final scriptSection = '[SCRIPT]\n${_generateBlocksOnlyLoliCode()}';

      // Reconstruct the file content
      final newContent = '$settingsSection\n\n$scriptSection';

      // Write the updated content back to the file
      await File(configSummary.filePath).writeAsString(newContent);

      // Reload configs to reflect changes throughout the app
      await configsNotifier.reloadConfigs();
    } catch (e) {
      throw Exception('Failed to save config to file: $e');
    }
  }

  bool _validateLoliCode(String text) {
    if (text.contains('BLOCK:') && !text.contains('ENDBLOCK')) {
      _showErrorMessage('Unmatched BLOCK/ENDBLOCK statements');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    context.showErrorToast(message);
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isEditMode = false;
                _hasUnsavedChanges = false;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      decoration: BoxDecoration(
        color: GeistColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
        border: Border.all(color: GeistColors.amber.withValues(alpha: 0.3)),
      ),
      padding: EdgeInsets.all(GeistSpacing.md),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: GeistColors.amber, size: 24),
          SizedBox(width: GeistSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeistText.labelMedium(
                  'Edit Mode Active',
                  color: GeistTextColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: GeistSpacing.xs / 2),
                GeistText.bodySmall(
                  'Editing config blocks as plain text may break the configuration if syntax errors are introduced. Please ensure proper LoliCode format.',
                  color: GeistTextColor.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlainTextView() {
    final isMobile = GeistBreakpoints.isMobile(context);
    final editorHeight = isMobile ? 300.0 : 500.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GeistButton(
              text: 'Cancel',
              variant: GeistButtonVariant.ghost,
              size: GeistButtonSize.small,
              onPressed: () {
                if (_hasUnsavedChanges) {
                  _showUnsavedChangesDialog();
                } else {
                  setState(() {
                    _isEditMode = false;
                  });
                }
              },
            ),
            SizedBox(width: GeistSpacing.sm),
            GeistButton(
              text: 'Save Changes',
              variant: GeistButtonVariant.filled,
              size: GeistButtonSize.small,
              icon: Icon(Icons.save, size: 16),
              onPressed: _hasUnsavedChanges ? _saveChanges : null,
            ),
          ],
        ),
        SizedBox(height: GeistSpacing.md),
        SizedBox(
          height: editorHeight,
          child: Container(
            decoration: BoxDecoration(
              color: GeistColors.gray50,
              borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
              border: Border.all(color: GeistColors.gray200),
            ),
            child: TextFormField(
              controller: _plainTextController,
              maxLines: null,
              minLines: 10,
              style: const TextStyle(
                fontFamily: 'GeistMono',
                fontSize: 12,
                color: GeistColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter LoliCode configuration...',
                hintStyle: TextStyle(color: GeistColors.gray500),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(GeistSpacing.md),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocksListView() {
    return ListView.builder(
      padding: EdgeInsets.all(GeistSpacing.md),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.config.blocks.length,
      itemBuilder: (context, index) {
        final block = widget.config.blocks[index];

        return Container(
          margin: EdgeInsets.only(bottom: GeistSpacing.sm),
          decoration: BoxDecoration(
            color: GeistColors.white,
            borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
            border: Border.all(color: GeistColors.gray200),
            boxShadow: [
              BoxShadow(
                color: GeistColors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(
              horizontal: GeistSpacing.md,
              vertical: GeistSpacing.xs,
            ),
            childrenPadding: EdgeInsets.zero,
            title: GeistText.bodyMedium(
              '${index + 1}. ${block.id}',
              color: GeistTextColor.primary,
              fontWeight: FontWeight.w500,
            ),
            subtitle: block.label.isNotEmpty
                ? GeistText.bodySmall(
                    block.label,
                    color: GeistTextColor.secondary,
                  )
                : null,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(GeistSpacing.md),
                decoration: BoxDecoration(
                  color: GeistColors.gray50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(GeistBorders.radiusMedium),
                    bottomRight: Radius.circular(GeistBorders.radiusMedium),
                  ),
                  border: Border(top: BorderSide(color: GeistColors.gray200)),
                ),
                child: SelectableText(
                  block.toLoliCode(),
                  style: const TextStyle(
                    fontFamily: 'GeistMono',
                    fontSize: 12,
                    color: GeistColors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: GeistSpacing.md,
            right: GeistSpacing.md,
            top: GeistSpacing.xs,
            bottom: GeistSpacing.md,
          ),
          decoration: BoxDecoration(
            color: GeistColors.white,
            border: Border(bottom: BorderSide(color: GeistColors.gray200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GeistText.bodyMedium(
                'Edit as Plain Text',
                color: GeistTextColor.primary,
                fontWeight: FontWeight.w500,
              ),
              Switch(
                value: _isEditMode,
                onChanged: (_) => _toggleEditMode(),
                activeColor: GeistColors.black,
                inactiveThumbColor: GeistColors.gray400,
                inactiveTrackColor: GeistColors.gray200,
              ),
            ],
          ),
        ),
        if (_isEditMode) ...[
          Padding(
            padding: EdgeInsets.all(GeistSpacing.md),
            child: _buildWarningCard(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
            child: _buildPlainTextView(),
          ),
        ] else ...[
          _buildBlocksListView(),
        ],
      ],
    );
  }
}

class _CustomInputsTab extends ConsumerStatefulWidget {
  final Config config;
  final String configId;

  const _CustomInputsTab({required this.config, required this.configId});

  @override
  ConsumerState<_CustomInputsTab> createState() => _CustomInputsTabState();
}

class _CustomInputsTabState extends ConsumerState<_CustomInputsTab> {
  List<CustomInput>? _cachedCustomInputs;

  // Accordion state management
  int? _expandedIndex;
  Map<int, GlobalKey<FormState>> _formKeys = {};
  Map<int, TextEditingController> _variableNameControllers = {};
  Map<int, TextEditingController> _descriptionControllers = {};
  Map<int, bool> _isRequiredValues = {};

  // Delete All confirmation state
  bool _showDeleteAllConfirmation = false;

  List<CustomInput> get customInputs {
    if (_cachedCustomInputs != null) {
      return _cachedCustomInputs!;
    }
    try {
      _cachedCustomInputs = widget.config.settings.customInputs;
      return _cachedCustomInputs!;
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (final controller in _variableNameControllers.values) {
      controller.dispose();
    }
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllersForInput(int index) {
    final input = customInputs[index];
    _formKeys[index] = GlobalKey<FormState>();
    _variableNameControllers[index] = TextEditingController(
      text: input.variableName,
    );
    _descriptionControllers[index] = TextEditingController(
      text: input.description,
    );
    _isRequiredValues[index] = input.isRequired;
  }

  void _onExpansionChanged(int index, bool expanded) {
    setState(() {
      if (expanded) {
        _expandedIndex = index;
        if (!_variableNameControllers.containsKey(index)) {
          _initializeControllersForInput(index);
        }
      } else {
        _expandedIndex = null;
      }
    });
  }

  void _saveDynamicChanges(int index) {
    // Validate fields before saving
    if (_formKeys[index]?.currentState?.validate() == true) {
      final updatedInput = CustomInput(
        variableName: _variableNameControllers[index]!.text.trim(),
        description: _descriptionControllers[index]!.text.trim(),
        value: customInputs[index].value,
        isRequired: _isRequiredValues[index] ?? true,
      );

      _updateCustomInput(updatedInput, index);
    }
  }

  void _deleteInlineInput(int index) {
    final input = customInputs[index];
    _deleteCustomInput(index);
    setState(() {
      _expandedIndex = null;
    });
    context.showSuccessToast('Custom input "${input.description}" deleted');
  }

  Widget _buildInlineEditForm(int index) {
    return Form(
      key: _formKeys[index],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _variableNameControllers[index],
                  style: TextStyle(
                    fontFamily: 'GeistMono',
                    fontSize: 14,
                    color: GeistColors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Variable Name',
                    labelStyle: TextStyle(
                      color: GeistColors.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'e.g., username, apiKey',
                    hintStyle: TextStyle(color: GeistColors.gray500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        GeistBorders.radiusSmall,
                      ),
                      borderSide: BorderSide(color: GeistColors.gray300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: GeistSpacing.sm,
                      vertical: GeistSpacing.sm,
                    ),
                  ),
                  onChanged: (value) {
                    _saveDynamicChanges(index);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Variable name is required';
                    }

                    final variableName = value.trim();
                    if (!RegExp(
                      r'^[a-zA-Z_][a-zA-Z0-9_]*$',
                    ).hasMatch(variableName)) {
                      return 'Variable name must start with letter/underscore and contain only letters, numbers, underscores';
                    }

                    final existingNames = customInputs
                        .asMap()
                        .entries
                        .where((entry) => entry.key != index)
                        .map((entry) => entry.value.variableName)
                        .toList();

                    if (existingNames.contains(variableName)) {
                      return 'Variable name already exists';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: GeistSpacing.sm),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GeistColors.errorColor,
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: GeistColors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _deleteInlineInput(index),
                    child: Center(
                      child: Icon(
                        Icons.delete,
                        color: GeistColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: GeistSpacing.md),

          TextFormField(
            controller: _descriptionControllers[index],
            maxLines: 2,
            style: TextStyle(fontSize: 14, color: GeistColors.black),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(
                color: GeistColors.gray600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintText: 'Describe what this input is for',
              hintStyle: TextStyle(color: GeistColors.gray500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GeistBorders.radiusSmall),
                borderSide: BorderSide(color: GeistColors.gray300),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: GeistSpacing.sm,
                vertical: GeistSpacing.sm,
              ),
            ),
            onChanged: (value) {
              _saveDynamicChanges(index);
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          SizedBox(height: GeistSpacing.md),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GeistButton(
                fontSize: 15,
                text: (_isRequiredValues[index] ?? true)
                    ? 'Required: YES'
                    : 'Required: NO',
                variant: (_isRequiredValues[index] ?? true)
                    ? GeistButtonVariant.filled
                    : GeistButtonVariant.outline,
                size: GeistButtonSize.medium,
                width: double.infinity,
                onPressed: () {
                  setState(() {
                    _isRequiredValues[index] =
                        !(_isRequiredValues[index] ?? true);
                  });
                  _saveDynamicChanges(index);
                },
              ),
              SizedBox(height: GeistSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GeistText.bodySmall(
                    'User must provide a value for this input when required',
                    color: GeistTextColor.secondary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cachedCustomInputs = widget.config.settings.customInputs;
    _expandedIndex = null;
    _formKeys = {};
    _variableNameControllers = {};
    _descriptionControllers = {};
    _isRequiredValues = {};
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the widget is still mounted and config is available
    if (!mounted) {
      return const SizedBox.shrink();
    }

    // Get a safe copy of custom inputs
    final safeCustomInputs = customInputs;

    if (safeCustomInputs.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(GeistSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.input, size: 64, color: GeistColors.gray400),
              SizedBox(height: GeistSpacing.lg),
              GeistText.headingMedium(
                'No custom inputs defined',
                color: GeistTextColor.secondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: GeistSpacing.sm),
              GeistText.bodyMedium(
                'Add custom inputs to collect user data for this config',
                color: GeistTextColor.tertiary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: GeistSpacing.xl),
              GeistButton(
                text: 'Add Custom Input',
                variant: GeistButtonVariant.filled,
                icon: Icon(Icons.add),
                onPressed: _addNewCustomInput,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Custom input definitions section
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(GeistSpacing.md),
                decoration: BoxDecoration(
                  color: GeistColors.white,
                  border: Border(
                    bottom: BorderSide(color: GeistColors.gray200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GeistText.headingMedium(
                        'Input Definitions',
                        color: GeistTextColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GeistButton(
                      text: 'Add',
                      variant: GeistButtonVariant.outline,
                      size: GeistButtonSize.small,
                      icon: Icon(Icons.add, size: 16),
                      onPressed: _addNewCustomInput,
                    ),
                    SizedBox(width: GeistSpacing.sm),
                    GestureDetector(
                      onTap: safeCustomInputs.isEmpty
                          ? null
                          : () {
                              if (_showDeleteAllConfirmation) {
                                // Confirm deletion
                                setState(() {
                                  widget.config.settings.customInputs.clear();
                                  _cachedCustomInputs = [];
                                  _showDeleteAllConfirmation = false;
                                  _expandedIndex = null;
                                });
                                _saveConfig();
                                context.showSuccessToast(
                                  'All custom inputs deleted',
                                );
                              } else {
                                // Show confirmation
                                setState(() {
                                  _showDeleteAllConfirmation = true;
                                });
                              }
                            },
                      child: Container(
                        height: 32,
                        padding: EdgeInsets.symmetric(
                          horizontal: GeistSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _showDeleteAllConfirmation
                              ? GeistColors.errorColor
                              : Colors.transparent,
                          border: Border.all(
                            color: safeCustomInputs.isEmpty
                                ? GeistColors.gray300
                                : GeistColors.gray400,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showDeleteAllConfirmation
                                  ? Icons.check
                                  : Icons.delete_sweep,
                              size: 16,
                              color: _showDeleteAllConfirmation
                                  ? GeistColors.white
                                  : (safeCustomInputs.isEmpty
                                        ? GeistColors.gray400
                                        : GeistColors.gray600),
                            ),
                            SizedBox(width: GeistSpacing.xs),
                            GeistText.bodySmall(
                              _showDeleteAllConfirmation
                                  ? 'Confirm'
                                  : 'Delete All',
                              color: _showDeleteAllConfirmation
                                  ? GeistTextColor.primary
                                  : (safeCustomInputs.isEmpty
                                        ? GeistTextColor.tertiary
                                        : GeistTextColor.secondary),
                              fontWeight: FontWeight.w500,
                              customColor: _showDeleteAllConfirmation
                                  ? GeistColors.white
                                  : (safeCustomInputs.isEmpty
                                        ? GeistColors.gray400
                                        : GeistColors.gray600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(GeistSpacing.md),
                  itemCount: safeCustomInputs.length,
                  itemBuilder: (context, index) {
                    if (index >= safeCustomInputs.length) {
                      return const SizedBox.shrink();
                    }
                    final input = safeCustomInputs[index];
                    final isExpanded = _expandedIndex == index;

                    return Container(
                      margin: EdgeInsets.only(bottom: GeistSpacing.sm),
                      decoration: BoxDecoration(
                        color: GeistColors.white,
                        borderRadius: BorderRadius.circular(
                          GeistBorders.radiusMedium,
                        ),
                        border: Border.all(color: GeistColors.gray200),
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: GeistSpacing.md,
                          vertical: GeistSpacing.sm,
                        ),
                        childrenPadding: EdgeInsets.zero,
                        initiallyExpanded: isExpanded,
                        onExpansionChanged: (expanded) =>
                            _onExpansionChanged(index, expanded),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: input.isRequired
                                ? GeistColors.errorColor.withValues(alpha: 0.1)
                                : GeistColors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              GeistBorders.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            input.isRequired ? Icons.star : Icons.star_border,
                            color: input.isRequired
                                ? GeistColors.errorColor
                                : GeistColors.blue,
                            size: 20,
                          ),
                        ),
                        title: GeistText.bodyMedium(
                          input.description,
                          color: GeistTextColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        subtitle: GeistText.bodySmall(
                          'Variable: ${input.variableName}',
                          color: GeistTextColor.secondary,
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(GeistSpacing.md),
                            decoration: BoxDecoration(
                              color: GeistColors.gray50,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  GeistBorders.radiusMedium,
                                ),
                                bottomRight: Radius.circular(
                                  GeistBorders.radiusMedium,
                                ),
                              ),
                              border: Border(
                                top: BorderSide(color: GeistColors.gray200),
                              ),
                            ),
                            child: _buildInlineEditForm(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Custom input values section
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(GeistSpacing.md),
                decoration: BoxDecoration(
                  color: GeistColors.white,
                  border: Border(
                    bottom: BorderSide(color: GeistColors.gray200),
                  ),
                ),
                child: GeistText.headingMedium(
                  'Input Values',
                  color: GeistTextColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(GeistSpacing.md),
                  itemCount: safeCustomInputs.length,
                  itemBuilder: (context, index) {
                    if (index >= safeCustomInputs.length) {
                      return const SizedBox.shrink();
                    }
                    final input = safeCustomInputs[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: GeistSpacing.md),
                      child: CustomInputValueField(
                        customInput: input,
                        configId: widget.configId,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addNewCustomInput() {
    final newInput = CustomInput(
      variableName: 'new_variable',
      description: 'New custom input',
      value: '',
      isRequired: true,
    );

    setState(() {
      widget.config.settings.customInputs.add(newInput);
      _cachedCustomInputs = List.from(widget.config.settings.customInputs);
      final newIndex = widget.config.settings.customInputs.length - 1;
      _expandedIndex = newIndex;
      _initializeControllersForInput(newIndex);
    });
    _saveConfig();
  }

  void _updateCustomInput(CustomInput updatedInput, int index) {
    setState(() {
      widget.config.settings.customInputs[index] = updatedInput;
      _cachedCustomInputs = List.from(widget.config.settings.customInputs);
    });
    _saveConfig();
    _ensureValueSlotExists(updatedInput.variableName);
  }

  void _deleteCustomInput(int index) {
    final safeCustomInputs = customInputs;
    if (index >= safeCustomInputs.length) return;

    final input = safeCustomInputs[index];

    setState(() {
      widget.config.settings.customInputs.removeAt(index);
      _cachedCustomInputs = List.from(widget.config.settings.customInputs);
    });

    // Clear saved values for this custom input asynchronously
    _clearCustomInputValueAsync(input.variableName);

    _saveConfig();
  }

  Future<void> _ensureValueSlotExists(String variableName) async {
    try {
      // Touch the provider storage to ensure config key exists
      final existing = await ref
          .read(customInputProvider.notifier)
          .getCustomInputValue(widget.configId, variableName);
      if (existing == null) {
        // Initialize with empty string so UI can reflect a persisted slot
        await ref
            .read(customInputProvider.notifier)
            .setCustomInputValue(widget.configId, variableName, '');
      }
    } catch (_) {}
  }

  Future<void> _clearCustomInputValueAsync(String variableName) async {
    try {
      await ref
          .read(customInputProvider.notifier)
          .setCustomInputValue(widget.configId, variableName, '');
    } catch (e) {
      Log.w('Error clearing custom input value: $e');
    }
  }

  Future<void> _saveConfig() async {
    if (!mounted) return;

    try {
      // Read the original file content to preserve the [SCRIPT] section
      final configSummary = ref
          .read(configsProvider)
          .configs
          .firstWhere((c) => c.id == widget.configId);

      final originalContent = await File(configSummary.filePath).readAsString();

      if (!mounted) return;

      // Find the positions of [SETTINGS] and [SCRIPT]
      final settingsStart = originalContent.indexOf('[SETTINGS]');
      final scriptStart = originalContent.indexOf('[SCRIPT]');

      if (settingsStart == -1 || scriptStart == -1) {
        throw Exception(
          'Invalid .loli config format: missing [SETTINGS] or [SCRIPT] sections',
        );
      }

      // Extract the script section to preserve it
      final scriptSection = originalContent.substring(scriptStart);

      // Create updated settings JSON
      final updatedSettings = widget.config.settings.toJson();
      final settingsJson = JsonEncoder.withIndent(
        '  ',
      ).convert(updatedSettings);

      // Reconstruct the file content
      final newContent = '[SETTINGS]\n$settingsJson\n\n$scriptSection';

      // Write the updated content back to the file
      await File(configSummary.filePath).writeAsString(newContent);

      if (!mounted) return;

      // Update the configs provider to reflect the changes
      await ref.read(configsProvider.notifier).reloadConfigs();
    } catch (e) {
      Log.w('Error saving config: $e');
      if (mounted) {
        context.showErrorToast('Error saving config: $e');
      }
    }
  }
}
