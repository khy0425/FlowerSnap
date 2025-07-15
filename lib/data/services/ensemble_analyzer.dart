import '../models/analysis_result.dart';

/// 앙상블 분석기 - 다중 API 결과를 통합하는 역할
class EnsembleAnalyzer {
  /// 생성자 (의존성 주입)
  EnsembleAnalyzer();
  
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
    final bestResult = verifiedResults.first;
    
    // 신뢰도 가중 평균 계산
    double totalWeight = 0;
    double weightedConfidence = 0;
    
    for (final result in verifiedResults) {
      final weight = result.confidence;
      totalWeight += weight;
      weightedConfidence += result.confidence * weight;
    }
    
    final averageConfidence = weightedConfidence / totalWeight;
    
    // 대안명 통합
    final allAlternatives = <String>{};
    for (final result in verifiedResults) {
      allAlternatives.addAll(result.alternativeNames);
    }
    
    return bestResult.copyWith(
      confidence: averageConfidence,
      alternativeNames: allAlternatives.toList(),
    );
  }
  
  /// 결과 유효성 검증
  bool _isValidResult(final AnalysisResult result) => result.confidence > 0.3 && result.isValid;
} 