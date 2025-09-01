import '../../core/bot_data.dart';

abstract class BlockInstance {
  String id;
  String label;
  bool disabled;
  bool safe;

  BlockInstance({
    required this.id,
    this.label = '',
    this.disabled = false,
    this.safe = false,
  });

  Future<void> execute(BotData data);

  void fromLoliCode(String content);

  String toLoliCode();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'disabled': disabled,
      'safe': safe,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    label = json['label'] ?? '';
    disabled = json['disabled'] ?? false;
    safe = json['safe'] ?? false;
  }
}
