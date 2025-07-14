import 'package:flora_snap/data/services/analysis_token_service.dart';
import 'package:flora_snap/generated/l10n/app_localizations.dart';
import 'package:flora_snap/presentation/screens/flora_snap_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('토큰 관리 시스템 통합 테스트', () {
    late AnalysisTokenService tokenService;

    setUpAll(() async {
      // Hive 초기화 (한 번만)
      await Hive.initFlutter();
    });

    setUp(() {
      tokenService = AnalysisTokenService();
    });

    tearDownAll(() async {
      // 모든 테스트 후 Hive 정리
      await Hive.close();
    });

    testWidgets('토큰 서비스 초기화 및 기본 동작', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FloraSnapHomeScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 토큰 카운트 표시 확인 (올바른 아이콘 사용)
      expect(find.byIcon(Icons.stars), findsOneWidget);
      
      // 토큰 서비스 기본 기능 테스트
      final initialTokens = await tokenService.getTokenCount();
      expect(initialTokens, isA<int>());
      expect(initialTokens, greaterThanOrEqualTo(0));
      
      print('✅ 토큰 서비스 초기화 테스트 통과');
    });

    testWidgets('토큰 관리 UI 기본 동작', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FloraSnapHomeScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 기본 UI 요소들 확인
      expect(find.text('FloraSnap'), findsOneWidget);
      expect(find.byIcon(Icons.stars), findsOneWidget); // 토큰 아이콘
      expect(find.byIcon(Icons.local_florist), findsOneWidget); // 로고
      
      print('✅ 토큰 관리 UI 기본 동작 테스트 통과');
    });

    testWidgets('토큰 서비스 안정성 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FloraSnapHomeScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 여러 번 토큰 카운트 호출해도 안정적인지 확인
      for (int i = 0; i < 3; i++) {
        final tokenCount = await tokenService.getTokenCount();
        expect(tokenCount, isA<int>());
        expect(tokenCount, greaterThanOrEqualTo(0));
        
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      print('✅ 토큰 서비스 안정성 테스트 통과');
    });
  });
} 