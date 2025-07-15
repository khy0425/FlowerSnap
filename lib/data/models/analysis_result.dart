import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'bounding_box.dart';
import 'detection_result.dart';
import 'parsers/analysis_result_parser.dart';
import 'validators/plant_validator.dart';

part 'analysis_result.g.dart';

/// 식물/동물 분석 결과 모델 (Hive + JSON 직렬화)
@JsonSerializable()
@HiveType(typeId: 1)
@immutable
// ignore: must_be_immutable
class AnalysisResult extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final String id;

  @JsonKey(name: 'name')
  @HiveField(1)
  final String name;

  @JsonKey(name: 'scientific_name')
  @HiveField(2)
  final String scientificName;

  @JsonKey(name: 'confidence')
  @HiveField(3)
  final double confidence;

  @JsonKey(name: 'description')
  @HiveField(4)
  final String description;

  @JsonKey(name: 'alternative_names')
  @HiveField(5)
  final List<String> alternativeNames;

  @JsonKey(name: 'image_url')
  @HiveField(6)
  final String imageUrl;

  @JsonKey(name: 'analyzed_at')
  @HiveField(7)
  final DateTime analyzedAt;

  @JsonKey(name: 'api_provider')
  @HiveField(8)
  final String apiProvider; // 'plantnet', 'inaturalist', 'plantid'

  @JsonKey(name: 'is_premium_result')
  @HiveField(9)
  final bool isPremiumResult;

  @JsonKey(name: 'category')
  @HiveField(10)
  final String category; // 'plant', 'animal', 'flower', etc.

  @JsonKey(name: 'rarity')
  @HiveField(11)
  final int rarity; // 1-5 희귀도

  @JsonKey(name: 'additional_info')
  @HiveField(12)
  final Map<String, dynamic>? additionalInfo;

  /// 객체 감지 결과 (꽃의 위치, 신뢰도, 레이블)
  @JsonKey(name: 'detection_results')
  @HiveField(13)
  final List<DetectionResult> detectionResults;

  /// 이전 버전 호환성을 위한 boundingBoxes 접근자
  @Deprecated('Use detectionResults instead. Will be removed in v2.0.0')
  List<BoundingBox> get boundingBoxes =>
      detectionResults.map((final detection) => detection.boundingBox).toList();

  /// 일반적인 생성자
  AnalysisResult({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.description,
    required this.alternativeNames,
    required this.imageUrl,
    required this.analyzedAt,
    required this.apiProvider,
    required this.isPremiumResult,
    required this.category,
    this.rarity = 1,
    this.additionalInfo,
    this.detectionResults = const <DetectionResult>[],
  });

  /// JSON 직렬화
  factory AnalysisResult.fromJson(final Map<String, dynamic> json) => _$AnalysisResultFromJson(json);

  /// JSON 역직렬화
  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  /// 테스트/목업용 생성자
  factory AnalysisResult.createMock({
    required final String name,
    required final String scientificName,
    required final double confidence,
    required final String apiProvider,
    required final String category,
    final String? description,
    final List<String>? alternativeNames,
    final String? imageUrl,
    final DateTime? analyzedAt,
    final bool isPremiumResult = false,
    final int? rarity,
    final Map<String, dynamic>? additionalInfo,
    final List<DetectionResult>? detectionResults,
  }) => AnalysisResult(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      scientificName: scientificName,
      confidence: confidence,
      description: description ?? '$name에 대한 분석 결과입니다.',
      alternativeNames: alternativeNames ?? <String>[],
      imageUrl: imageUrl ?? '',
      analyzedAt: analyzedAt ?? DateTime.now(),
      apiProvider: apiProvider,
      isPremiumResult: isPremiumResult,
      category: category,
      rarity: rarity ?? 1,
      additionalInfo: additionalInfo,
      detectionResults: detectionResults ?? <DetectionResult>[],
    );

  /// API JSON에서 AnalysisResult 생성 (위임)
  factory AnalysisResult.fromApiJson(
    final Map<String, dynamic> json,
    final String provider,
  ) => AnalysisResultParser.fromApiJson(json, provider);

  /// PlantNet API 응답에서 AnalysisResult 생성 (위임)
  factory AnalysisResult.fromPlantNet(final Map<String, dynamic> json) =>
      AnalysisResultParser.fromPlantNet(json);

  /// PlantID API 응답에서 AnalysisResult 생성 (위임)
  factory AnalysisResult.fromPlantId(final Map<String, dynamic> json) =>
      AnalysisResultParser.fromPlantId(json);

  /// copyWith 메서드 (불변성 유지)
  AnalysisResult copyWith({
    final String? id,
    final String? name,
    final String? scientificName,
    final double? confidence,
    final String? description,
    final List<String>? alternativeNames,
    final String? imageUrl,
    final DateTime? analyzedAt,
    final String? apiProvider,
    final bool? isPremiumResult,
    final String? category,
    final int? rarity,
    final Map<String, dynamic>? additionalInfo,
  }) => AnalysisResult(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      imageUrl: imageUrl ?? this.imageUrl,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      apiProvider: apiProvider ?? this.apiProvider,
      isPremiumResult: isPremiumResult ?? this.isPremiumResult,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );

  // === 계산된 속성들 ===

  /// UI 표시용 신뢰도 텍스트
  String get confidenceText {
    if (confidence >= 0.9) return '매우 높음';
    if (confidence >= 0.8) return '높음';
    if (confidence >= 0.6) return '보통';
    if (confidence >= 0.4) return '낮음';
    return '매우 낮음';
  }

  /// UI 표시용 API 제공자 텍스트
  String get providerDisplayName {
    switch (apiProvider) {
      case 'plantnet':
        return 'PlantNet (무료)';
      case 'plantid':
        return 'Plant.id (프리미엄)';
      case 'inaturalist':
        return 'iNaturalist (무료)';
      default:
        return '알 수 없음';
    }
  }

  /// 유효한 식물인지 판별 (PlantValidator로 위임)
  bool get isFlower => PlantValidator.isPlant(
      name: name,
      scientificName: scientificName,
      description: description,
      alternativeNames: alternativeNames,
      confidence: confidence,
      category: category,
    );

  /// 식물이 아닌 이유 설명 (PlantValidator로 위임)
  String get notFlowerReason => PlantValidator.getNotPlantReason(
      name: name,
      scientificName: scientificName,
      description: description,
      alternativeNames: alternativeNames,
      confidence: confidence,
      category: category,
    );

  /// 유효성 검증
  bool get isValid => name.isNotEmpty && confidence >= 0.0 && confidence <= 1.0;

  @override
  String toString() =>
      'AnalysisResult(id: $id, name: $name, confidence: $confidence, provider: $apiProvider)';

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is AnalysisResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
