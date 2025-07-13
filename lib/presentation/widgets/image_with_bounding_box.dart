import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/theme/senior_theme.dart';
import '../../data/models/bounding_box.dart';
import '../../data/models/detection_result.dart';

/// 이미지 위에 바운딩 박스를 그리는 위젯
class ImageWithBoundingBox extends StatelessWidget {
  final File imageFile;
  final List<DetectionResult> detectionResults;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImageWithBoundingBox({
    super.key,
    required this.imageFile,
    required this.detectionResults,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(final BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
      child: Stack(
        children: [
          // 기본 이미지
          Image.file(
            imageFile,
            width: width,
            height: height,
            fit: fit,
          ),
          
          // 바운딩 박스 오버레이
          if (boundingBoxes.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: BoundingBoxPainter(
                  boundingBoxes: boundingBoxes,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 바운딩 박스를 그리는 CustomPainter
class BoundingBoxPainter extends CustomPainter {
  final List<BoundingBox> boundingBoxes;

  BoundingBoxPainter({
    required this.boundingBoxes,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    for (final box in boundingBoxes) {
      if (!box.isValid) continue;

      // 바운딩 박스 좌표 계산 (비율로 이미지 크기에 맞춤)
      final left = box.x * size.width;
      final top = box.y * size.height;
      final right = (box.x + box.width) * size.width;
      final bottom = (box.y + box.height) * size.height;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      // 바운딩 박스 색상 설정
      final paint = Paint()
        ..color = _getBoxColor(box.confidence)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // 바운딩 박스 그리기
      canvas.drawRect(rect, paint);

      // 라벨과 신뢰도 텍스트 배경
      final labelText = '${box.label} ${(box.confidence * 100).toInt()}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // 텍스트 배경 그리기
      final textBackground = Rect.fromLTWH(
        left,
        top - textPainter.height - 8,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final backgroundPaint = Paint()
        ..color = _getBoxColor(box.confidence).withValues(alpha: 0.8);

      canvas.drawRect(textBackground, backgroundPaint);

      // 텍스트 그리기
      textPainter.paint(
        canvas,
        Offset(left + 4, top - textPainter.height - 6),
      );
    }
  }

  /// 신뢰도에 따른 바운딩 박스 색상 결정
  Color _getBoxColor(final double confidence) {
    if (confidence >= 0.8) {
      return SeniorTheme.successColor; // 높은 신뢰도 - 녹색
    } else if (confidence >= 0.6) {
      return SeniorTheme.warningColor; // 중간 신뢰도 - 오렌지
    } else {
      return SeniorTheme.errorColor; // 낮은 신뢰도 - 빨간색
    }
  }

  @override
  bool shouldRepaint(final BoundingBoxPainter oldDelegate) {
    return boundingBoxes != oldDelegate.boundingBoxes;
  }
}

/// 바운딩 박스와 함께 분석 결과를 보여주는 카드 위젯
class FlowerDetectionCard extends StatelessWidget {
  final File imageFile;
  final List<BoundingBox> boundingBoxes;
  final String title;

  const FlowerDetectionCard({
    super.key,
    required this.imageFile,
    required this.boundingBoxes,
    this.title = '객체 감지 결과',
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: SeniorTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.center_focus_strong,
                    color: SeniorTheme.accentColor,
                    size: SeniorConstants.iconSizeMedium,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SeniorTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 바운딩 박스가 있는 이미지
            Center(
              child: ImageWithBoundingBox(
                imageFile: imageFile,
                boundingBoxes: boundingBoxes,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(height: SeniorConstants.spacing),
            
            // 감지 통계
            if (boundingBoxes.isNotEmpty) ...[
              Text(
                '감지된 객체 ${boundingBoxes.length}개',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SeniorTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: SeniorConstants.spacingSmall),
              ...boundingBoxes.map((box) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getBoxColor(box.confidence),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${box.label} (${(box.confidence * 100).toInt()}%)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )),
            ] else ...[
              Text(
                '감지된 꽃이 없습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SeniorTheme.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 신뢰도에 따른 색상 (카드용)
  Color _getBoxColor(final double confidence) {
    if (confidence >= 0.8) {
      return SeniorTheme.successColor;
    } else if (confidence >= 0.6) {
      return SeniorTheme.warningColor;
    } else {
      return SeniorTheme.errorColor;
    }
  }
} 
