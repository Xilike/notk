import 'dart:io';
import 'speech_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  RecordingService() {
    SpeechService.stopExternalAudio = player.stop;
  }
  bool _busy = false;
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();
  String? lastPath;

  Future<bool> start(String id) async {
    if (_busy || SpeechService.recordingActive) return false;
    _busy = true;
    var started = false;
    try {
      if (!await recorder.hasPermission()) return false;
      SpeechService.recordingActive = true;
      await SpeechService.stop();
      await player.stop();
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/practice_$id.m4a';
      await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path);
      lastPath = path;
      started = true;
      return true;
    } finally {
      if (!started) SpeechService.recordingActive = false;
      _busy = false;
    }
  }

  Future<String?> stop() async {
    lastPath = await recorder.stop();
    SpeechService.recordingActive = false;
    return lastPath;
  }

  Future<bool> playLast() async {
    if (_busy ||
        SpeechService.recordingActive ||
        lastPath == null ||
        !File(lastPath!).existsSync()) {
      return false;
    }
    _busy = true;
    try {
      await SpeechService.stop();
      await player.stop();
      await player.play(DeviceFileSource(lastPath!));
      return true;
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() async {
    SpeechService.recordingActive = false;
    SpeechService.stopExternalAudio = null;
    await recorder.dispose();
    await player.dispose();
  }
}
