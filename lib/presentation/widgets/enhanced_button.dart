import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/senior_theme.dart';

/// 🌟 향상된 마이크로 인터랙션 버튼
class EnhancedButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool enableHaptic;
  final double? width;
  final double? height;

  const EnhancedButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.enableHaptic = true,
    this.width,
    this.height,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late Animation<double> _pressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 로딩 중일 때 펄스 애니메이션
    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(final EnhancedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(final TapDownDetails details) {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    _pressController.forward();
  }

  void _onTapUp(final TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _onTap() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_pressAnimation, _pulseAnimation]),
    builder: (final BuildContext context, final Widget? child) => Transform.scale(
      scale: _pressAnimation.value * _pulseAnimation.value,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: widget.onPressed != null ? _onTapCancel : null,
        onTap: widget.onPressed != null ? _onTap : null,
        child: AnimatedContainer(
          duration: SeniorConstants.animationDurationFast,
          width: widget.width,
          height: widget.height ?? SeniorConstants.buttonHeight,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(
                    colors: [
                      SeniorTheme.primaryColor,
                      SeniorTheme.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      SeniorTheme.secondaryColor.withValues(alpha: 0.1),
                      SeniorTheme.secondaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
            border: Border.all(
              color: widget.isPrimary
                  ? SeniorTheme.primaryColor
                  : SeniorTheme.secondaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: (widget.isPrimary 
                          ? SeniorTheme.primaryColor 
                          : SeniorTheme.secondaryColor).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
              splashColor: Colors.white.withValues(alpha: 0.3),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SeniorConstants.spacing,
                  vertical: SeniorConstants.spacingSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isPrimary ? Colors.white : SeniorTheme.primaryColor,
                          ),
                        ),
                      )
                    else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: SeniorConstants.iconSizeMedium,
                        color: widget.isPrimary ? Colors.white : SeniorTheme.primaryColor,
                      ),
                      const SizedBox(width: SeniorConstants.spacingSmall),
                    ],
                    
                    Text(
                      widget.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: widget.isPrimary ? Colors.white : SeniorTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
} 