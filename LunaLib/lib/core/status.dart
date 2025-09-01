enum BotStatus {
  SUCCESS,
  FAIL,
  RETRY,
  BAN,
  ERROR,
  UNKNOWN,
  CUSTOM,
  NONE,
  TOCHECK
}

class StatusUtils {
  static bool isSuccess(BotStatus status) => status == BotStatus.SUCCESS;
  static bool isFail(BotStatus status) => status == BotStatus.FAIL;
  static bool isRetry(BotStatus status) => status == BotStatus.RETRY;
  static bool isBan(BotStatus status) => status == BotStatus.BAN;
  static bool isError(BotStatus status) => status == BotStatus.ERROR;
  static bool isUnknown(BotStatus status) => status == BotStatus.UNKNOWN;
  static bool isCustom(BotStatus status) => status == BotStatus.CUSTOM;
  static bool isNone(BotStatus status) => status == BotStatus.NONE;
  static bool isToCheck(BotStatus status) => status == BotStatus.TOCHECK;

  /// Get display name for status
  static String getDisplayName(BotStatus status) {
    if (status == BotStatus.TOCHECK) return 'TOCHECK';
    if (status == BotStatus.NONE) return 'NONE';
    return status.toString().split('.').last;
  }
}
