import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_token.g.dart';

/// API 토큰 모델 (Hive + JSON 직렬화)
@JsonSerializable()
@HiveType(typeId: 0)
@immutable
class ApiToken extends HiveObject {
  @JsonKey(name: 'provider')
  @HiveField(0)
  final String provider; // 'plantid', 'openai', etc.

  @JsonKey(name: 'token')
  @HiveField(1)
  final String token;

  @JsonKey(name: 'added_at')
  @HiveField(2)
  final DateTime addedAt;

  @JsonKey(name: 'usage_count')
  @HiveField(3)
  final int usageCount;

  @JsonKey(name: 'usage_limit')
  @HiveField(4)
  final int? usageLimit; // null이면 무제한

  @JsonKey(name: 'is_active')
  @HiveField(5)
  final bool isActive;

  @JsonKey(name: 'expires_at')
  @HiveField(6)
  final DateTime? expiresAt;

  ApiToken({
    required this.provider,
    required this.token,
    required this.addedAt,
    this.usageCount = 0,
    this.usageLimit,
    this.isActive = true,
    this.expiresAt,
  });

  /// JSON 직렬화 팩토리
  factory ApiToken.fromJson(final Map<String, dynamic> json) =>
      _$ApiTokenFromJson(json);

  /// JSON 직렬화 메서드
  Map<String, dynamic> toJson() => _$ApiTokenToJson(this);

  /// copyWith 메서드 (불변성 유지)
  ApiToken copyWith({
    final String? provider,
    final String? token,
    final DateTime? addedAt,
    final int? usageCount,
    final int? usageLimit,
    final bool? isActive,
    final DateTime? expiresAt,
  }) => ApiToken(
    provider: provider ?? this.provider,
    token: token ?? this.token,
    addedAt: addedAt ?? this.addedAt,
    usageCount: usageCount ?? this.usageCount,
    usageLimit: usageLimit ?? this.usageLimit,
    isActive: isActive ?? this.isActive,
    expiresAt: expiresAt ?? this.expiresAt,
  );

  // === 계산된 속성들 ===

  /// 토큰이 사용 가능한지 확인
  bool get canUse {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    return true;
  }

  /// 남은 사용 횟수
  int? get remainingUsage {
    if (usageLimit == null) return null;
    return usageLimit! - usageCount;
  }

  /// 토큰 사용 후 카운트 증가
  ApiToken incrementUsage() => copyWith(usageCount: usageCount + 1);

  /// 토큰 마스킹 (UI 표시용)
  String get maskedToken {
    if (token.length <= 8) return token;
    return '${token.substring(0, 4)}****${token.substring(token.length - 4)}';
  }

  /// UI 표시용 제공자 이름
  String get providerDisplayName {
    switch (provider) {
      case 'plantid':
        return 'Plant.id (프리미엄)';
      case 'openai':
        return 'OpenAI (프리미엄)';
      default:
        return provider;
    }
  }

  /// 유효성 검증
  bool get isValid =>
      provider.isNotEmpty &&
      token.isNotEmpty &&
      usageCount >= 0 &&
      (usageLimit == null || usageLimit! >= 0);

  /// 만료 상태 확인
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// 사용량 초과 확인
  bool get isUsageLimitExceeded =>
      usageLimit != null && usageCount >= usageLimit!;

  @override
  String toString() =>
      'ApiToken(provider: $provider, masked: $maskedToken, canUse: $canUse)';

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ApiToken &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          token == other.token;

  @override
  int get hashCode => Object.hash(provider, token);
}
