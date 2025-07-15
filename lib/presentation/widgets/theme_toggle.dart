import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/senior_theme.dart';

/// 🌙 다크모드 전환 위젯
class ThemeToggle extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggle;
  final bool showLabel;
  final String lightModeLabel;
  final String darkModeLabel;

  const ThemeToggle({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
    this.showLabel = true,
    this.lightModeLabel = "밝은 테마",
    this.darkModeLabel = "어두운 테마",
  });

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _toggleController;
  late AnimationController _iconController;
  late Animation<double> _toggleAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    
    _toggleController = AnimationController(
      duration: SeniorConstants.animationDuration,
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _toggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _toggleController, curve: Curves.easeInOut),
    );
    
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    
    if (widget.isDarkMode) {
      _toggleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(final ThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDarkMode != oldWidget.isDarkMode) {
      if (widget.isDarkMode) {
        _toggleController.forward();
      } else {
        _toggleController.reverse();
      }
      _iconController.forward().then((_) => _iconController.reverse());
    }
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onToggle() {
    HapticFeedback.lightImpact();
    widget.onToggle(!widget.isDarkMode);
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_toggleAnimation, _iconAnimation]),
    builder: (final BuildContext context, final Widget? child) => GestureDetector(
      onTap: _onToggle,
      child: Container(
        padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
        decoration: BoxDecoration(
          color: widget.isDarkMode 
              ? const Color(0xFF2E2E2E) 
              : SeniorTheme.surfaceColor,
          borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
          border: Border.all(
            color: widget.isDarkMode 
                ? Colors.white.withValues(alpha: 0.2)
                : SeniorTheme.borderColor,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: SeniorTheme.cardElevationColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 토글 스위치
            Container(
              width: 60,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDarkMode
                      ? const [
                          Color(0xFF4A90E2),
                          Color(0xFF357ABD),
                        ]
                      : const [
                          SeniorTheme.tokenColor,
                          SeniorTheme.secondaryColor,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: SeniorConstants.animationDuration,
                    curve: Curves.easeInOut,
                    left: widget.isDarkMode ? 28 : 4,
                    top: 4,
                    child: Transform.scale(
                      scale: 1.0 + (_iconAnimation.value * 0.2),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
                          size: 16,
                          color: widget.isDarkMode 
                              ? const Color(0xFF4A90E2) 
                              : SeniorTheme.tokenColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (widget.showLabel) ...[
              const SizedBox(width: SeniorConstants.spacing),
              
              // 라벨 텍스트
              Text(
                widget.isDarkMode ? widget.darkModeLabel : widget.lightModeLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: widget.isDarkMode ? Colors.white : SeniorTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// 🎨 접근성 테마 설정 패널
class AccessibilityThemePanel extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final bool highContrast;
  final ValueChanged<bool> onDarkModeToggle;
  final ValueChanged<double> onFontSizeChange;
  final ValueChanged<bool> onHighContrastToggle;

  const AccessibilityThemePanel({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.highContrast,
    required this.onDarkModeToggle,
    required this.onFontSizeChange,
    required this.onHighContrastToggle,
  });

  @override
  State<AccessibilityThemePanel> createState() => _AccessibilityThemePanelState();
}

class _AccessibilityThemePanelState extends State<AccessibilityThemePanel> {
  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
    decoration: SeniorTheme.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            const Icon(
              Icons.accessibility,
              color: SeniorTheme.primaryColor,
              size: SeniorConstants.iconSizeLarge,
            ),
            const SizedBox(width: SeniorConstants.spacing),
            Text(
              "접근성 설정",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: SeniorTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: SeniorConstants.spacingLarge),
        
        // 다크모드 토글
        _buildSettingItem(
          icon: Icons.dark_mode,
          title: "어두운 테마",
          subtitle: "눈의 피로를 줄여줍니다",
          child: ThemeToggle(
            isDarkMode: widget.isDarkMode,
            onToggle: widget.onDarkModeToggle,
            showLabel: false,
          ),
        ),
        
        const SizedBox(height: SeniorConstants.spacingLarge),
        
        // 폰트 크기 조절
        _buildSettingItem(
          icon: Icons.text_fields,
          title: "글자 크기",
          subtitle: "읽기 편한 크기로 조절하세요",
          child: Column(
            children: [
              Slider(
                value: widget.fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 6,
                activeColor: SeniorTheme.primaryColor,
                inactiveColor: SeniorTheme.primaryColor.withValues(alpha: 0.3),
                onChanged: (final double value) {
                  HapticFeedback.selectionClick();
                  widget.onFontSizeChange(value);
                },
              ),
              Text(
                "${widget.fontSize.round()}px",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: SeniorConstants.spacingLarge),
        
        // 고대비 모드
        _buildSettingItem(
          icon: Icons.contrast,
          title: "고대비 모드",
          subtitle: "색상 대비를 높여 선명하게 표시",
          child: Switch(
            value: widget.highContrast,
            onChanged: (final bool value) {
              HapticFeedback.lightImpact();
              widget.onHighContrastToggle(value);
            },
            activeColor: SeniorTheme.primaryColor,
            activeTrackColor: SeniorTheme.primaryColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );

  Widget _buildSettingItem({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final Widget child,
  }) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
        decoration: BoxDecoration(
          color: SeniorTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: SeniorTheme.primaryColor,
          size: SeniorConstants.iconSizeMedium,
        ),
      ),
      
      const SizedBox(width: SeniorConstants.spacing),
      
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SeniorTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(width: SeniorConstants.spacing),
      
      child,
    ],
  );
} 