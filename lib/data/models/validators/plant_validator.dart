/// 식물 검증 로직을 담당하는 클래스
class PlantValidator {
  /// 비생물 키워드 목록
  static const List<String> _nonBiologicalKeywords = [
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

  /// 식물 키워드 목록
  static const List<String> _plantKeywords = [
    // 꽃 관련 키워드
    '꽃', '화', '블룸', '봉오리', '꽃봉오리', '개화', '화관', '꽃잎', '화판',
    '꽃받침', '수술', '암술', '화서', '꽃송이', '만개',
    'flower', 'bloom', 'blossom', 'petal', 'corolla', 'inflorescence',
    'flowering', 'blooming', 'floral', 'floret', 'stamen', 'pistil',
    'sepal', 'calyx', 'anther', 'stigma',
    
    // 식물의 다른 부분들
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

  /// 버섯/균류 키워드
  static const List<String> _fungusKeywords = [
    '버섯', 'mushroom', 'fungus', 'fungi',
  ];

  /// 식물인지 검증
  static bool isPlant({
    required final String name,
    required final String scientificName,
    required final String description,
    required final List<String> alternativeNames,
    required final double confidence,
    required final String category,
  }) {
    // 1. 신뢰도가 낮으면 식물이 아닐 가능성이 높음
    if (confidence < 0.4) return false;
    
    // 2. 카테고리가 plant가 아니면 식물이 아님
    if (category != 'plant') return false;
    
    final searchText = '$name $scientificName $description ${alternativeNames.join(' ')}'.toLowerCase();
    
    // 3. 비생물 키워드가 있으면 무조건 false
    if (_containsNonBiologicalKeywords(searchText)) return false;
    
    // 4. 식물 키워드 확인
    final hasPlantKeyword = _containsPlantKeywords(searchText);
    final isFungus = _containsFungusKeywords(searchText);
    
    // 5. 최종 판단
    if (hasPlantKeyword) {
      return confidence >= 0.5; // 식물 키워드가 있으면 더 관대한 기준
    } else if (isFungus) {
      return confidence >= 0.6; // 버섯은 약간 더 엄격
    }
    
    // 기본적으로 카테고리가 plant이고 신뢰도가 높으면 식물일 가능성
    return confidence >= 0.7;
  }

  /// 식물이 아닌 이유 설명
  static String getNotPlantReason({
    required final String name,
    required final String scientificName,
    required final String description,
    required final List<String> alternativeNames,
    required final double confidence,
    required final String category,
  }) {
    if (confidence < 0.4) {
      return '식물이 아닙니다. (AI 분석 신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)';
    }
    
    if (category != 'plant') {
      return '식물이 아닙니다. (식물 외의 카테고리로 분류됨)';
    }
    
    final searchText = '$name $scientificName $description ${alternativeNames.join(' ')}'.toLowerCase();
    
    // 비생물 키워드 체크
    for (final keyword in _nonBiologicalKeywords) {
      if (searchText.contains(keyword.toLowerCase())) {
        return _getSpecificNonBiologicalReason(keyword);
      }
    }
    
    if (confidence < 0.7) {
      return '식물이 아닙니다. (AI 분석 신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)';
    }
    
    return '식물이 아닙니다. (식물의 특징이 명확하지 않음)';
  }

  /// 비생물 키워드 포함 여부 확인
  static bool _containsNonBiologicalKeywords(final String searchText) =>
      _nonBiologicalKeywords.any((final keyword) => 
        searchText.contains(keyword.toLowerCase()));

  /// 식물 키워드 포함 여부 확인
  static bool _containsPlantKeywords(final String searchText) =>
      _plantKeywords.any((final keyword) => 
        searchText.contains(keyword.toLowerCase()));

  /// 버섯 키워드 포함 여부 확인
  static bool _containsFungusKeywords(final String searchText) =>
      _fungusKeywords.any((final keyword) => 
        searchText.contains(keyword.toLowerCase()));

  /// 특정 비생물 키워드에 대한 상세 이유 반환
  static String _getSpecificNonBiologicalReason(final String keyword) {
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