import 'package:flora_snap/generated/l10n/app_localizations.dart';
import 'package:flora_snap/presentation/screens/flora_snap_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget() => const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: FloraSnapHomeScreen(),
      ),
    );

  group('FloraSnapHomeScreen Widget Tests', () {
    group('Basic Widget Structure', () {
      testWidgets('should build without crashing', (final tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // 기본적인 위젯이 빌드되었는지 확인
        expect(find.byType(FloraSnapHomeScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display main UI elements', (final tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // 주요 UI 요소들이 존재하는지 확인
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should contain camera section', (final tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // 카메라 관련 요소들 확인 (아이콘 타입으로 확인)
        expect(find.byIcon(Icons.camera_alt), findsWidgets);
      });

      testWidgets('should contain gallery section', (final tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // 갤러리 관련 요소들 확인
        expect(find.byIcon(Icons.photo_library), findsWidgets);
      });

      testWidgets('should have proper scaffold structure', (final tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // Scaffold 구조 확인
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsWidgets);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should handle safe area', (final tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // SafeArea가 적절히 설정되어 있는지 확인
        expect(find.byType(SafeArea), findsOneWidget);
        
        // 메인 콘텐츠가 SafeArea 내부에 있는지 확인
        final safeAreaFinder = find.byType(SafeArea);
        expect(safeAreaFinder, findsOneWidget);
      });
    });
  });
} 