import 'dart:typed_data';
import 'dart:convert';
import 'variable_types.dart';

abstract class Variable {
  String name;
  bool markedForCapture;
  VariableType type;

  Variable(this.name, this.type, {this.markedForCapture = false});

  String asString();
  int asInt();
  double asDouble();
  bool asBool();
  List<String> asList();
  Map<String, String> asMap();
  Uint8List asByteArray();
  dynamic asObject();
}

class StringVariable extends Variable {
  final String value;

  StringVariable(String name, this.value) : super(name, VariableType.String);

  @override
  String asString() => value;

  @override
  int asInt() {
    final parsed = int.tryParse(value);
    if (parsed == null) throw FormatException('Cannot convert "$value" to int');
    return parsed;
  }

  @override
  double asDouble() {
    final parsed = double.tryParse(value);
    if (parsed == null)
      throw FormatException('Cannot convert "$value" to double');
    return parsed;
  }

  @override
  bool asBool() {
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    throw FormatException('Cannot convert "$value" to bool');
  }

  @override
  List<String> asList() => [value];

  @override
  Map<String, String> asMap() => {value: ''};

  @override
  Uint8List asByteArray() => Uint8List.fromList(utf8.encode(value));

  @override
  dynamic asObject() => value;
}

class IntVariable extends Variable {
  final int value;

  IntVariable(String name, this.value) : super(name, VariableType.Int);

  @override
  String asString() => value.toString();

  @override
  int asInt() => value;

  @override
  double asDouble() => value.toDouble();

  @override
  bool asBool() {
    if (value == 0) return false;
    if (value == 1) return true;
    throw FormatException('Cannot convert $value to bool');
  }

  @override
  List<String> asList() => [value.toString()];

  @override
  Map<String, String> asMap() => {value.toString(): ''};

  @override
  Uint8List asByteArray() {
    final bytes = ByteData(4);
    bytes.setInt32(0, value);
    return bytes.buffer.asUint8List();
  }

  @override
  dynamic asObject() => value;
}

class FloatVariable extends Variable {
  final double value;

  FloatVariable(String name, this.value) : super(name, VariableType.Float);

  @override
  String asString() => value.toString();

  @override
  int asInt() => value.toInt();

  @override
  double asDouble() => value;

  @override
  bool asBool() {
    if (value == 0.0) return false;
    if (value == 1.0) return true;
    throw FormatException('Cannot convert $value to bool');
  }

  @override
  List<String> asList() => [value.toString()];

  @override
  Map<String, String> asMap() => {value.toString(): ''};

  @override
  Uint8List asByteArray() {
    final bytes = ByteData(8);
    bytes.setFloat64(0, value);
    return bytes.buffer.asUint8List();
  }

  @override
  dynamic asObject() => value;
}

class BoolVariable extends Variable {
  final bool value;

  BoolVariable(String name, this.value) : super(name, VariableType.Bool);

  @override
  String asString() => value.toString();

  @override
  int asInt() => value ? 1 : 0;

  @override
  double asDouble() => value ? 1.0 : 0.0;

  @override
  bool asBool() => value;

  @override
  List<String> asList() => [value.toString()];

  @override
  Map<String, String> asMap() => {value.toString(): ''};

  @override
  Uint8List asByteArray() => Uint8List.fromList([value ? 1 : 0]);

  @override
  dynamic asObject() => value;
}

class ListVariable extends Variable {
  final List<String> value;

  ListVariable(String name, this.value)
      : super(name, VariableType.ListOfStrings);

  @override
  String asString() => '[${value.join(', ')}]';

  @override
  int asInt() {
    if (value.isEmpty) throw StateError('Cannot convert empty list to int');
    return int.parse(value.first);
  }

  @override
  double asDouble() {
    if (value.isEmpty) throw StateError('Cannot convert empty list to double');
    return double.parse(value.first);
  }

  @override
  bool asBool() {
    if (value.isEmpty) throw StateError('Cannot convert empty list to bool');
    return bool.parse(value.first);
  }

  @override
  List<String> asList() => List.from(value);

  @override
  Map<String, String> asMap() {
    final map = <String, String>{};
    for (final item in value) {
      map[item] = '';
    }
    return map;
  }

  @override
  Uint8List asByteArray() => Uint8List.fromList(utf8.encode(asString()));

  @override
  dynamic asObject() => value;
}

class MapVariable extends Variable {
  final Map<String, String> value;

  MapVariable(String name, this.value)
      : super(name, VariableType.DictionaryOfStrings);

  @override
  String asString() {
    final pairs = value.entries.map((e) => '(${e.key}, ${e.value})').join(', ');
    return '{$pairs}';
  }

  @override
  int asInt() => throw UnsupportedError('Cannot convert dictionary to int');

  @override
  double asDouble() =>
      throw UnsupportedError('Cannot convert dictionary to double');

  @override
  bool asBool() => throw UnsupportedError('Cannot convert dictionary to bool');

  @override
  List<String> asList() =>
      value.entries.map((e) => '${e.key}, ${e.value}').toList();

  @override
  Map<String, String> asMap() => Map.from(value);

  @override
  Uint8List asByteArray() => Uint8List.fromList(utf8.encode(asString()));

  @override
  dynamic asObject() => value;
}

class ByteArrayVariable extends Variable {
  final Uint8List value;

  ByteArrayVariable(String name, this.value)
      : super(name, VariableType.ByteArray);

  @override
  String asString() => utf8.decode(value);

  @override
  int asInt() {
    if (value.length < 4)
      throw StateError('Byte array too short for int conversion');
    return ByteData.sublistView(value).getInt32(0);
  }

  @override
  double asDouble() {
    if (value.length < 8)
      throw StateError('Byte array too short for double conversion');
    return ByteData.sublistView(value).getFloat64(0);
  }

  @override
  bool asBool() {
    if (value.isEmpty)
      throw StateError('Empty byte array cannot be converted to bool');
    return value[0] != 0;
  }

  @override
  List<String> asList() => [asString()];

  @override
  Map<String, String> asMap() => {asString(): ''};

  @override
  Uint8List asByteArray() => Uint8List.fromList(value);

  @override
  dynamic asObject() => value;
}
