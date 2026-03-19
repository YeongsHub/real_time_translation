import 'dart:async';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:real_time_translation/core/errors/app_exception.dart';
import 'package:real_time_translation/features/stt/domain/repositories/stt_service.dart';

/// On-device STT using speech_to_text (offline-capable on both iOS and Android).
class DeviceSttService implements SttService {
  DeviceSttService() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;
  StreamController<SttResult>? _controller;
  bool _initialized = false;
  bool _restarting = false;

  @override
  bool get isListening => _speech.isListening;

  @override
  Stream<SttResult> startListening({required String localeId}) {
    _controller?.close();
    _controller = StreamController<SttResult>.broadcast();

    _initAndListen(localeId);
    return _controller!.stream;
  }

  Future<void> _initAndListen(String localeId) async {
    try {
      if (!_initialized) {
        final available = await _speech.initialize(
          onError: (error) {
            if (error.errorMsg == 'error_speech_timeout' ||
                error.errorMsg == 'error_no_match') {
              _restartListening(localeId);
              return;
            }
            _controller?.addError(SttException(error.errorMsg));
          },
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              _restartListening(localeId);
            }
          },
        );

        if (!available) {
          _controller?.addError(
            const SttException('Speech recognition not available'),
          );
          return;
        }

        _initialized = true;
      }

      _listenOnce(localeId);
    } on PlatformException catch (e) {
      _controller?.addError(
        SttException(e.message ?? 'STT initialization failed'),
      );
    }
  }

  void _restartListening(String localeId) {
    if (_restarting || _controller == null || _controller!.isClosed) return;
    _restarting = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      _restarting = false;
      if (_controller != null && !_controller!.isClosed) {
        _listenOnce(localeId);
      }
    });
  }

  void _listenOnce(String localeId) {
    if (_controller == null || _controller!.isClosed) return;

    _speech.listen(
      localeId: localeId,
      onResult: (result) {
        _controller?.add(SttResult(
          text: result.recognizedWords,
          isFinal: result.finalResult,
        ));
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> dispose() async {
    await stopListening();
    _initialized = false;
  }
}
