import 'comparer.dart';
import 'bot_data.dart';
import '../parsing/interpolation_engine.dart';

/// Static class for evaluating conditions
class Condition {
  /// Evaluates a condition without variable replacement
  static bool evaluate(String left, Comparer comparer, String right) {
    switch (comparer) {
      case Comparer.equalTo:
        return left == right;
      case Comparer.notEqualTo:
        return left != right;
      case Comparer.contains:
        return left.contains(right);
      case Comparer.doesNotContain:
        return !left.contains(right);
      case Comparer.greaterThan:
        return _compareNumeric(left, right) > 0;
      case Comparer.lessThan:
        return _compareNumeric(left, right) < 0;
      case Comparer.startsWith:
        return left.startsWith(right);
      case Comparer.endsWith:
        return left.endsWith(right);
      case Comparer.matches:
        try {
          return RegExp(right).hasMatch(left);
        } catch (e) {
          return false;
        }
      case Comparer.doesNotMatch:
        try {
          return !RegExp(right).hasMatch(left);
        } catch (e) {
          return true;
        }
      case Comparer.exists:
        return left.isNotEmpty;
      case Comparer.doesNotExist:
        return left.isEmpty;
    }
  }

  /// Evaluates a condition with variable interpolation
  static bool evaluateWithData(
      String left, Comparer comparer, String right, BotData data) {
    final interpolatedLeft =
        InterpolationEngine.interpolateForLoliCode(left, data.variables, data);
    final interpolatedRight =
        InterpolationEngine.interpolateForLoliCode(right, data.variables, data);

    if (comparer == Comparer.exists) {
      return interpolatedLeft != left;
    } else if (comparer == Comparer.doesNotExist) {
      return interpolatedLeft == left;
    }

    // For other comparers, evaluate with interpolated values
    return evaluate(interpolatedLeft, comparer, interpolatedRight);
  }

  /// Helper method for numeric comparison
  static int _compareNumeric(String left, String right) {
    try {
      final leftNum = double.parse(left.replaceAll(',', '.'));
      final rightNum = double.parse(right.replaceAll(',', '.'));

      if (leftNum < rightNum) return -1;
      if (leftNum > rightNum) return 1;
      return 0;
    } catch (e) {
      return left.compareTo(right);
    }
  }
}
