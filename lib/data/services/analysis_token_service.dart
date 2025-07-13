import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// 분석권 관리 서비스
/// 리워드 광고 시청으로 획득한 분석권을 로컬에 저장하고 관리
class AnalysisTokenService {
  static const String _tokenCountKey = 'analysis_token_count';
  static const String _lastRewardAdDateKey = 'last_reward_ad_date';
  static const int _dailyRewardAdLimit = 5; // 하루 최대 리워드 광고 시청 횟수
  
  final Logger _logger = Logger();
  
  /// 현재 보유한 분석권 개수 조회
  Future<int> getTokenCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_tokenCountKey) ?? 0;
      _logger.i('현재 분석권 개수: $count');
      return count;
    } catch (e) {
      _logger.e('분석권 개수 조회 실패: $e');
      return 0;
    }
  }
  
  /// 분석권 개수 설정
  Future<void> setTokenCount(final int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tokenCountKey, count);
      _logger.i('분석권 개수 설정: $count');
    } catch (e) {
      _logger.e('분석권 개수 설정 실패: $e');
    }
  }
  
  /// 분석권 1개 추가 (리워드 광고 시청 후)
  Future<bool> addToken() async {
    try {
      final currentCount = await getTokenCount();
      await setTokenCount(currentCount + 1);
      _logger.i('분석권 1개 추가됨. 현재 개수: ${currentCount + 1}');
      return true;
    } catch (e) {
      _logger.e('분석권 추가 실패: $e');
      return false;
    }
  }
  
  /// 분석권 1개 사용 (정밀 분석 시)
  Future<bool> useToken() async {
    try {
      final currentCount = await getTokenCount();
      if (currentCount <= 0) {
        _logger.w('사용할 분석권이 없습니다.');
        return false;
      }
      
      await setTokenCount(currentCount - 1);
      _logger.i('분석권 1개 사용됨. 현재 개수: ${currentCount - 1}');
      return true;
    } catch (e) {
      _logger.e('분석권 사용 실패: $e');
      return false;
    }
  }
  
  /// 분석권이 충분한지 확인
  Future<bool> hasToken() async {
    final count = await getTokenCount();
    return count > 0;
  }
  
  /// 오늘 리워드 광고 시청 횟수 조회
  Future<int> getTodayRewardAdCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString(_lastRewardAdDateKey) ?? '';
      
      if (lastDate == today) {
        return prefs.getInt('reward_ad_count_$today') ?? 0;
      }
      return 0;
    } catch (e) {
      _logger.e('오늘 리워드 광고 횟수 조회 실패: $e');
      return 0;
    }
  }
  
  /// 오늘 리워드 광고 시청 횟수 증가
  Future<void> incrementTodayRewardAdCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentCount = await getTodayRewardAdCount();
      
      await prefs.setString(_lastRewardAdDateKey, today);
      await prefs.setInt('reward_ad_count_$today', currentCount + 1);
      
      _logger.i('오늘 리워드 광고 시청 횟수 증가: ${currentCount + 1}');
    } catch (e) {
      _logger.e('리워드 광고 시청 횟수 증가 실패: $e');
    }
  }
  
  /// 오늘 리워드 광고를 더 볼 수 있는지 확인
  Future<bool> canWatchRewardAdToday() async {
    final todayCount = await getTodayRewardAdCount();
    return todayCount < _dailyRewardAdLimit;
  }
  
  /// 분석권 여러 개 추가 (결제 후)
  Future<void> addTokens(int count) async {
    try {
      final currentCount = await getTokenCount();
      await setTokenCount(currentCount + count);
      _logger.i('분석권 $count개 추가됨. 현재 개수: ${currentCount + count}');
    } catch (e) {
      _logger.e('분석권 추가 실패: $e');
    }
  }
  
  /// 분석권 정보 초기화 (개발/테스트용)
  Future<void> resetTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenCountKey);
      await prefs.remove(_lastRewardAdDateKey);
      _logger.i('분석권 정보 초기화 완료');
    } catch (e) {
      _logger.e('분석권 정보 초기화 실패: $e');
    }
  }
} 