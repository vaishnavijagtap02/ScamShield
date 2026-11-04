sealed class AppException implements Exception {
  const new(this.message);
  final String message;

  @override
  String toString() => 'AppException: $message';
}

class SttException extends AppException {
  const new(super.message, {this.statusCode});
  final int? statusCode;
}

class LlmException extends AppException {
  const new(super.message, {this.statusCode});
  final int? statusCode;
}

class AlertException extends AppException {
  const new(super.message, {this.statusCode});
  final int? statusCode;
}

class AudioFormatException extends AppException {
  const new(super.message);
}
