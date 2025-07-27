import 'package:flutter/material.dart';
import '../../../models/music.dart';
import '../../../service/music_service.dart';

class MusicCard extends StatefulWidget {
  final Music music;
  final int medicineId;
  final VoidCallback? onPlay;

  const MusicCard({
    super.key,
    required this.music,
    required this.medicineId,
    this.onPlay,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // 재생 완료 이벤트 리스너 등록
    MusicService.onPlayerComplete(() {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  Future<void> _playMusic() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 현재 재생 중인 음악이 이 음악이 아니라면 재생
      if (MusicService.currentMusicId != widget.music.id.toString()) {
        await MusicService.playMusic(widget.medicineId, widget.music.id);
        setState(() {
          isPlaying = true;
        });
      } else {
        // 같은 음악이 재생 중이라면 일시정지/재개
        await MusicService.togglePlayPause();
        setState(() {
          isPlaying = MusicService.isPlaying;
        });
      }

      widget.onPlay?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('음악 재생에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 재생 버튼
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.music.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _playMusic,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPlaying 
                        ? const Color.fromARGB(255, 152, 205, 91)
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: isPlaying ? Colors.black : Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 설명
          Text(
            widget.music.description,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 