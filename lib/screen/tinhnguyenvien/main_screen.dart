import 'package:flutter/material.dart';

class VolunteerMainScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const VolunteerMainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // VolunteerHomeTab(user: widget.user),
      // VolunteerEventsTab(user: widget.user),
      // VolunteerScheduleTab(user: widget.user),
      // VolunteerChildrenTab(user: widget.user),
      // VolunteerNotificationTab(user: widget.user),
      // VolunteerAccountTab(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Sự kiện'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch trống'),
          BottomNavigationBarItem(icon: Icon(Icons.child_care), label: 'Trẻ em'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}