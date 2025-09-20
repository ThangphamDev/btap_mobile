import 'package:flutter/material.dart';

import 'alarm_screen.dart';
import 'mlkit_translate_screen.dart';
import 'camera_translate_screen.dart';
import 'group_info_screen.dart';
import 'information_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasActiveAlarm = false;

  // Tạo các widget một lần để duy trì trạng thái
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      AlarmScreen(onAlarmStatusChanged: _updateAlarmStatus),
      MLKitTranslateScreen(),
      CameraTranslateScreen(),
      GroupInfoScreen(),
      InformationScreen(),
      SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateAlarmStatus(bool hasAlarm) {
    setState(() {
      _hasActiveAlarm = hasAlarm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pham Xuan Thang'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _hasActiveAlarm
                ? Stack(
                    children: [
                      const Icon(Icons.alarm),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.alarm),
            label: 'Đồng hồ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Dịch',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Nhóm'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Thông tin',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
