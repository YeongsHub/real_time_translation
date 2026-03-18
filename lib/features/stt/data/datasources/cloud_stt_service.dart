import 'dart:async';
import 'package:dio/dio.dart';
import 'package:real_time_translation/features/stt/domain/repositories/stt_service.dart';

/// Cloud-based STT service for premium users.
/// Uses a backend proxy (Cloud Functions) to avoid embedding API keys.
class CloudSttService implements SttService {
  CloudSttService({required this.dio, required this.proxyBaseUrl});

  final Dio dio;
  final String proxyBaseUrl;
  bool _isListening = false;
  StreamController<SttResult>? _controller;

  @override
  bool get isListening => _isListening;

  @override
  Stream<SttResult> startListening({required String localeId}) {
    _controller?.close();
    _controller = StreamController<SttResult>.broadcast();
    _isListening = true;

    // TODO: Implement actual cloud STT streaming via backend proxy.
    // This will stream audio chunks to Cloud Speech-to-Text via
    // a Cloud Functions endpoint, avoiding direct API key exposure.
    //
    // For now, falls back to the device STT behavior.
    // Implementation will use WebSocket or chunked HTTP streaming.

    return _controller!.stream;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> dispose() async {
    await stopListening();
  }
}
