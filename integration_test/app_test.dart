import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flora_snap/generated/l10n/app_localizations.dart';
import 'package:flora_snap/presentation/screens/flora_snap_home_screen.dart';

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

    testWidgets('앱 시작 및 기본 UI 로드 테스트', (final WidgetTester tester) async {
      // 직접 FloraSnapHomeScreen을 테스트 (main() 호출 대신)
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

      // UI 로딩 대기
      await tester.pumpAndSettle();
      
      // 기본 요소들이 화면에 표시되는지 확인
      expect(find.text('꽃 이름을 알아보세요'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      
      // 로그 출력 (테스트 환경에서는 필요할 수 있음)
      debugPrint('✅ 앱 시작 및 기본 UI 로드 테스트 통과');
    });

    testWidgets('카메라 버튼 탭 테스트', (final WidgetTester tester) async {
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

      // 카메라 버튼 탭
      final cameraButton = find.byIcon(Icons.camera_alt);
      expect(cameraButton, findsOneWidget);
      
      await tester.tap(cameraButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 카메라 관련 동작이 실행되었는지 확인 (실제 카메라는 테스트 환경에서 사용 불가)
      // 여기서는 버튼이 정상적으로 탭되는지만 확인
      debugPrint('✅ 카메라 버튼 탭 테스트 통과');
    });

    testWidgets('갤러리 버튼 탭 테스트', (final WidgetTester tester) async {
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

      // 갤러리 버튼 탭
      final galleryButton = find.byIcon(Icons.photo_library);
      expect(galleryButton, findsOneWidget);
      
      await tester.tap(galleryButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 갤러리 관련 동작이 실행되었는지 확인 (실제 갤러리는 테스트 환경에서 사용 불가)
      debugPrint('✅ 갤러리 버튼 탭 테스트 통과');
    });

    testWidgets('설정 화면 네비게이션 테스트', (final WidgetTester tester) async {
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

      // 설정 버튼 찾기 및 탭
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // 설정 화면으로 이동했는지 확인
      expect(find.text('설정'), findsOneWidget);
      
      debugPrint('✅ 설정 화면 네비게이션 테스트 통과');
    });
  });
} 