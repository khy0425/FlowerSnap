import 'package:flora_snap/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Blooming App Integration Tests', () {
    testWidgets('앱 시작 및 기본 UI 로드 테스트', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle();

      // 기본 UI 요소들이 로드되는지 확인
      expect(find.text('FloraSnap'), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      
      // 토큰 카운트 UI가 있는지 확인
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
      
      print('✅ 기본 UI 로드 테스트 통과');
    });

    testWidgets('네비게이션 테스트 - 설정 화면', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 설정 버튼 찾기 및 탭
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // 설정 화면 UI 확인
      expect(find.text('설정'), findsOneWidget);
      expect(find.text('언어 설정'), findsOneWidget);
      expect(find.text('테마 설정'), findsOneWidget);
      
      // 뒤로가기
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // 메인 화면으로 돌아왔는지 확인
      expect(find.text('FloraSnap'), findsOneWidget);
      
      print('✅ 설정 화면 네비게이션 테스트 통과');
    });

    testWidgets('개발자 메뉴 테스트 (디버그 모드)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 개발자 메뉴 버튼 찾기 (디버그 모드에서만 표시)
      final devMenuButton = find.byIcon(Icons.developer_mode);
      
      if (devMenuButton.evaluate().isNotEmpty) {
        await tester.tap(devMenuButton);
        await tester.pumpAndSettle();

        // 개발자 메뉴 다이얼로그가 나타나는지 확인
        expect(find.text('개발자 메뉴'), findsOneWidget);
        expect(find.text('토큰 추가'), findsOneWidget);
        expect(find.text('토큰 제거'), findsOneWidget);
        
        // 다이얼로그 닫기
        await tester.tap(find.text('닫기'));
        await tester.pumpAndSettle();
        
        print('✅ 개발자 메뉴 테스트 통과');
      } else {
        print('ℹ️ 개발자 메뉴가 숨겨져 있음 (릴리즈 모드)');
      }
    });

    testWidgets('토큰 관리 UI 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 토큰 관련 UI 요소들 확인
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
      
      // 프리미엄 기능 섹션 확인
      expect(find.text('프리미엄 기능'), findsOneWidget);
      expect(find.text('광고 보고 토큰 받기'), findsOneWidget);
      
      print('✅ 토큰 관리 UI 테스트 통과');
    });

    testWidgets('카메라 및 갤러리 버튼 존재 확인', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 카메라 버튼 확인
      final cameraButton = find.byIcon(Icons.photo_camera);
      expect(cameraButton, findsOneWidget);
      
      // 갤러리 버튼 확인
      final galleryButton = find.byIcon(Icons.photo_library);
      expect(galleryButton, findsOneWidget);

      // 실제 카메라/갤러리 접근은 테스트 환경에서 어려우므로 UI 존재만 확인
      print('✅ 카메라/갤러리 버튼 존재 확인 테스트 통과');
    });

    testWidgets('꽃 노트 섹션 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 꽃 노트 섹션 UI 확인
      expect(find.text('나의 꽃 노트'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      
      // 초기 상태에서는 "저장된 꽃이 없습니다" 메시지가 나타날 수 있음
      print('✅ 꽃 노트 섹션 테스트 통과');
    });

    testWidgets('스크롤 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 메인 화면에서 스크롤 테스트
      final scrollableFinder = find.byType(SingleChildScrollView);
      if (scrollableFinder.evaluate().isNotEmpty) {
        await tester.drag(scrollableFinder.first, const Offset(0, -300));
        await tester.pumpAndSettle();
        
        await tester.drag(scrollableFinder.first, const Offset(0, 300));
        await tester.pumpAndSettle();
      }
      
      print('✅ 스크롤 테스트 통과');
    });

    testWidgets('애니메이션 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // FadeTransition과 SlideTransition이 적용되어 있는지 확인
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
      
      print('✅ 애니메이션 UI 테스트 통과');
    });

    testWidgets('전체 앱 안정성 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 여러 번의 상호작용으로 앱의 안정성 확인
      for (int i = 0; i < 3; i++) {
        // 설정 화면 이동
        final settingsButton = find.byIcon(Icons.settings);
        if (settingsButton.evaluate().isNotEmpty) {
          await tester.tap(settingsButton);
          await tester.pumpAndSettle();
          
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        
        // 잠시 대기
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // 마지막에 앱이 여전히 정상 상태인지 확인
      expect(find.text('FloraSnap'), findsOneWidget);
      
      print('✅ 전체 앱 안정성 테스트 통과');
    });
  });
} 