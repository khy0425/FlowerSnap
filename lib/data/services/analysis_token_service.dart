import 'dart:async';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 분석 토큰 관리 서비스
class AnalysisTokenService {
  static const String _tokenCountKey = 'analysis_token_count';
  
  final Logger _logger;

  /// 생성자 (의존성 주입)
  AnalysisTokenService({final Logger? logger}) : _logger = logger ?? Logger();

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
    if (currentCount > 0) {
      await _setTokenCount(currentCount - 1);
      _logger.i('💎 토큰 1개 사용됨. 남은 토큰: ${currentCount - 1}개');
      return true;
    } else {
      _logger.w('💎 사용할 토큰이 없습니다');
      return false;
    }
  }

  /// 토큰 개수 직접 설정 (테스트용)
  Future<void> _setTokenCount(final int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenCountKey, count);
    _logger.d('💎 토큰 개수 설정: $count개');
  }

  /// 토큰 개수 변경 (내부 메서드)
  Future<void> _modifyTokenCount(final int delta) async {
    final currentCount = await getTokenCount();
    final newCount = (currentCount + delta).clamp(0, 999);
    await _setTokenCount(newCount);
    
    if (delta > 0) {
      _logger.i('💎 토큰 $delta개 추가됨. 현재: $newCount개');
    } else {
      _logger.i('💎 토큰 ${-delta}개 차감됨. 현재: $newCount개');
    }
  }

  /// 토큰 개수 직접 설정 (공개 메서드)
  Future<void> setTokenCount(final int count) async {
    await _setTokenCount(count);
    _logger.i('💎 토큰 개수 수동 설정: $count개');
  }

  /// 토큰 초기화 (모든 토큰 제거)
  Future<void> resetTokens() async {
    await _setTokenCount(0);
    _logger.i('💎 모든 토큰이 초기화되었습니다');
  }

  /// 토큰 보유 여부 확인
  Future<bool> hasToken() async {
    final count = await getTokenCount();
    return count > 0;
  }
} 