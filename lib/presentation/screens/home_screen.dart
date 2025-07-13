import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/camera_button.dart';
import '../widgets/collection_tab.dart';
import '../widgets/garden_grid.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CameraScreen(),
    const GardenScreen(),
    const CollectionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(final BuildContext context) => Scaffold(
    body: _screens[_currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (final index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '카메라'),
        BottomNavigationBarItem(icon: Icon(Icons.park), label: '정원'),
        BottomNavigationBarItem(icon: Icon(Icons.collections), label: '도감'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
    ),
  );
}

// 카메라 스크린
class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_florist,
            size: 32,
            color: Colors.pink,
          ),
          SizedBox(width: 8),
          Text('FloraSnap'),
        ],
      ),
      centerTitle: true,
    ),
    body: const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 상단 설명
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_florist,
                        size: 24,
                        color: Colors.pink,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '식물이나 꽃을 찍어보세요!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI가 식물을 인식하고 정원에 추가해드립니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          // 카메라 버튼
          Expanded(child: Center(child: CameraButton())),
        ],
      ),
    ),
  );
}

// 정원 스크린
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.park,
            size: 28,
            color: Colors.green,
          ),
          SizedBox(width: 8),
          Text('내 정원'),
        ],
      ),
      centerTitle: true,
    ),
    body: const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 정원 그리드
          Expanded(child: GardenGrid()),
        ],
      ),
    ),
  );
}

// 도감 스크린
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book,
            size: 28,
            color: Colors.orange,
          ),
          SizedBox(width: 8),
          Text('식물 도감'),
        ],
      ),
      centerTitle: true,
    ),
    body: const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 도감 탭
          Expanded(child: CollectionTab()),
        ],
      ),
    ),
  );
}
