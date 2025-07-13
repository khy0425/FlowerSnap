import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bounding_box.g.dart';

/// 바운딩 박스 정보를 나타내는 모델
@HiveType(typeId: 2)
@JsonSerializable()
class BoundingBox {
  /// 왼쪽 상단 X 좌표 (0.0 ~ 1.0, 이미지 너비 기준 비율)
  @HiveField(0)
  final double x;
  
  /// 왼쪽 상단 Y 좌표 (0.0 ~ 1.0, 이미지 높이 기준 비율)
  @HiveField(1)
  final double y;
  
  /// 너비 (0.0 ~ 1.0, 이미지 너비 기준 비율)
  @HiveField(2)
  final double width;
  
  /// 높이 (0.0 ~ 1.0, 이미지 높이 기준 비율)
  @HiveField(3)
  final double height;
  
  /// 신뢰도 (0.0 ~ 1.0)
  @HiveField(4)
  final double confidence;
  
  /// 감지된 객체의 라벨
  @HiveField(5)
  final String label;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.label,
  });

  /// JSON에서 BoundingBox 생성
  factory BoundingBox.fromJson(final Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      label: json['label'] as String,
    );
  }

  /// BoundingBox를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'confidence': confidence,
      'label': label,
    };
  }

  /// 유효성 검증
  bool get isValid =>
      x >= 0.0 && x <= 1.0 &&
      y >= 0.0 && y <= 1.0 &&
      width >= 0.0 && width <= 1.0 &&
      height >= 0.0 && height <= 1.0 &&
      x + width <= 1.0 &&
      y + height <= 1.0 &&
      confidence >= 0.0 && confidence <= 1.0;

  @override
  String toString() => 'BoundingBox(x: $x, y: $y, width: $width, height: $height, confidence: $confidence, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoundingBox &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          confidence == other.confidence &&
          label == other.label;

  @override
  int get hashCode =>
      x.hashCode ^
      y.hashCode ^
      width.hashCode ^
      height.hashCode ^
      confidence.hashCode ^
      label.hashCode;
} 