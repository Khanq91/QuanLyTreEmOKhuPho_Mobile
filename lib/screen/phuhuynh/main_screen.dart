import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/su_kien_tab.dart';
import 'package:mobile/screen/phuhuynh/tai_khoan_tab.dart';
import 'package:mobile/screen/phuhuynh/thong_bao_tab.dart';
import 'package:mobile/screen/phuhuynh/tre_em_tab.dart';
import 'home_tab.dart';

class ParentMainScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ParentMainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ParentHomeTab(user: widget.user),
      ParentChildrenTab(user: widget.user),
      ParentEventsTab(user: widget.user),
      ParentNotificationTab(user: widget.user),
      ParentAccountTab(user: widget.user),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.child_care), label: 'Con tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Sự kiện'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}