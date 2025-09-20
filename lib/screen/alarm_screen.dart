import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  TimeOfDay? _alarmTime;
  Timer? _alarmTimer;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _alarmSet = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initNotifications();
    tz.initializeTimeZones();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _notifications.initialize(initSettings);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _recognizedText = val.recognizedWords;
            });
            _parseAlarmTime(val.recognizedWords);
          },
          localeId: 'vi_VN',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _parseAlarmTime(String text) {
    final regexList = [
      RegExp(r'(\d{1,2})[:hH](\d{1,2})'),
      RegExp(r'(\d{1,2})\s*giờ\s*(\d{1,2})'),
      RegExp(r'(\d{1,2})\s*giờ'),
      RegExp(r'(\d{1,2})h'),
    ];
    for (final regex in regexList) {
      final match = regex.firstMatch(text);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = match.groupCount > 1 && match.group(2) != null
            ? int.parse(match.group(2)!)
            : 0;
        setState(() {
          _alarmTime = TimeOfDay(hour: hour, minute: minute);
        });
        _setAlarm(hour, minute);
        return;
      }
    }
    setState(() {
      _alarmTime = null;
      _alarmSet = false;
    });
  }

  Future<void> _setAlarm(int hour, int minute) async {
    _alarmTimer?.cancel();
    final now = DateTime.now();
    DateTime alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(const Duration(days: 1));
    }
    final duration = alarmDateTime.difference(now);
    _alarmTimer = Timer(duration, _triggerAlarm);
    setState(() {
      _alarmSet = true;
    });
    await _showNotification(alarmDateTime);

    // Mở ứng dụng đồng hồ hệ thống để đặt báo thức thật
    final uri = Uri.parse(
      'intent://com.android.deskclock#Intent;action=android.intent.action.SET_ALARM;Sandroid.intent.extra.alarm.MESSAGE=Báo thức AI;Iandroid.intent.extra.alarm.HOUR=$hour;Iandroid.intent.extra.alarm.MINUTES=$minute;end',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // ignore nếu không mở được
    }
  }

  Future<void> _showNotification(DateTime dateTime) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Báo thức',
          channelDescription: 'Thông báo báo thức',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm'),
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    final tz.TZDateTime scheduled = tz.TZDateTime.from(dateTime, tz.local);
    await _notifications.zonedSchedule(
      0,
      'Báo thức',
      'Đã đến giờ báo thức!',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _triggerAlarm() async {
    // Phát âm thanh báo thức
    try {
      await _audioPlayer.setAsset('assets/alarm.mp3');
      await _audioPlayer.play();
    } catch (e) {
      // ignore
    }
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Báo thức!'),
          content: const Text('Đã đến giờ báo thức!'),
          actions: [
            TextButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.of(context).pop();
              },
              child: const Text('Tắt chuông'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng chuyển đổi'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'Đặt báo thức bằng giọng nói',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.blue.shade100
                              : Colors.blue,
                          foregroundColor: _isListening
                              ? Colors.blue
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        onPressed: _listen,
                        child: Text(
                          _isListening ? 'Đang nghe...' : 'Nhấn để nói',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bạn nói:',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Text(
                        _recognizedText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_alarmTime != null)
                        Column(
                          children: [
                            const Text(
                              'Giờ báo thức:',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              _alarmTime!.format(context),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (_alarmSet)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Báo thức đã được đặt!',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      if (_alarmTime == null && _recognizedText.isNotEmpty)
                        const Text(
                          'Không nhận diện được giờ báo thức!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
