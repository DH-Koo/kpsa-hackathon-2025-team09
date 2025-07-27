import 'package:audioplayers/audioplayers.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MusicService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  static String? _currentMusicId;

  // 현재 재생 상태
  static bool get isPlaying => _isPlaying;
  static String? get currentMusicId => _currentMusicId;

  // 음악 재생
  static Future<void> playMusic(int medicineId, int musicId) async {
    try {
      // 현재 재생 중인 음악이 있다면 중지
      if (_isPlaying) {
        await stopMusic();
      }

      // 음악 바이너리 데이터 가져오기
      final audioData = await ChatApiService.getMusicBinary(medicineId, musicId);
      
      if (audioData.isEmpty) {
        throw Exception('음악 데이터를 가져올 수 없습니다.');
      }

      // 바이너리 데이터를 임시 파일로 저장하고 재생
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio_$musicId.wav');
      await tempFile.writeAsBytes(audioData);

      // 음악 재생
      await _audioPlayer.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
      _currentMusicId = musicId.toString();
      
      print('[MusicService] 음악 재생 시작: ${tempFile.path}');
    } catch (e) {
      print('[MusicService] 음악 재생 실패: $e');
      rethrow;
    }
  }

  // 음악 중지
  static Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentMusicId = null;
      print('[MusicService] 음악 재생 중지');
    } catch (e) {
      print('[MusicService] 음악 중지 실패: $e');
    }
  }

  // 음악 일시정지/재개
  static Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
        print('[MusicService] 음악 일시정지');
      } else {
        await _audioPlayer.resume();
        _isPlaying = true;
        print('[MusicService] 음악 재개');
      }
    } catch (e) {
      print('[MusicService] 음악 재생/일시정지 실패: $e');
    }
  }

  // 리소스 정리
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isPlaying = false;
      _currentMusicId = null;
      print('[MusicService] 리소스 정리 완료');
    } catch (e) {
      print('[MusicService] 리소스 정리 실패: $e');
    }
  }

  // 재생 완료 이벤트 리스너
  static void onPlayerComplete(Function() callback) {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _currentMusicId = null;
      callback();
    });
  }
} 