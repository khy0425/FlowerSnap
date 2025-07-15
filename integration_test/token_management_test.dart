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

  group('Token Management Integration Tests', () {
    late AnalysisTokenService tokenService;

    setUpAll(() async {
      // Hive 초기화
      await Hive.initFlutter();
      tokenService = AnalysisTokenService();
    });

    tearDownAll(() async {
      // 테스트 후 정리
      await Hive.close();
    });

    setUp(() async {
      // 각 테스트 전에 토큰 초기화
      await tokenService.resetTokens();
    });

    testWidgets('토큰 초기 상태 확인 테스트', (final WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ko', ''),
              Locale('en', ''),
              Locale('ja', ''),
            ],
            home: FloraSnapHomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 초기 토큰 개수 확인 (기본값: 10개)
      final initialTokenCount = await tokenService.getTokenCount();
      expect(initialTokenCount, equals(10));

      // 토큰 아이콘이 화면에 표시되는지 확인
      expect(find.byIcon(Icons.stars), findsOneWidget);

      debugPrint('✅ 토큰 초기 상태 확인 테스트 통과 - 초기 토큰: $initialTokenCount개');
    });

    testWidgets('토큰 사용 테스트', (final WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ko', ''),
              Locale('en', ''),
              Locale('ja', ''),
            ],
            home: FloraSnapHomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 토큰 사용 전 개수 확인
      final initialCount = await tokenService.getTokenCount();

      // 토큰 1개 사용
      final success = await tokenService.useToken();
      expect(success, isTrue);

      // 토큰 사용 후 개수 확인
      final afterUseCount = await tokenService.getTokenCount();
      expect(afterUseCount, equals(initialCount - 1));

      debugPrint(
        '✅ 토큰 사용 테스트 통과 - 사용 전: $initialCount개, 사용 후: $afterUseCount개',
      );
    });

    testWidgets('토큰 추가 테스트', (final WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ko', ''),
              Locale('en', ''),
              Locale('ja', ''),
            ],
            home: FloraSnapHomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 토큰 추가 전 개수 확인
      final initialCount = await tokenService.getTokenCount();

      // 토큰 5개 추가
      await tokenService.addTokens(5);

      // 잠시 대기
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 토큰 추가 후 개수 확인
      final afterAddCount = await tokenService.getTokenCount();
      expect(afterAddCount, equals(initialCount + 5));

      debugPrint(
        '✅ 토큰 추가 테스트 통과 - 추가 전: $initialCount개, 추가 후: $afterAddCount개',
      );
    });
  });
}
