import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final String phoneNumber =
      '0123456789'; // Số điện thoại mẫu, có thể lấy từ cài đặt

  Future<void> _callPhone() async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể gọi điện!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Thông tin cá nhân', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.phone),
            label: const Text('Gọi điện'),
            onPressed: _callPhone,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.ondemand_video),
            label: const Text('Mở app Youtube'),
            onPressed: () async {
              const youtubeScheme = 'vnd.youtube://';
              if (await canLaunchUrl(Uri.parse(youtubeScheme))) {
                await launchUrl(Uri.parse(youtubeScheme));
              } else {
                // Nếu không mở được app Youtube thì mở trang web Youtube
                const webUrl = 'https://www.youtube.com/';
                if (await canLaunchUrl(Uri.parse(webUrl))) {
                  await launchUrl(Uri.parse(webUrl));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không thể mở Youtube!')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
