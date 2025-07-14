import 'package:flora_snap/data/services/analysis_token_service.dart';
import 'package:flora_snap/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('토큰 관리 시스템 통합 테스트', () {
    late AnalysisTokenService tokenService;

    setUp(() {
      tokenService = AnalysisTokenService();
    });

    testWidgets('토큰 서비스 초기화 및 기본 동작', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 토큰 카운트 표시 확인
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
      
      // 토큰 서비스 기본 기능 테스트
      final initialTokens = await tokenService.getTokenCount();
      expect(initialTokens, isA<int>());
      expect(initialTokens, greaterThanOrEqualTo(0));
      
      print('✅ 토큰 서비스 초기화 테스트 통과 - 초기 토큰: $initialTokens');
    });

    testWidgets('개발자 메뉴를 통한 토큰 관리 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 개발자 메뉴 버튼 찾기
      final devMenuButton = find.byIcon(Icons.developer_mode);
      
      if (devMenuButton.evaluate().isNotEmpty) {
        // 현재 토큰 수 기록
        final initialTokens = await tokenService.getTokenCount();
        
        // 개발자 메뉴 열기
        await tester.tap(devMenuButton);
        await tester.pumpAndSettle();

        // 토큰 추가 버튼 테스트
        final addTokenButton = find.text('토큰 추가');
        if (addTokenButton.evaluate().isNotEmpty) {
          await tester.tap(addTokenButton);
          await tester.pumpAndSettle();
          
          // 토큰이 추가되었는지 확인
          final newTokens = await tokenService.getTokenCount();
          expect(newTokens, greaterThan(initialTokens));
          
          print('✅ 토큰 추가 테스트 통과 - $initialTokens → $newTokens');
        }

        // 다이얼로그 닫기
        final closeButton = find.text('닫기');
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      } else {
        print('ℹ️ 개발자 메뉴를 사용할 수 없음 (릴리즈 모드)');
      }
    });

    testWidgets('프리미엄 기능 UI 상호작용 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 프리미엄 기능 섹션 찾기
      expect(find.text('프리미엄 기능'), findsOneWidget);
      
      // 광고 보기 버튼 확인
      final rewardAdButton = find.text('광고 보고 토큰 받기');
      expect(rewardAdButton, findsOneWidget);
      
      // 버튼 탭 테스트 (실제 광고는 실행되지 않지만 UI 반응 확인)
      await tester.tap(rewardAdButton);
      await tester.pumpAndSettle();
      
      // 테스트 모드에서는 토큰 다이얼로그가 나타날 수 있음
      final testTokenDialog = find.text('테스트 토큰 받기');
      if (testTokenDialog.evaluate().isNotEmpty) {
        // 토큰 받기 버튼 클릭
        await tester.tap(find.text('토큰 받기'));
        await tester.pumpAndSettle();
        
        print('✅ 테스트 모드 토큰 받기 성공');
      }
      
      print('✅ 프리미엄 기능 UI 테스트 통과');
    });

    testWidgets('토큰 소비 시뮬레이션 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 현재 토큰 수 확인
      final initialTokens = await tokenService.getTokenCount();
      
      if (initialTokens > 0) {
        // 토큰 사용 시뮬레이션 (실제 분석 대신 서비스 메서드 직접 호출)
        final success = await tokenService.useToken();
        expect(success, isTrue);
        
        // 토큰이 감소했는지 확인
        final newTokens = await tokenService.getTokenCount();
        expect(newTokens, equals(initialTokens - 1));
        
        print('✅ 토큰 소비 테스트 통과 - $initialTokens → $newTokens');
      } else {
        print('ℹ️ 토큰이 없어서 소비 테스트를 건너뜀');
      }
    });

    testWidgets('토큰 표시 UI 업데이트 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 토큰 아이콘 확인
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
      
      // 토큰 카운트 텍스트 찾기 (숫자가 표시된 위젯)
      final tokenCountWidgets = find.byWidgetPredicate(
        (widget) => widget is Text && 
                   widget.data != null && 
                   RegExp(r'^\d+$').hasMatch(widget.data!),
      );
      
      if (tokenCountWidgets.evaluate().isNotEmpty) {
        print('✅ 토큰 카운트 UI 표시 확인');
      }
      
      print('✅ 토큰 표시 UI 테스트 통과');
    });

    testWidgets('토큰 부족 상황 처리 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 모든 토큰을 소모하여 0으로 만들기
      while (await tokenService.getTokenCount() > 0) {
        await tokenService.useToken();
      }
      
      // 토큰이 0인 상태에서 추가 사용 시도
      final success = await tokenService.useToken();
      expect(success, isFalse);
      
      // 여전히 토큰이 0인지 확인
      final finalTokens = await tokenService.getTokenCount();
      expect(finalTokens, equals(0));
      
      print('✅ 토큰 부족 상황 처리 테스트 통과');
    });

    testWidgets('토큰 서비스 안정성 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 여러 번의 토큰 연산으로 안정성 확인
      for (int i = 0; i < 5; i++) {
        await tokenService.addTokens(1);
        final count1 = await tokenService.getTokenCount();
        
        await tokenService.useToken();
        final count2 = await tokenService.getTokenCount();
        
        expect(count2, equals(count1 - 1));
      }
      
      print('✅ 토큰 서비스 안정성 테스트 통과');
    });
  });
} 