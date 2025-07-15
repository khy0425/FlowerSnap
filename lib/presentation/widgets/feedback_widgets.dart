import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/senior_theme.dart';

/// 🎯 피드백 타입
enum FeedbackType {
  success,
  error,
  warning,
  info,
}

/// 🎯 성공/실패 피드백 위젯
class FeedbackWidget extends StatefulWidget {
  final FeedbackType type;
  final String message;
  final String? title;
  final IconData? customIcon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool autoHide;
  final Duration duration;
  final bool enableHaptic;

  const FeedbackWidget({
    super.key,
    required this.type,
    required this.message,
    this.title,
    this.customIcon,
    this.onAction,
    this.actionLabel,
    this.autoHide = false,
    this.duration = const Duration(seconds: 3),
    this.enableHaptic = true,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _iconController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: SeniorConstants.animationDuration,
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    
    _showFeedback();
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _showFeedback() async {
    if (widget.enableHaptic) {
      switch (widget.type) {
        case FeedbackType.success:
          HapticFeedback.heavyImpact();
        case FeedbackType.error:
          HapticFeedback.heavyImpact();
        case FeedbackType.warning:
          HapticFeedback.mediumImpact();
        case FeedbackType.info:
          HapticFeedback.lightImpact();
      }
    }
    
    await _controller.forward();
    await _iconController.forward();
    
    if (widget.autoHide) {
      await Future<void>.delayed(widget.duration);
      if (mounted) {
        await _hideFeedback();
      }
    }
  }

  Future<void> _hideFeedback() async {
    await _iconController.reverse();
    await _controller.reverse();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case FeedbackType.success:
        return SeniorTheme.successColor;
      case FeedbackType.error:
        return SeniorTheme.errorColor;
      case FeedbackType.warning:
        return SeniorTheme.warningColor;
      case FeedbackType.info:
        return SeniorTheme.infoColor;
    }
  }

  IconData get _icon {
    if (widget.customIcon != null) return widget.customIcon!;
    
    switch (widget.type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
    }
  }

  String get _defaultTitle {
    switch (widget.type) {
      case FeedbackType.success:
        return "성공!";
      case FeedbackType.error:
        return "오류가 발생했습니다";
      case FeedbackType.warning:
        return "주의하세요";
      case FeedbackType.info:
        return "알림";
    }
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_slideAnimation, _fadeAnimation, _iconAnimation]),
    builder: (final BuildContext context, final Widget? child) => Transform.translate(
      offset: Offset(0, _slideAnimation.value),
      child: Opacity(
        opacity: _fadeAnimation.value,
        child: Container(
          margin: const EdgeInsets.all(SeniorConstants.spacing),
          padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _backgroundColor,
                _backgroundColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: _backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // 아이콘
              Transform.scale(
                scale: _iconAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon,
                    color: Colors.white,
                    size: SeniorConstants.iconSizeLarge,
                  ),
                ),
              ),
              
              const SizedBox(width: SeniorConstants.spacing),
              
              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목
                    Text(
                      widget.title ?? _defaultTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (widget.message.isNotEmpty) ...[
                      const SizedBox(height: SeniorConstants.spacingXSmall),
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 액션 버튼
              if (widget.onAction != null && widget.actionLabel != null) ...[
                const SizedBox(width: SeniorConstants.spacing),
                ElevatedButton(
                  onPressed: widget.onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Text(widget.actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// 🎯 토스트 메시지
class CustomToast {
  static void show(
    final BuildContext context, {
    required final FeedbackType type,
    required final String message,
    final String? title,
    final IconData? icon,
    final VoidCallback? onAction,
    final String? actionLabel,
    final Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (final BuildContext context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FeedbackWidget(
            type: type,
            message: message,
            title: title,
            customIcon: icon,
            onAction: () {
              entry.remove();
              onAction?.call();
            },
            actionLabel: actionLabel,
            autoHide: true,
            duration: duration,
          ),
        ),
      ),
    );
    
    overlay.insert(entry);
    
    // 자동 제거
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  static void showSuccess(
    final BuildContext context, {
    required final String message,
    final String? title,
    final VoidCallback? onAction,
    final String? actionLabel,
  }) {
    show(
      context,
      type: FeedbackType.success,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showError(
    final BuildContext context, {
    required final String message,
    final String? title,
    final VoidCallback? onAction,
    final String? actionLabel,
  }) {
    show(
      context,
      type: FeedbackType.error,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showWarning(
    final BuildContext context, {
    required final String message,
    final String? title,
    final VoidCallback? onAction,
    final String? actionLabel,
  }) {
    show(
      context,
      type: FeedbackType.warning,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    final BuildContext context, {
    required final String message,
    final String? title,
    final VoidCallback? onAction,
    final String? actionLabel,
  }) {
    show(
      context,
      type: FeedbackType.info,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}

/// 🎯 결과 카드 위젯
class ResultCard extends StatelessWidget {
  final FeedbackType type;
  final String title;
  final String message;
  final List<Widget>? actions;
  final Widget? child;

  const ResultCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.actions,
    this.child,
  });

  Color get _backgroundColor {
    switch (type) {
      case FeedbackType.success:
        return SeniorTheme.successColor.withValues(alpha: 0.1);
      case FeedbackType.error:
        return SeniorTheme.errorColor.withValues(alpha: 0.1);
      case FeedbackType.warning:
        return SeniorTheme.warningColor.withValues(alpha: 0.1);
      case FeedbackType.info:
        return SeniorTheme.infoColor.withValues(alpha: 0.1);
    }
  }

  Color get _borderColor {
    switch (type) {
      case FeedbackType.success:
        return SeniorTheme.successColor;
      case FeedbackType.error:
        return SeniorTheme.errorColor;
      case FeedbackType.warning:
        return SeniorTheme.warningColor;
      case FeedbackType.info:
        return SeniorTheme.infoColor;
    }
  }

  IconData get _icon {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
    decoration: BoxDecoration(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
      border: Border.all(color: _borderColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _icon,
          color: _borderColor,
          size: SeniorConstants.iconSizeMedium,
        ),
        const SizedBox(width: SeniorConstants.spacingSmall),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: SeniorTheme.textPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
} 