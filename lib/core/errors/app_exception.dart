sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SttException extends AppException {
  const SttException(super.message);
}

class TranslationException extends AppException {
  const TranslationException(super.message);
}

class TtsException extends AppException {
  const TtsException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class PurchaseException extends AppException {
  const PurchaseException(super.message);
}
