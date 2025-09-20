import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  DateTime? _alarmTime;
  Timer? _alarmTimer;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  bool _isAlarmRinging = false;

  static const platform = MethodChannel('alarm_channel');

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _startClock();
    _initializeNotifications();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notifications.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
            _processCommand(_recognizedText);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processCommand(String command) {
    command = command.toLowerCase();

    // Tìm thời gian dạng "7:30" hoặc "7 giờ 30"
    final regexTime = RegExp(r'(\d{1,2}):(\d{2})');
    final matchTime = regexTime.firstMatch(command);

    if (matchTime != null) {
      final hour = int.parse(matchTime.group(1)!);
      final minute = int.parse(matchTime.group(2)!);
      _setAlarm(hour, minute);
      return;
    }

    // Tìm thời gian dạng "7 giờ 30 phút"
    final regexText = RegExp(r'(\d{1,2})\s*(giờ|h)\s*(\d{1,2})?\s*(phút)?');
    final matchText = regexText.firstMatch(command);

    if (matchText != null) {
      final hour = int.parse(matchText.group(1)!);
      final minute = matchText.group(3) != null
          ? int.parse(matchText.group(3)!)
          : 0;
      _setAlarm(hour, minute);
      return;
    }
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
      _alarmTime = alarmDateTime;
    });

    await _showNotification(alarmDateTime);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Đã đặt báo thức thành công lúc $hour:${minute.toString().padLeft(2, '0')}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _setSystemAlarm(int hour, int minute) async {
    try {
      final result = await platform.invokeMethod('setAlarm', {
        'hour': hour,
        'minute': minute,
        'message': 'Báo thức từ Pham Xuan Thang',
      });

      if (result == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã cài báo thức vào hệ thống thành công!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Không thể cài báo thức vào hệ thống'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi cài báo thức: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showNotification(DateTime dateTime) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Báo thức',
      description: 'Thông báo báo thức từ ứng dụng',
      importance: Importance.max,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Báo thức',
          channelDescription: 'Thông báo báo thức từ ứng dụng',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0,
      'Báo thức',
      'Báo thức đã được đặt lúc ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
      notificationDetails,
    );
  }

  void _triggerAlarm() async {
    setState(() {
      _isAlarmRinging = true;
    });

    // Hiển thị dialog báo thức
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🔔 Báo thức!'),
            content: Text(
              'Đã đến giờ báo thức: ${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isAlarmRinging = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Tắt báo thức'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildSimpleDigitalClock() {
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: _isAlarmRinging ? Colors.red.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: _isAlarmRinging
            ? Border.all(color: Colors.red, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: _isAlarmRinging
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: _isAlarmRinging ? 30 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _isAlarmRinging ? Colors.red : Colors.black,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Đặt báo thức bằng giọng nói',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Voice recognition button
          GestureDetector(
            onTap: _listen,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? Colors.red.shade400
                    : Colors.blue.shade400,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.blue).withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Recognized text
          if (_recognizedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'Bạn nói: $_recognizedText',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          // Alarm time display
          if (_alarmTime != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Báo thức: ${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // System alarm button
          if (_alarmTime != null)
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, size: 20),
              label: const Text('Đặt báo thức vào hệ thống'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () =>
                  _setSystemAlarm(_alarmTime!.hour, _alarmTime!.minute),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pham Xuan Thang',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Simple Digital Clock
            _buildSimpleDigitalClock(),
            const SizedBox(height: 40),
            // Voice Recognition Section
            _buildVoiceSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
