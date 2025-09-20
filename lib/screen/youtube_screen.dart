import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> {
  final TextEditingController _controller = TextEditingController();
  YoutubePlayerController? _ytController;
  String? _videoId;

  void _playVideo() {
    final url = _controller.text.trim();
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      setState(() {
        _videoId = videoId;
        _ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link Youtube không hợp lệ!')),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem Youtube')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Dán link Youtube',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Phát video'),
              onPressed: _playVideo,
            ),
            const SizedBox(height: 24),
            if (_ytController != null && _videoId != null)
              YoutubePlayer(
                controller: _ytController!,
                showVideoProgressIndicator: true,
              ),
          ],
        ),
      ),
    );
  }
}
