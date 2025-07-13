import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// 분석 토큰 관리 서비스
class AnalysisTokenService {
  static const String _tokenCountKey = 'analysis_token_count';
  
  final Logger _logger = Logger();

  /// 현재 토큰 개수 조회
  Future<int> getTokenCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_tokenCountKey) ?? 0;
    _logger.d('💎 현재 토큰 개수: $count');
    return count;
  }

  /// 토큰 추가
  Future<void> addToken() async {
    final currentCount = await getTokenCount();
    await _setTokenCount(currentCount + 1);
    _logger.i('💎 토큰 1개 추가됨. 현재: ${currentCount + 1}개');
  }

  /// 복수 토큰 추가
  Future<void> addTokens(final int count) => _modifyTokenCount(count);

  /// 토큰 사용 (차감)
  Future<bool> useToken() async {
    final currentCount = await getTokenCount();
    
    if (currentCount <= 0) {
      _logger.w('❌ 사용 가능한 토큰이 없습니다');
      return false;
    }
    
    await _setTokenCount(currentCount - 1);
    _logger.i('💎 토큰 1개 사용됨. 남은 토큰: ${currentCount - 1}개');
    return true;
  }

  /// 토큰 개수 설정
  Future<void> _setTokenCount(final int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenCountKey, count);
  }

  /// 토큰 개수 수정 (내부 메서드)
  Future<void> _modifyTokenCount(final int count) async {
    if (count < 0) {
      _logger.w('❌ 음수 토큰은 추가할 수 없습니다');
      return;
    }
    
    final currentCount = await getTokenCount();
    final newCount = currentCount + count;
    await _setTokenCount(newCount);
    
    _logger.i('💎 토큰 ${count}개 추가됨. 현재: ${newCount}개');
  }

  /// 토큰 개수 리셋 (디버그용)
  Future<void> resetTokenCount() async {
    await _setTokenCount(0);
    _logger.i('💎 토큰 개수가 초기화되었습니다');
  }

  /// 특정 토큰 개수로 설정 (테스트용)
  Future<void> setTokenCountForTesting(final int count) async {
    await _setTokenCount(count);
    _logger.d('🧪 테스트용 토큰 설정: ${count}개');
  }
} 