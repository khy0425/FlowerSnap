import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/senior_theme.dart';
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
  Widget build(final BuildContext context) => ClipRRect(
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
          if (detectionResults.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: BoundingBoxPainter(
                  detectionResults: detectionResults,
                ),
              ),
            ),
        ],
      ),
    );
}

/// 바운딩 박스를 그리는 CustomPainter
class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detectionResults;

  BoundingBoxPainter({
    required this.detectionResults,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    for (final detection in detectionResults) {
      final box = detection.boundingBox;
      if (!box.isValid) continue;

      // 바운딩 박스 좌표 계산 (비율로 이미지 크기에 맞춤)
      final left = box.left * size.width;
      final top = box.top * size.height;
      final right = (box.left + box.width) * size.width;
      final bottom = (box.top + box.height) * size.height;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      // 바운딩 박스 색상 설정
      final paint = Paint()
        ..color = _getBoxColor(detection.confidence)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // 바운딩 박스 그리기
      canvas.drawRect(rect, paint);

      // 라벨과 신뢰도 텍스트 배경
      final labelText = '${detection.label} ${(detection.confidence * 100).toInt()}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();

      // 텍스트 배경 위치 계산
      final textX = left;
      final textY = top - textPainter.height - 5;
      
      // 텍스트 배경 그리기
      final backgroundRect = Rect.fromLTWH(
        textX,
        textY,
        textPainter.width + 8,
        textPainter.height + 4,
      );
      
      final backgroundPaint = Paint()
        ..color = _getBoxColor(detection.confidence).withValues(alpha: 0.8);
      
      canvas.drawRect(backgroundRect, backgroundPaint);
      
      // 텍스트 그리기
      textPainter.paint(canvas, Offset(textX + 4, textY + 2));
    }
  }

  @override
  bool shouldRepaint(final BoundingBoxPainter oldDelegate) => detectionResults != oldDelegate.detectionResults;

  /// 신뢰도에 따른 바운딩 박스 색상 결정
  Color _getBoxColor(final double confidence) =>
      confidence >= 0.8 ? Colors.green :
      confidence >= 0.6 ? Colors.orange :
      Colors.red;
}

/// 이미지에 바운딩 박스를 표시하는 전체 화면 위젯
class FullScreenImageWithBoundingBox extends StatelessWidget {
  final File imageFile;
  final List<DetectionResult> detectionResults;

  const FullScreenImageWithBoundingBox({
    super.key,
    required this.imageFile,
    required this.detectionResults,
  });

  @override
  Widget build(final BuildContext context) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: ImageWithBoundingBox(
            imageFile: imageFile,
            detectionResults: detectionResults,
          ),
        ),
      ),
    );

  /// 전체화면으로 이미지 보기
  static void show(final BuildContext context, final File imageFile, final List<DetectionResult> detectionResults) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (final context) => FullScreenImageWithBoundingBox(
          imageFile: imageFile,
          detectionResults: detectionResults,
        ),
      ),
    );
  }
}

/// 바운딩 박스 상세 정보 위젯
class BoundingBoxInfo extends StatelessWidget {
  final DetectionResult detection;

  const BoundingBoxInfo({
    super.key,
    required this.detection,
  });

  @override
  Widget build(final BuildContext context) => Container(
      padding: const EdgeInsets.all(SeniorConstants.spacing),
      decoration: BoxDecoration(
        color: SeniorTheme.surfaceColor,
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(color: SeniorTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.label,
                color: SeniorTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: SeniorConstants.spacingSmall),
              Text(
                detection.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: SeniorTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: SeniorConstants.spacingSmall),
          Row(
            children: [
              const Icon(
                Icons.precision_manufacturing,
                color: SeniorTheme.textSecondaryColor,
                size: 16,
              ),
              const SizedBox(width: SeniorConstants.spacingSmall),
              Text(
                '신뢰도: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SeniorTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
} 
