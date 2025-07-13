import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// 이미지 내 객체의 경계 상자 정보
@immutable
class BoundingBox {
  /// 좌측 상단 X 좌표 (0.0 ~ 1.0)
  final double left;
  
  /// 좌측 상단 Y 좌표 (0.0 ~ 1.0)
  final double top;
  
  /// 너비 (0.0 ~ 1.0)
  final double width;
  
  /// 높이 (0.0 ~ 1.0)
  final double height;

  const BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// JSON에서 BoundingBox 생성
  factory BoundingBox.fromJson(final Map<String, dynamic> json) => BoundingBox(
    left: (json['left'] as num?)?.toDouble() ?? 0.0,
    top: (json['top'] as num?)?.toDouble() ?? 0.0,
    width: (json['width'] as num?)?.toDouble() ?? 0.0,
    height: (json['height'] as num?)?.toDouble() ?? 0.0,
  );

  /// BoundingBox를 JSON으로 변환
  Map<String, dynamic> toJson() => {
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  };

  /// 우측 하단 X 좌표 계산
  double get right => left + width;

  /// 우측 하단 Y 좌표 계산  
  double get bottom => top + height;

  /// 중심점 X 좌표
  double get centerX => left + width / 2;

  /// 중심점 Y 좌표
  double get centerY => top + height / 2;

  /// 경계 상자의 면적
  double get area => width * height;

  /// 경계 상자가 유효한지 확인
  bool get isValid => left >= 0 && top >= 0 && width > 0 && height > 0 && 
                     left + width <= 1.0 && top + height <= 1.0;

  /// 다른 경계 상자와의 교집합 계산
  BoundingBox? intersectionWith(final BoundingBox other) {
    final double intersectLeft = math.max(left, other.left);
    final double intersectTop = math.max(top, other.top);
    final double intersectRight = math.min(right, other.right);
    final double intersectBottom = math.min(bottom, other.bottom);

    if (intersectLeft < intersectRight && intersectTop < intersectBottom) {
      return BoundingBox(
        left: intersectLeft,
        top: intersectTop,
        width: intersectRight - intersectLeft,
        height: intersectBottom - intersectTop,
      );
    }
    return null;
  }

  @override
  bool operator ==(final Object other) => 
    identical(this, other) || 
    other is BoundingBox &&
    runtimeType == other.runtimeType &&
    left == other.left &&
    top == other.top &&
    width == other.width &&
    height == other.height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'BoundingBox(left: $left, top: $top, width: $width, height: $height)';

  /// 경계 상자를 특정 배율로 스케일링
  BoundingBox scale(final double scaleX, final double scaleY) => BoundingBox(
    left: left * scaleX,
    top: top * scaleY,
    width: width * scaleX,
    height: height * scaleY,
  );

  /// 경계 상자를 픽셀 좌표로 변환
  BoundingBox toPixelCoordinates(final double imageWidth, final double imageHeight) => BoundingBox(
    left: left * imageWidth,
    top: top * imageHeight,
    width: width * imageWidth,
    height: height * imageHeight,
  );
} 