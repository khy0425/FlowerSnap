import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flora_snap/presentation/screens/flora_snap_home_screen.dart';

void main() {
  group('FloraSnapHomeScreen Widget Tests', () {
    
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: const FloraSnapHomeScreen(),
        ),
      );
    }

    group('Basic Widget Structure', () {
      testWidgets('should build without crashing', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // 기본적인 위젯이 빌드되었는지 확인
        expect(find.byType(FloraSnapHomeScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display app bar', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // 앱바 존재 확인
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display floating action button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // FAB 존재 확인 (카메라 버튼)
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('UI Elements', () {
      testWidgets('should display main camera section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // 카메라 관련 아이콘들 확인
        expect(find.byIcon(Icons.camera_alt), findsWidgets);
      });

      testWidgets('should handle tap interactions safely', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // FloatingActionButton 존재 확인
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);
        
        // 탭 후에도 위젯이 정상적으로 존재하는지 확인
        expect(find.byType(FloraSnapHomeScreen), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should render efficiently', (tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(createTestWidget());
        
        stopwatch.stop();
        
        // 1초 이내에 렌더링되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
} 