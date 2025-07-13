import 'package:flutter/material.dart';

/// 시니어 사용자를 위한 테마 설정
class SeniorTheme {
  // 색상 팔레트 (높은 대비, 부드러운 색감)
  static const Color primaryColor = Color(0xFF2E7D32); // 진한 녹색
  static const Color secondaryColor = Color(0xFFFFB74D); // 따뜻한 오렌지
  static const Color accentColor = Color(0xFF4CAF50); // 밝은 녹색
  static const Color backgroundColor = Color(0xFFF5F5F5); // 연한 회색
  static const Color surfaceColor = Color(0xFFFFFFFF); // 순백색
  static const Color textPrimaryColor = Color(0xFF212121); // 진한 검정
  static const Color textSecondaryColor = Color(0xFF757575); // 회색
  static const Color errorColor = Color(0xFFD32F2F); // 빨간색
  static const Color successColor = Color(0xFF388E3C); // 녹색
  static const Color warningColor = Color(0xFFF57C00); // 오렌지
  static const Color infoColor = Color(0xFF1976D2); // 파란색
  
  // 추가 색상들
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color cardElevationColor = Color(0x0A000000);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFBDBDBD);
  static const Color hintColor = Color(0xFF9E9E9E);
  
  // 특별한 색상들
  static const Color premiumColor = Color(0xFF8E24AA); // 보라색
  static const Color tokenColor = Color(0xFFFFC107); // 노란색
  static const Color confidenceHighColor = Color(0xFF4CAF50); // 녹색
  static const Color confidenceMediumColor = Color(0xFFFF9800); // 오렌지
  static const Color confidenceLowColor = Color(0xFFF44336); // 빨간색

  /// 시니어 테마 데이터
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    
    // 폰트 크기 - 시니어용으로 크게 설정
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        letterSpacing: -0.25,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        letterSpacing: -0.25,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        letterSpacing: -0.15,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        letterSpacing: -0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        letterSpacing: -0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        letterSpacing: -0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
        letterSpacing: 0.4,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
        letterSpacing: 0.5,
      ),
    ),
    
    // 버튼 테마 - 크고 누르기 쉽게
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 56), // 큰 버튼 크기
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: cardElevationColor,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    
    // 카드 테마 - 일관된 스타일
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: cardElevationColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      surfaceTintColor: surfaceColor,
      color: cardBackgroundColor,
    ),
    
    // 앱바 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 4,
      shadowColor: cardElevationColor,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.25,
      ),
    ),
    
    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        fontSize: 16,
        color: textSecondaryColor,
      ),
      hintStyle: const TextStyle(
        fontSize: 16,
        color: hintColor,
      ),
      filled: true,
      fillColor: surfaceColor,
    ),
    
    // 스낵바 테마
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ),
    
    // 아이콘 테마
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 28,
    ),
    
    // 디바이더 테마
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    
    // 칩 테마
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      disabledColor: disabledColor,
      selectedColor: primaryColor,
      secondarySelectedColor: secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  /// 다크 테마 (시니어용 - 높은 대비)
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF4CAF50), // 밝은 녹색
      secondary: const Color(0xFFFFCC02), // 밝은 노란색
      surface: const Color(0xFF1E1E1E), // 진한 회색
      error: const Color(0xFFEF5350), // 밝은 빨간색
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    // 나머지 설정은 라이트 테마와 동일
  );
  
  /// 그라데이션 배경
  static BoxDecoration get gradientBackground => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        backgroundColor,
        backgroundColor.withValues(alpha: 0.8),
      ],
    ),
  );
  
  /// 카드 그림자
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: cardElevationColor,
        blurRadius: 12,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
    ],
  );
  
  /// 특별한 카드 (프리미엄 등)
  static BoxDecoration specialCardDecoration(final Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: color.withValues(alpha: 0.3),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.1),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ],
  );
  
  /// 신뢰도 색상 가져오기
  static Color getConfidenceColor(final double confidence) {
    if (confidence >= 0.8) return confidenceHighColor;
    if (confidence >= 0.6) return confidenceMediumColor;
    return confidenceLowColor;
  }
  
  /// 신뢰도 아이콘 가져오기
  static IconData getConfidenceIcon(final double confidence) {
    if (confidence >= 0.8) return Icons.verified;
    if (confidence >= 0.6) return Icons.check_circle_outline;
    return Icons.help_outline;
  }
}

/// 시니어 친화적인 상수들
class SeniorConstants {
  // 버튼 크기
  static const double buttonHeight = 56.0;
  static const double buttonMinWidth = 120.0;
  static const double buttonPadding = 24.0;
  
  // 간격
  static const double spacing = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingSmall = 8.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXSmall = 4.0;
  
  // 글씨 크기
  static const double fontSizeHuge = 28.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeSmall = 16.0;
  
  // 모서리 둥글기
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusSmall = 8.0;
  
  // 그림자
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  
  // 아이콘 크기
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // 컨테이너 크기
  static const double containerMinHeight = 56.0;
  static const double cardImageHeight = 200.0;
  static const double cardImageHeightLarge = 300.0;
  
  // 애니메이션 지속시간
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
} 