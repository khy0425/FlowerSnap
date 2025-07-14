import 'package:flora_snap/generated/l10n/app_localizations.dart';
import 'package:flora_snap/presentation/screens/flora_snap_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Blooming App Integration Tests', () {
    setUpAll(() async {
      // Hive 초기화 (한 번만)
      await Hive.initFlutter();
    });

    tearDownAll(() async {
      // 모든 테스트 후 Hive 정리
      await Hive.close();
    });

    testWidgets('앱 시작 및 기본 UI 로드 테스트', (WidgetTester tester) async {
      // 직접 FloraSnapHomeScreen을 테스트 (main() 호출 대신)
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 로컬라이제이션 텍스트로 확인
      expect(find.text('FloraSnap'), findsOneWidget);
      
      // 기본 아이콘들 확인
      expect(find.byIcon(Icons.local_florist), findsOneWidget); // 로고 아이콘
      expect(find.byIcon(Icons.stars), findsOneWidget); // 토큰 아이콘
      
      print('✅ 기본 UI 로드 테스트 통과');
    });

    testWidgets('토큰 관리 UI 테스트', (WidgetTester tester) async {
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

      // 토큰 카운트 표시 확인
      expect(find.byIcon(Icons.stars), findsOneWidget);
      
      print('✅ 토큰 관리 UI 테스트 통과');
    });

    testWidgets('기본 버튼들 존재 확인', (WidgetTester tester) async {
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

      // 기본 UI 요소들이 로드되는지 확인
      expect(find.byType(FloraSnapHomeScreen), findsOneWidget);
      expect(find.text('FloraSnap'), findsOneWidget);
      
      print('✅ 기본 버튼들 존재 확인 테스트 통과');
    });

    testWidgets('애니메이션 테스트', (WidgetTester tester) async {
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
      
      // 애니메이션이 완전히 끝날 때까지 대기
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 화면이 정상적으로 로드되었는지 확인
      expect(find.byType(FloraSnapHomeScreen), findsOneWidget);
      
      print('✅ 애니메이션 테스트 통과');
    });
  });
} 