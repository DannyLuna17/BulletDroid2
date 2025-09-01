class BlockDescriptor {
  String id;
  String name;
  String category;
  String description;
  Map<String, BlockParameter> parameters;

  BlockDescriptor({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    Map<String, BlockParameter>? parameters,
  }) : parameters = parameters ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'parameters':
          parameters.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

abstract class BlockParameter {
  String name;
  String description;
  bool required;
  dynamic defaultValue;

  BlockParameter({
    required this.name,
    this.description = '',
    this.required = false,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'required': required,
      'defaultValue': defaultValue,
    };
  }
}

class StringParameter extends BlockParameter {
  bool multiLine;

  StringParameter({
    required String name,
    String description = '',
    bool required = false,
    String? defaultValue,
    this.multiLine = false,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}

class IntParameter extends BlockParameter {
  int? min;
  int? max;

  IntParameter({
    required String name,
    String description = '',
    bool required = false,
    int? defaultValue,
    this.min,
    this.max,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}

class FloatParameter extends BlockParameter {
  double? min;
  double? max;

  FloatParameter({
    required String name,
    String description = '',
    bool required = false,
    double? defaultValue,
    this.min,
    this.max,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}

class BoolParameter extends BlockParameter {
  BoolParameter({
    required String name,
    String description = '',
    bool required = false,
    bool? defaultValue,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}

class ListParameter extends BlockParameter {
  ListParameter({
    required String name,
    String description = '',
    bool required = false,
    List<String>? defaultValue,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}

class MapParameter extends BlockParameter {
  MapParameter({
    required String name,
    String description = '',
    bool required = false,
    Map<String, String>? defaultValue,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}

class EnumParameter extends BlockParameter {
  List<String> options;

  EnumParameter({
    required String name,
    required this.options,
    String description = '',
    bool required = false,
    String? defaultValue,
  }) : super(
            name: name,
            description: description,
            required: required,
            defaultValue: defaultValue);
}
