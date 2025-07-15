import 'package:logger/logger.dart';

import '../models/analysis_result.dart';

/// 앙상블 분석기 - 다중 API 결과를 통합하는 역할
class EnsembleAnalyzer {
  final Logger _logger;
  
  /// 생성자 (의존성 주입)
  EnsembleAnalyzer({final Logger? logger}) : _logger = logger ?? Logger();
  
  /// 앙상블 결과 생성
  AnalysisResult createEnsembleResult(final List<AnalysisResult> validResults) {
    if (validResults.length == 1) {
      return validResults.first;
    }
    
    // 검증된 결과만 사용
    final verifiedResults = validResults.where(_isValidResult).toList();
    
    if (verifiedResults.isEmpty) {
      return validResults.first; // 최소한 하나는 반환
    }
    
    // 신뢰도 순으로 정렬
    verifiedResults.sort((final a, final b) => b.confidence.compareTo(a.confidence));
    
    return _buildEnsembleResult(verifiedResults);
  }
  
  /// 앙상블 결과 구성
  AnalysisResult _buildEnsembleResult(final List<AnalysisResult> verifiedResults) {
    final ensembleBuilder = EnsembleResultBuilder(verifiedResults);
    
    return AnalysisResult(
      id: 'ensemble_${DateTime.now().millisecondsSinceEpoch}',
      name: ensembleBuilder.selectBestName(),
      scientificName: ensembleBuilder.selectBestScientificName(),
      confidence: ensembleBuilder.calculateWeightedConfidence(),
      description: ensembleBuilder.generateCombinedDescription(),
      alternativeNames: ensembleBuilder.combineAlternativeNames(),
      imageUrl: verifiedResults.first.imageUrl,
      analyzedAt: DateTime.now(),
      apiProvider: 'ensemble_${verifiedResults.map((final r) => r.apiProvider).join('+')}',
      isPremiumResult: verifiedResults.any((final r) => r.isPremiumResult),
      category: verifiedResults.first.category,
      rarity: ensembleBuilder.calculateAverageRarity(),
      additionalInfo: ensembleBuilder.buildAdditionalInfo(),
      detectionResults: verifiedResults.first.detectionResults,
    );
  }
  
  /// 결과의 유효성 검증
  bool _isValidResult(final AnalysisResult result) {
    return result.confidence > 0.5 && result.name.isNotEmpty;
  }
}

/// 앙상블 결과 생성을 위한 도우미 클래스
class EnsembleResultBuilder {
  final List<AnalysisResult> _results;
  
  EnsembleResultBuilder(this._results);
  
  /// 가장 적합한 이름 선택
  String selectBestName() {
    final highestConfidence = _results.first;
    return highestConfidence.name;
  }
  
  /// 가장 적합한 학명 선택
  String selectBestScientificName() {
    final highestConfidence = _results.first;
    return highestConfidence.scientificName;
  }
  
  /// 가중 신뢰도 계산
  double calculateWeightedConfidence() {
    double totalWeight = 0;
    double weightedSum = 0;
    
    for (final result in _results) {
      final weight = _getApiWeight(result.apiProvider);
      totalWeight += weight;
      weightedSum += result.confidence * weight;
    }
    
    return totalWeight > 0 ? weightedSum / totalWeight : 0;
  }
  
  /// API별 가중치 계산
  double _getApiWeight(final String apiProvider) {
    switch (apiProvider) {
      case 'plantid':
        return 0.4;
      case 'plantnet':
        return 0.3;
      case 'google_vision':
        return 0.3;
      default:
        return 0.2;
    }
  }
  
  /// 결합된 설명 생성
  String generateCombinedDescription() {
    final descriptions = _results
        .map((final r) => r.description)
        .where((final d) => d.isNotEmpty)
        .toList();
    
    if (descriptions.isEmpty) {
      return '다중 API 분석을 통해 식물을 식별했습니다.';
    }
    
    return descriptions.first;
  }
  
  /// 대체 이름들 결합
  List<String> combineAlternativeNames() {
    final allNames = <String>{};
    
    for (final result in _results) {
      allNames.addAll(result.alternativeNames);
    }
    
    return allNames.toList();
  }
  
  /// 평균 희귀도 계산
  int calculateAverageRarity() {
    final rarities = _results.map((final r) => r.rarity).toList();
    if (rarities.isEmpty) return 1;
    
    final sum = rarities.reduce((final a, final b) => a + b);
    return (sum / rarities.length).round();
  }
  
  /// 추가 정보 구성
  Map<String, dynamic> buildAdditionalInfo() {
    final info = <String, dynamic>{};
    
    info['ensemble_sources'] = _results.map((final r) => r.apiProvider).toList();
    info['individual_confidences'] = _results.map((final r) => r.confidence).toList();
    info['analysis_method'] = 'ensemble';
    
    return info;
  }
} 