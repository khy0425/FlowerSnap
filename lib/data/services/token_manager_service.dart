import 'package:hive/hive.dart';
import '../models/api_token.dart';

class TokenManagerService {
  static const String _tokenBoxName = 'api_tokens';

  late Box<ApiToken> _tokenBox;

  /// 토큰 박스 초기화
  Future<void> init() async {
    _tokenBox = await Hive.openBox<ApiToken>(_tokenBoxName);
  }

  /// 특정 프로바이더의 활성 토큰 가져오기
  Future<ApiToken?> getActiveToken(final String provider) async {
    await _ensureBoxOpen();

    final tokens = _tokenBox.values
        .where((final token) => token.provider == provider && token.canUse)
        .toList();

    if (tokens.isEmpty) return null;

    // 가장 최근에 추가된 토큰 반환
    tokens.sort((final a, final b) => b.addedAt.compareTo(a.addedAt));
    return tokens.first;
  }

  /// 토큰 저장
  Future<void> saveToken(final ApiToken token) async {
    await _ensureBoxOpen();

    // 기존 같은 프로바이더 토큰이 있으면 비활성화
    final existingTokens = _tokenBox.values
        .where((final t) => t.provider == token.provider)
        .toList();

    for (final existingToken in existingTokens) {
      final updatedToken = ApiToken(
        provider: existingToken.provider,
        token: existingToken.token,
        addedAt: existingToken.addedAt,
        usageCount: existingToken.usageCount,
        usageLimit: existingToken.usageLimit,
        isActive: false, // 기존 토큰 비활성화
        expiresAt: existingToken.expiresAt,
      );
      await existingToken.delete();
      await _tokenBox.add(updatedToken);
    }

    // 새 토큰 저장
    await _tokenBox.add(token);
  }

  /// 토큰 사용량 증가
  Future<void> incrementTokenUsage(final ApiToken token) async {
    await _ensureBoxOpen();

    final updatedToken = ApiToken(
      provider: token.provider,
      token: token.token,
      addedAt: token.addedAt,
      usageCount: token.usageCount + 1,
      usageLimit: token.usageLimit,
      isActive: token.isActive,
      expiresAt: token.expiresAt,
    );

    await token.delete();
    await _tokenBox.add(updatedToken);
  }

  /// 토큰 제거
  Future<void> removeToken(final String provider) async {
    await _ensureBoxOpen();

    final tokensToRemove = _tokenBox.values
        .where((final token) => token.provider == provider)
        .toList();

    for (final token in tokensToRemove) {
      await token.delete();
    }
  }

  /// 모든 토큰 목록
  Future<List<ApiToken>> getAllTokens() async {
    await _ensureBoxOpen();
    return _tokenBox.values.toList();
  }

  /// 토큰 상태 업데이트
  Future<void> updateTokenStatus(
    final ApiToken token,
    final bool isActive,
  ) async {
    await _ensureBoxOpen();

    final updatedToken = ApiToken(
      provider: token.provider,
      token: token.token,
      addedAt: token.addedAt,
      usageCount: token.usageCount,
      usageLimit: token.usageLimit,
      isActive: isActive,
      expiresAt: token.expiresAt,
    );

    await token.delete();
    await _tokenBox.add(updatedToken);
  }

  /// 만료된 토큰 정리
  Future<void> cleanupExpiredTokens() async {
    await _ensureBoxOpen();

    final now = DateTime.now();
    final expiredTokens = _tokenBox.values
        .where(
          (final token) =>
              token.expiresAt != null && now.isAfter(token.expiresAt!),
        )
        .toList();

    for (final token in expiredTokens) {
      await token.delete();
    }
  }

  /// 박스가 열려있는지 확인하고 필요시 열기
  Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_tokenBoxName)) {
      _tokenBox = await Hive.openBox<ApiToken>(_tokenBoxName);
    }
  }

  /// 서비스 종료
  Future<void> dispose() async {
    if (Hive.isBoxOpen(_tokenBoxName)) {
      await _tokenBox.close();
    }
  }
}
