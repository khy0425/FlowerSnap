import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'bounding_box.dart';
import 'detection_result.dart';

part 'analysis_result.g.dart';

/// 식물/동물 분석 결과 모델 (Hive + JSON 직렬화)
@JsonSerializable()
@HiveType(typeId: 1)
@immutable
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
  @deprecated
  List<BoundingBox> get boundingBoxes =>
      detectionResults.map((detection) => detection.boundingBox).toList();

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

  /// JSON 직렬화 팩토리
  factory AnalysisResult.fromJson(final Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  /// JSON 직렬화 메서드
  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  /// 범용 JSON으로부터 생성 (타입 안전성 강화)
  factory AnalysisResult.fromApiJson(
    final Map<String, dynamic> json,
    final String provider,
  ) {
    final String id =
        _getStringValue(json, 'id') ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final String name = _getStringValue(json, 'name') ?? '알 수 없는 생물';
    final String scientificName =
        _getStringValue(json, 'scientific_name') ??
        _getStringValue(json, 'scientificName') ??
        '';
    final double confidence =
        _getDoubleValue(json, 'confidence') ??
        _getDoubleValue(json, 'score') ??
        0.0;
    final String description = _getStringValue(json, 'description') ?? '';
    final List<String> alternativeNames =
        _getStringListValue(json, 'alternative_names') ??
        _getStringListValue(json, 'alternativeNames') ??
        <String>[];
    final String imageUrl =
        _getStringValue(json, 'image_url') ??
        _getStringValue(json, 'imageUrl') ??
        '';
    final Map<String, dynamic>? additionalInfo =
        _getMapValue(json, 'additional_info') ??
        _getMapValue(json, 'additionalInfo');

    return AnalysisResult(
      id: id,
      name: name,
      scientificName: scientificName,
      confidence: confidence,
      description: description,
      alternativeNames: alternativeNames,
      imageUrl: imageUrl,
      analyzedAt: DateTime.now(),
      apiProvider: provider,
      isPremiumResult: provider == 'plantid',
      category: _getCategoryFromProvider(provider),
      rarity: _calculateRarity(confidence),
      additionalInfo: additionalInfo,
    );
  }

  /// PlantNet API 응답으로부터 생성 (타입 안전성 강화)
  factory AnalysisResult.fromPlantNet(final Map<String, dynamic> json) {
    final Map<String, dynamic> species =
        _getMapValue(json, 'species') ?? <String, dynamic>{};
    final String scientificNameWithoutAuthor =
        _getStringValue(species, 'scientificNameWithoutAuthor') ?? '';
    final List<String> commonNames =
        _getStringListValue(species, 'commonNames') ?? <String>[];
    final double score = _getDoubleValue(json, 'score') ?? 0.0;
    final Map<String, dynamic> genus =
        _getMapValue(species, 'genus') ?? <String, dynamic>{};
    final String genusName =
        _getStringValue(genus, 'scientificNameWithoutAuthor') ?? '';

    return AnalysisResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: commonNames.isNotEmpty
          ? commonNames.first
          : scientificNameWithoutAuthor,
      scientificName: scientificNameWithoutAuthor,
      confidence: score,
      description: genusName.isNotEmpty ? '$genusName 속의 식물' : '식물',
      alternativeNames: commonNames,
      imageUrl: '',
      analyzedAt: DateTime.now(),
      apiProvider: 'plantnet',
      isPremiumResult: false,
      category: 'plant',
      rarity: _calculateRarity(score),
    );
  }

  /// Plant.id API 응답으로부터 생성 (타입 안전성 강화)
  factory AnalysisResult.fromPlantId(final Map<String, dynamic> json) {
    final List<dynamic> suggestions =
        json['suggestions'] as List<dynamic>? ?? <dynamic>[];
    if (suggestions.isEmpty) {
      throw Exception('식물이 아닙니다');
    }

    final Map<String, dynamic> suggestion =
        suggestions.first as Map<String, dynamic>;
    final Map<String, dynamic> plantDetails =
        _getMapValue(suggestion, 'plant_details') ?? <String, dynamic>{};
    final String plantName = _getStringValue(suggestion, 'plant_name') ?? '';
    final double probability =
        _getDoubleValue(suggestion, 'probability') ?? 0.0;
    final List<String> commonNames =
        _getStringListValue(plantDetails, 'common_names') ?? <String>[];
    final Map<String, dynamic> wikiDescription =
        _getMapValue(plantDetails, 'wiki_description') ?? <String, dynamic>{};
    final Map<String, dynamic> image =
        _getMapValue(plantDetails, 'image') ?? <String, dynamic>{};
    final Map<String, dynamic> wikiUrl =
        _getMapValue(plantDetails, 'wiki_url') ?? <String, dynamic>{};

    return AnalysisResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: commonNames.isNotEmpty ? commonNames.first : plantName,
      scientificName: plantName,
      confidence: probability,
      description: _getStringValue(wikiDescription, 'value') ?? '',
      alternativeNames: commonNames,
      imageUrl: _getStringValue(image, 'value') ?? '',
      analyzedAt: DateTime.now(),
      apiProvider: 'plantid',
      isPremiumResult: true,
      category: 'plant',
      rarity: _calculateRarity(probability),
      additionalInfo: <String, dynamic>{
        'wiki_url': _getStringValue(wikiUrl, 'value'),
        'gbif_id': _getStringValue(plantDetails, 'gbif_id'),
      },
    );
  }

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

  // === 타입 안전 헬퍼 메서드들 ===

  static String? _getStringValue(
    final Map<String, dynamic> map,
    final String key,
  ) {
    final dynamic value = map[key];
    return value is String ? value : null;
  }

  static double? _getDoubleValue(
    final Map<String, dynamic> map,
    final String key,
  ) {
    final dynamic value = map[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? _getStringListValue(
    final Map<String, dynamic> map,
    final String key,
  ) {
    final dynamic value = map[key];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
  }

  static Map<String, dynamic>? _getMapValue(
    final Map<String, dynamic> map,
    final String key,
  ) {
    final dynamic value = map[key];
    return value is Map<String, dynamic> ? value : null;
  }

  static String _getCategoryFromProvider(final String provider) {
    switch (provider) {
      case 'plantnet':
      case 'plantid':
        return 'plant';
      case 'inaturalist':
        return 'wildlife';
      default:
        return 'unknown';
    }
  }

  static int _calculateRarity(final double confidence) {
    if (confidence >= 0.9) return 5; // 매우 높은 신뢰도
    if (confidence >= 0.8) return 4;
    if (confidence >= 0.6) return 3;
    if (confidence >= 0.4) return 2;
    return 1; // 낮은 신뢰도
  }

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

  /// 유효한 식물인지 판별 (꽃뿐만 아니라 모든 식물 포함)
  bool get isFlower {
    // 1. 신뢰도가 낮으면 식물이 아닐 가능성이 높음
    if (confidence < 0.4) return false; // 기준을 더 관대하게
    
    // 2. 카테고리가 plant가 아니면 식물이 아님
    if (category != 'plant') return false;
    
    // 3. 비식물/비생물 키워드 검사 (더 강화된 필터링)
    final nonBiologicalKeywords = [
      // 음식 관련
      '초콜릿', '쿠키', '과자', '케이크', '빵', '음식', '먹을거리',
      'chocolate', 'cookie', 'cake', 'bread', 'food', 'snack',
      
      // 책/문서 관련  
      '책', '소설', '책자', '책갈피', '문서', '종이', '카드', '겉띠지',
      'book', 'novel', 'paper', 'document', 'card', 'cover',
      
      // 인공물/제품
      '제품', '상품', '포장', '플라스틱', '금속', '도구', '기계',
      '장난감', '인형', '그림', '그래픽', '로고', '텍스트',
      'product', 'plastic', 'metal', 'toy', 'tool', 'machine',
      'graphic', 'logo', 'text', 'artificial', 'synthetic',
      
      // 건물/구조물
      '건물', '집', '벽', '바닥', '천장', '문', '창문',
      'building', 'house', 'wall', 'floor', 'ceiling', 'door', 'window',
      
      // 의류/액세서리
      '옷', '의류', '신발', '가방', '모자', '안경',
      'clothes', 'clothing', 'shoes', 'bag', 'hat', 'glasses',
    ];
    
    final searchText = '$name $scientificName $description ${alternativeNames.join(' ')}'.toLowerCase();
    
    // 비생물 키워드가 있으면 무조건 false
    for (final keyword in nonBiologicalKeywords) {
      if (searchText.contains(keyword.toLowerCase())) {
        return false;
      }
    }
    
    // 4. 식물 관련 키워드 검사 (꽃뿐만 아니라 모든 식물 포함)
    final plantKeywords = [
      // 꽃 관련 키워드
      '꽃', '화', '블룸', '봉오리', '꽃봉오리', '개화', '화관', '꽃잎', '화판',
      '꽃받침', '수술', '암술', '화서', '꽃송이', '만개',
      'flower', 'bloom', 'blossom', 'petal', 'corolla', 'inflorescence',
      'flowering', 'blooming', 'floral', 'floret', 'stamen', 'pistil',
      'sepal', 'calyx', 'anther', 'stigma',
      
      // 식물의 다른 부분들 (이제 유효한 식물로 인정)
      '잎', '줄기', '가지', '뿌리', '나무', '수피', '나무껍질', '새싹',
      '덩굴', '넝쿨', '가시', '열매', '씨앗', '꼬투리',
      'leaf', 'leaves', 'stem', 'branch', 'root', 'bark', 'trunk',
      'twig', 'shoot', 'sprout', 'vine', 'thorn', 'fruit', 'seed',
      'foliage', 'wood', 'timber',
      
      // 식물 종류
      '나무', '관목', '풀', '잔디', '허브', '야채', '채소',
      'tree', 'shrub', 'bush', 'grass', 'herb', 'vegetable',
      
      // 특정 식물들
      '장미', '국화', '튤립', '백합', '해바라기', '코스모스', '민들레',
      '소나무', '참나무', '단풍나무', '버드나무', '은행나무',
      'rose', 'chrysanthemum', 'tulip', 'lily', 'sunflower', 'cosmos',
      'dandelion', 'pine', 'oak', 'maple', 'willow',
      
      // 학명/분류 패턴
      'flora', '-anthus', '-antha', 'flor-', '-phyte', '-dendron',
      'plantae', 'spermatophyta', 'angiosperm', 'gymnosperm',
    ];
    
    // 식물 키워드가 있는지 확인
    bool hasPlantKeyword = false;
    for (final keyword in plantKeywords) {
      if (searchText.contains(keyword.toLowerCase())) {
        hasPlantKeyword = true;
        break;
      }
    }
    
    // 5. 버섯/균류는 별도 처리 (식물은 아니지만 자연 생물)
    final fungusKeywords = ['버섯', 'mushroom', 'fungus', 'fungi'];
    bool isFungus = false;
    for (final keyword in fungusKeywords) {
      if (searchText.contains(keyword.toLowerCase())) {
        isFungus = true;
        break;
      }
    }
    
    // 6. 최종 판단: 식물 키워드가 있거나 버섯이면서 적절한 신뢰도를 가져야 함
    if (hasPlantKeyword) {
      return confidence >= 0.5; // 식물 키워드가 있으면 더 관대한 기준
    } else if (isFungus) {
      return confidence >= 0.6; // 버섯은 약간 더 엄격
    }
    
    // 기본적으로 카테고리가 plant이고 신뢰도가 높으면 식물일 가능성
    return confidence >= 0.7;
  }
  
  /// 식물이 아닌 이유 설명
  String get notFlowerReason {
    if (confidence < 0.4) {
      return '식물이 아닙니다. (AI 분석 신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)';
    }
    
    if (category != 'plant') {
      return '식물이 아닙니다. (식물 외의 카테고리로 분류됨)';
    }
    
    final searchText = '$name $scientificName $description ${alternativeNames.join(' ')}'.toLowerCase();
    
    // 비생물 키워드 체크
    final nonBiologicalKeywords = [
      '초콜릿', '쿠키', '과자', '케이크', '빵', '음식',
      'chocolate', 'cookie', 'cake', 'bread', 'food', 'snack',
      '책', '소설', '책자', '문서', '종이', '카드', '겉띠지',
      'book', 'novel', 'paper', 'document', 'card', 'cover',
      '제품', '상품', '포장', '플라스틱', '금속', '도구',
      'product', 'plastic', 'metal', 'toy', 'tool', 'artificial',
    ];
    
    for (final keyword in nonBiologicalKeywords) {
      if (searchText.contains(keyword.toLowerCase())) {
        switch (keyword) {
          case '초콜릿':
          case 'chocolate':
            return '식물이 아닙니다. (초콜릿이나 과자류로 인식됨)';
          case '책':
          case '소설':
          case 'book':
          case 'novel':
            return '식물이 아닙니다. (책이나 문서로 인식됨)';
          case '제품':
          case 'product':
            return '식물이 아닙니다. (인공 제품으로 인식됨)';
          default:
            return '식물이 아닙니다. (생물이 아닌 물체로 인식됨)';
        }
      }
    }
    
    if (confidence < 0.7) {
      return '식물이 아닙니다. (AI 분석 신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)';
    }
    
    return '식물이 아닙니다. (식물의 특징이 명확하지 않음)';
  }

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
