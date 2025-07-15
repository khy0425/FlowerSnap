import '../analysis_result.dart';

/// API 응답을 AnalysisResult로 파싱하는 클래스
class AnalysisResultParser {
  /// 일반 API JSON에서 AnalysisResult 생성
  static AnalysisResult fromApiJson(
    final Map<String, dynamic> json,
    final String provider,
  ) {
    final String id = _getStringValue(json, 'id') ?? 
                     DateTime.now().millisecondsSinceEpoch.toString();
    final String name = _getStringValue(json, 'name') ?? '알 수 없는 생물';
    final String scientificName = _getStringValue(json, 'scientific_name') ?? 
                                 _getStringValue(json, 'scientificName') ?? '';
    final double confidence = _getDoubleValue(json, 'confidence') ?? 
                             _getDoubleValue(json, 'score') ?? 0.0;
    final String description = _getStringValue(json, 'description') ?? '';
    final List<String> alternativeNames = 
        _getStringListValue(json, 'alternative_names') ?? 
        _getStringListValue(json, 'alternativeNames') ?? 
        <String>[];
    final String imageUrl = _getStringValue(json, 'image_url') ?? 
                           _getStringValue(json, 'imageUrl') ?? '';
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

  /// PlantNet API 응답에서 AnalysisResult 생성
  static AnalysisResult fromPlantNet(final Map<String, dynamic> json) {
    final List<dynamic> results = json['results'] as List<dynamic>? ?? <dynamic>[];
    if (results.isEmpty) {
      throw Exception('식물이 아닙니다');
    }

    final Map<String, dynamic> firstResult = results.first as Map<String, dynamic>;
    final Map<String, dynamic> species = _getMapValue(firstResult, 'species') ?? <String, dynamic>{};
    final String scientificName = _getStringValue(species, 'scientificNameWithoutAuthor') ?? 
                                 _getStringValue(species, 'scientificName') ?? '';
    final double score = _getDoubleValue(firstResult, 'score') ?? 0.0;
    final List<dynamic> commonNames = _getListValue(species, 'commonNames') ?? <dynamic>[];
    final List<String> alternativeNames = commonNames
        .map((final dynamic name) => _getStringValue(name as Map<String, dynamic>, 'name'))
        .where((final String? name) => name != null)
        .cast<String>()
        .toList();

    return AnalysisResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: alternativeNames.isNotEmpty ? alternativeNames.first : scientificName,
      scientificName: scientificName,
      confidence: score,
      description: '$scientificName에 대한 분석 결과입니다.',
      alternativeNames: alternativeNames,
      imageUrl: '',
      analyzedAt: DateTime.now(),
      apiProvider: 'plantnet',
      isPremiumResult: false,
      category: 'plant',
      rarity: _calculateRarity(score),
    );
  }

  /// PlantID API 응답에서 AnalysisResult 생성  
  static AnalysisResult fromPlantId(final Map<String, dynamic> json) {
    final List<dynamic> suggestions = json['suggestions'] as List<dynamic>? ?? <dynamic>[];
    if (suggestions.isEmpty) {
      throw Exception('식물이 아닙니다');
    }

    final Map<String, dynamic> suggestion = suggestions.first as Map<String, dynamic>;
    final Map<String, dynamic> plantDetails = _getMapValue(suggestion, 'plant_details') ?? <String, dynamic>{};
    final String plantName = _getStringValue(suggestion, 'plant_name') ?? '';
    final double probability = _getDoubleValue(suggestion, 'probability') ?? 0.0;
    final List<String> commonNames = _getStringListValue(plantDetails, 'common_names') ?? <String>[];
    final Map<String, dynamic> wikiDescription = _getMapValue(plantDetails, 'wiki_description') ?? <String, dynamic>{};
    final Map<String, dynamic> image = _getMapValue(plantDetails, 'image') ?? <String, dynamic>{};
    final Map<String, dynamic> wikiUrl = _getMapValue(plantDetails, 'wiki_url') ?? <String, dynamic>{};

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

  // === 타입 안전 헬퍼 메서드들 ===

  static String? _getStringValue(final Map<String, dynamic> map, final String key) {
    final dynamic value = map[key];
    return value is String ? value : null;
  }

  static double? _getDoubleValue(final Map<String, dynamic> map, final String key) {
    final dynamic value = map[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? _getStringListValue(final Map<String, dynamic> map, final String key) {
    final dynamic value = map[key];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
  }

  static Map<String, dynamic>? _getMapValue(final Map<String, dynamic> map, final String key) {
    final dynamic value = map[key];
    return value is Map<String, dynamic> ? value : null;
  }

  static List<dynamic>? _getListValue(final Map<String, dynamic> map, final String key) {
    final dynamic value = map[key];
    return value is List ? value : null;
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
} 