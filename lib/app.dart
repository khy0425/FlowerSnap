import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/senior_theme.dart';
import 'generated/l10n/app_localizations.dart';
import 'presentation/screens/home_screen.dart';

class FloraSnapApp extends ConsumerWidget {
  const FloraSnapApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => MaterialApp(
    title: 'FloraSnap',
    debugShowCheckedModeBanner: false,
    theme: SeniorTheme.theme,
    darkTheme: SeniorTheme.darkTheme,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('ko', ''), // 한국어
      Locale('en', ''), // 영어
      Locale('ja', ''), // 일본어
    ],
    home: const HomeScreen(),
  );
}
