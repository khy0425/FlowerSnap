import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/senior_theme.dart';

/// 🔄 시니어 친화적인 풀 투 리프레시 래퍼
class PullToRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String refreshText;
  final bool enableHaptic;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText = "새로고침하려면 아래로 당겨주세요",
    this.enableHaptic = true,
  });

  @override
  State<PullToRefreshWrapper> createState() => _PullToRefreshWrapperState();
}

class _PullToRefreshWrapperState extends State<PullToRefreshWrapper>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: SeniorConstants.animationDuration,
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }

    _refreshController.forward();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        await _refreshController.reverse();
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) => RefreshIndicator(
    onRefresh: _handleRefresh,
    backgroundColor: SeniorTheme.surfaceColor,
    color: SeniorTheme.primaryColor,
    strokeWidth: 3.0,
    displacement: 60.0,
    child: AnimatedBuilder(
      animation: _refreshAnimation,
      builder: (final BuildContext context, final Widget? child) => Transform.scale(
        scale: 1.0 - (_refreshAnimation.value * 0.02),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              _refreshAnimation.value * SeniorConstants.borderRadiusLarge,
            ),
          ),
          child: widget.child,
        ),
      ),
    ),
  );
}

/// 🔄 커스텀 리프레시 인디케이터
class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String refreshText;
  final String pullingText;
  final String refreshingText;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText = "새로고침",
    this.pullingText = "아래로 당겨서 새로고침",
    this.refreshingText = "새로고침 중...",
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pullController;
  late AnimationController _rotationController;
  late Animation<double> _pullAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPulling = false;
  bool _isRefreshing = false;
  double _pullDistance = 0.0;
  static const double _triggerDistance = 80.0;

  @override
  void initState() {
    super.initState();
    
    _pullController = AnimationController(
      duration: SeniorConstants.animationDurationFast,
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pullAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pullController, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pullController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onPullStart() {
    if (!_isRefreshing) {
      setState(() {
        _isPulling = true;
      });
      _pullController.forward();
    }
  }

  void _onPullUpdate(final double distance) {
    if (!_isRefreshing) {
      setState(() {
        _pullDistance = distance.clamp(0.0, _triggerDistance * 1.5);
      });
    }
  }

  Future<void> _onPullEnd() async {
    if (!_isRefreshing && _pullDistance >= _triggerDistance) {
      setState(() {
        _isRefreshing = true;
      });
      
      _rotationController.repeat();
      HapticFeedback.mediumImpact();
      
      try {
        await widget.onRefresh();
      } finally {
        if (mounted) {
          _rotationController.stop();
          await _pullController.reverse();
          setState(() {
            _isRefreshing = false;
            _isPulling = false;
            _pullDistance = 0.0;
          });
        }
      }
    } else {
      await _pullController.reverse();
      setState(() {
        _isPulling = false;
        _pullDistance = 0.0;
      });
    }
  }

  String get _statusText {
    if (_isRefreshing) return widget.refreshingText;
    if (_pullDistance >= _triggerDistance) return widget.refreshText;
    return widget.pullingText;
  }

  @override
  Widget build(final BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: (final ScrollNotification notification) {
      if (notification is ScrollStartNotification && 
          notification.metrics.pixels <= 0) {
        _onPullStart();
      } else if (notification is ScrollUpdateNotification && _isPulling) {
        _onPullUpdate(-notification.metrics.pixels);
      } else if (notification is ScrollEndNotification && _isPulling) {
        _onPullEnd();
      }
      return false;
    },
    child: Stack(
      children: [
        widget.child,
        
        // 커스텀 리프레시 헤더
        if (_isPulling || _isRefreshing)
          AnimatedBuilder(
            animation: _pullAnimation,
            builder: (final BuildContext context, final Widget? child) {
              final progress = (_pullDistance / _triggerDistance).clamp(0.0, 1.0);
              
              return Positioned(
                top: -80 + (80 * _pullAnimation.value * progress),
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: SeniorTheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SeniorTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (final BuildContext context, final Widget? child) => Transform.rotate(
                          angle: _isRefreshing 
                              ? _rotationAnimation.value * 2 * 3.14159
                              : progress * 3.14159,
                          child: Icon(
                            _isRefreshing ? Icons.refresh : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: SeniorConstants.iconSizeLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: SeniorConstants.spacingXSmall),
                      Text(
                        _statusText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
} 