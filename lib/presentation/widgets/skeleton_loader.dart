import 'package:flutter/material.dart';

import '../../core/theme/senior_theme.dart';

/// 🦴 스켈레톤 로딩 위젯
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final baseColor = widget.baseColor ?? SeniorTheme.backgroundColor;
    final highlightColor = widget.highlightColor ?? 
        SeniorTheme.primaryColor.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (final BuildContext context, final Widget? child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? 
              BorderRadius.circular(SeniorConstants.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(-1.0 + _animation.value, 0.0),
            end: Alignment(-0.5 + _animation.value, 0.0),
            colors: [
              baseColor,
              highlightColor,
              baseColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

/// 🦴 스켈레톤 텍스트 라인
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 16.0,
    this.lines = 1,
  });

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(lines, (final int index) {
      final lineWidth = width ?? 
          (index == lines - 1 ? 120.0 : double.infinity);
      
      return Padding(
        padding: EdgeInsets.only(
          bottom: index < lines - 1 ? SeniorConstants.spacingSmall : 0,
        ),
        child: SkeletonLoader(
          width: lineWidth,
          height: height,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }),
  );
}

/// 🦴 스켈레톤 카드
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final bool hasImage;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.hasImage = true,
  });

  @override
  Widget build(final BuildContext context) => Container(
    width: width,
    height: height,
    padding: const EdgeInsets.all(SeniorConstants.spacing),
    decoration: SeniorTheme.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.circular(SeniorConstants.borderRadius),
          ),
          const SizedBox(height: SeniorConstants.spacing),
        ],
        
        // 제목
        const SkeletonText(height: 20),
        const SizedBox(height: SeniorConstants.spacingSmall),
        
        // 설명
        const SkeletonText(height: 14, lines: 2),
        const SizedBox(height: SeniorConstants.spacing),
        
        // 버튼들
        Row(
          children: [
            SkeletonLoader(
              width: 80,
              height: 32,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(width: SeniorConstants.spacingSmall),
            SkeletonLoader(
              width: 60,
              height: 32,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
      ],
    ),
  );
}

/// 🦴 꽃 분석 결과 스켈레톤
class FlowerAnalysisSkeletonCard extends StatelessWidget {
  const FlowerAnalysisSkeletonCard({super.key});

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(SeniorConstants.spacing),
    decoration: SeniorTheme.cardDecoration,
    child: Row(
      children: [
        // 꽃 이미지
        SkeletonLoader(
          width: 60,
          height: 60,
          borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        ),
        
        const SizedBox(width: SeniorConstants.spacing),
        
        // 꽃 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 꽃 이름
              const SkeletonText(width: 120, height: 18),
              const SizedBox(height: SeniorConstants.spacingXSmall),
              
              // 학명
              const SkeletonText(width: 160, height: 14),
              const SizedBox(height: SeniorConstants.spacingXSmall),
              
              // 신뢰도
              SkeletonLoader(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 🦴 메인 카메라 섹션 스켈레톤
class MainCameraSectionSkeleton extends StatelessWidget {
  const MainCameraSectionSkeleton({super.key});

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
    decoration: SeniorTheme.cardDecoration,
    child: Column(
      children: [
        // 타이틀
        const SkeletonText(width: 200, height: 24),
        const SizedBox(height: SeniorConstants.spacing),
        
        // 설명
        const SkeletonText(lines: 2),
        const SizedBox(height: SeniorConstants.spacingLarge),
        
        // 카메라 버튼들
        Row(
          children: [
            Expanded(
              child: SkeletonLoader(
                height: 120,
                borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
              ),
            ),
            const SizedBox(width: SeniorConstants.spacing),
            Expanded(
              child: SkeletonLoader(
                height: 120,
                borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
              ),
            ),
          ],
        ),
      ],
    ),
  );
} 