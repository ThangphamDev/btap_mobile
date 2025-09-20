import 'package:flutter/material.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({Key? key}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  final List<GroupMember> _members = [
    GroupMember(
      name: 'Phạm Xuân Thắng',
      role: 'Leader & Flutter Developer',
      email: 'thangpx@example.com',
      phone: '+84 123 456 789',
      avatar: '👨‍💻',
      skills: ['Flutter', 'Dart', 'Android', 'iOS', 'Firebase'],
      description:
          'Leader nhóm với 5 năm kinh nghiệm phát triển ứng dụng di động, chuyên về Flutter và mobile development.',
    ),
    GroupMember(
      name: 'Nguyễn Xuân Việt',
      role: 'Backend Developer',
      email: 'viet.nguyen@example.com',
      phone: '+84 987 654 321',
      avatar: '👨‍💻',
      skills: ['Node.js', 'Python', 'MongoDB', 'PostgreSQL', 'API'],
      description:
          'Chuyên gia phát triển backend với kiến thức sâu về database và thiết kế API RESTful.',
    ),
    GroupMember(
      name: 'Lê Thái Vinh',
      role: 'Frontend Developer',
      email: 'vinh.le@example.com',
      phone: '+84 555 123 456',
      avatar: '👨‍💻',
      skills: ['React', 'Vue.js', 'JavaScript', 'HTML/CSS', 'UI/UX'],
      description:
          'Chuyên gia phát triển frontend với kinh nghiệm thiết kế giao diện người dùng đẹp và responsive.',
    ),
    GroupMember(
      name: 'Thái Đức Sĩ Nguyên',
      role: 'Full-stack Developer',
      email: 'nguyen.thai@example.com',
      phone: '+84 777 888 999',
      avatar: '👨‍💻',
      skills: ['Java', 'Spring Boot', 'React', 'MySQL', 'Docker'],
      description:
          'Full-stack developer với khả năng phát triển cả frontend và backend, kinh nghiệm với Java ecosystem.',
    ),
    GroupMember(
      name: 'Nguyễn Kim Quang',
      role: 'Mobile Developer',
      email: 'quang.nguyen@example.com',
      phone: '+84 333 444 555',
      avatar: '👨‍💻',
      skills: ['React Native', 'Flutter', 'Kotlin', 'Swift', 'Firebase'],
      description:
          'Chuyên gia phát triển ứng dụng di động đa nền tảng với kinh nghiệm React Native và Flutter.',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Thông tin nhóm',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              _showGroupStats();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _members.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.blue.shade600
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Member Cards
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  return _buildMemberCard(_members[index]);
                },
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Trước'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _currentIndex > 0 ? _previousMember : null,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Tiếp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _currentIndex < _members.length - 1
                        ? _nextMember
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(GroupMember member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Avatar and Name
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      member.avatar,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name and Role
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    member.role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Info
                _buildInfoRow(Icons.email, member.email),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, member.phone),
                const SizedBox(height: 16),

                // Skills
                Text(
                  'Kỹ năng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: member.skills
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade300),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    member.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  void _previousMember() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextMember() {
    if (_currentIndex < _members.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showGroupStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê nhóm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem('Tổng thành viên', '${_members.length} người'),
            _buildStatItem(
              'Vị trí',
              '${_members.map((m) => m.role).toSet().length} vai trò',
            ),
            _buildStatItem(
              'Kỹ năng',
              '${_members.expand((m) => m.skills).toSet().length} kỹ năng',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class GroupMember {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String avatar;
  final List<String> skills;
  final String description;

  GroupMember({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.skills,
    required this.description,
  });
}
