import 'block_instance.dart';
import '../http/request_block.dart';
import '../parsing/parse_block.dart';
import '../logic/keycheck_block.dart';
import '../functions/function_block.dart';
import '../utility/loli_code_block.dart';
import '../utility/utility_block.dart';

class BlockFactory {
  static final Map<String, BlockInstance Function()> _blockCreators = {
    'Request': () => RequestBlock(),
    'Parse': () => ParseBlock(),
    'Keycheck': () => KeycheckBlock(),
    'Function': () => FunctionBlock(),
    'LoliCode': () => LoliCodeBlock(),
    'Utility': () => UtilityBlock(),
  };

  static BlockInstance createBlock(String blockType) {
    final creator = _blockCreators[blockType];
    if (creator == null) {
      throw ArgumentError('Unknown block type: $blockType');
    }
    return creator();
  }

  static List<String> getSupportedBlockTypes() {
    return _blockCreators.keys.toList();
  }

  static bool isSupported(String blockType) {
    return _blockCreators.containsKey(blockType);
  }

  static void registerBlock(
      String blockType, BlockInstance Function() creator) {
    _blockCreators[blockType] = creator;
  }
}
