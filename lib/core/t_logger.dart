typedef OnTLoggerMessageCallback = void Function(String message);

class TLogger {
  static final TLogger instance = TLogger._();
  TLogger._();
  factory TLogger() => instance;

  static bool isDebugLog = true;
  OnTLoggerMessageCallback? onMessageLog;

  void init({OnTLoggerMessageCallback? onMessageLog}) {
    this.onMessageLog = onMessageLog;
  }

  void showLog(String message, {String? tag}) {
    var msg = message;
    if (tag != null) {
      msg = '[$tag]: $message';
    }
    onMessageLog?.call(msg);
  }
}
