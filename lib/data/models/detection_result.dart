import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'bounding_box.dart';

part 'detection_result.g.dart';

/// 객체 감지 결과 (BoundingBox + 신뢰도 + 레이블)
@JsonSerializable()
@HiveType(typeId: 3)
@immutable
// ignore: must_be_immutable
class DetectionResult extends HiveObject {
  /// 경계 상자 정보
  @JsonKey(name: 'bounding_box')
  @HiveField(0)
  final BoundingBox boundingBox;

  /// 감지 신뢰도 (0.0 ~ 1.0)
  @JsonKey(name: 'confidence')
  @HiveField(1)
  final double confidence;

  /// 감지된 객체 레이블
  @JsonKey(name: 'label')
  @HiveField(2)
  final String label;

  DetectionResult({
    required this.boundingBox,
    required this.confidence,
    required this.label,
  });

  /// JSON에서 DetectionResult 생성
  factory DetectionResult.fromJson(final Map<String, dynamic> json) =>
      _$DetectionResultFromJson(json);

  /// 레거시 형식(x, y, width, height, confidence, label)에서 생성
  factory DetectionResult.fromLegacyJson(final Map<String, dynamic> json) =>
      DetectionResult(
        boundingBox: BoundingBox(
          left: (json['x'] as num?)?.toDouble() ?? 0.0,
          top: (json['y'] as num?)?.toDouble() ?? 0.0,
          width: (json['width'] as num?)?.toDouble() ?? 0.0,
          height: (json['height'] as num?)?.toDouble() ?? 0.0,
        ),
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        label: json['label'] as String? ?? '',
      );

  /// DetectionResult를 JSON으로 변환
  Map<String, dynamic> toJson() => _$DetectionResultToJson(this);

  /// 레거시 형식으로 변환 (하위 호환성)
  Map<String, dynamic> toLegacyJson() => {
        'x': boundingBox.left,
        'y': boundingBox.top,
        'width': boundingBox.width,
        'height': boundingBox.height,
        'confidence': confidence,
        'label': label,
      };

  /// 편의 메서드들 (BoundingBox 속성 접근)
  double get left => boundingBox.left;
  double get top => boundingBox.top;
  double get width => boundingBox.width;
  double get height => boundingBox.height;
  double get right => boundingBox.right;
  double get bottom => boundingBox.bottom;
  double get centerX => boundingBox.centerX;
  double get centerY => boundingBox.centerY;
  double get area => boundingBox.area;
  bool get isValid => boundingBox.isValid && confidence >= 0.0 && confidence <= 1.0;

  /// 레거시 호환 속성들 (deprecated이지만 기존 코드 호환성을 위해)
  @Deprecated('Use boundingBox.left instead. Will be removed in v2.0.0')
  double get x => boundingBox.left;
  @Deprecated('Use boundingBox.top instead. Will be removed in v2.0.0')
  double get y => boundingBox.top;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is DetectionResult &&
          runtimeType == other.runtimeType &&
          boundingBox == other.boundingBox &&
          confidence == other.confidence &&
          label == other.label;

  @override
  int get hashCode => Object.hash(boundingBox, confidence, label);

  @override
  String toString() =>
      'DetectionResult(box: $boundingBox, confidence: $confidence, label: $label)';
} 