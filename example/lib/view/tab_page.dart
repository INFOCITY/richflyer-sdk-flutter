import 'package:flutter/material.dart';
import 'package:richflyer_sdk_flutter_example/view/received_page.dart';
import 'package:richflyer_sdk_flutter_example/view/segment_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 0;
  final _page = [SegmentPage(), ReceivedPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/images/segment.png'),
                size: 30,
              ),
              label: 'Segment'),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/images/received.png'),
                size: 30,
              ),
              label: 'Received'),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blue,
        onTap: _onTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _onTapped(int index) => setState(() => _currentIndex = index);
}
