import 'package:flutter/material.dart';
class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      // VolunteerHomeTab(),
      // VolunteerEventsTab(),
      // VolunteerScheduleTab(),
      // VolunteerChildrenTab(),
      // VolunteerNotificationTab(),
      // VolunteerAccountTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text('Tình nguyện viên'),
      ),
      // body: IndexedStack(
      //   index: _selectedIndex,
      //   children: _screens,
      // ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: (index) => setState(() => _selectedIndex = index),
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   selectedFontSize: 12,
      //   unselectedFontSize: 11,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Trang chủ',),
      //     BottomNavigationBarItem(icon: Icon(Icons.event),label: 'Sự kiện',),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_today),label: 'Lịch trống',),
      //     BottomNavigationBarItem(icon: Icon(Icons.child_care),),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications),label: 'Thông báo',),
      //     BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Tài khoản',),
      //   ],
      // ),
    );
  }
}