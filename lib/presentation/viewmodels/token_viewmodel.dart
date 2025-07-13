import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../data/models/api_token.dart';
import '../../data/services/plant_analysis_service.dart';
import '../../data/services/token_manager_service.dart';
import 'home_viewmodel.dart';

/// 토큰 관리 ViewModel (MVVM + Command 패턴)
class TokenViewModel extends ChangeNotifier {
  final TokenManagerService _tokenManager;
  final PlantAnalysisService _analysisService;

  // === State Properties ===
  List<ApiToken> _tokens = <ApiToken>[];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isValidating = false;

  // === Constructor ===
  TokenViewModel({
    required final TokenManagerService tokenManager,
    required final PlantAnalysisService analysisService,
  }) : _tokenManager = tokenManager,
       _analysisService = analysisService;

  // === Getters (State Exposure) ===
  List<ApiToken> get tokens => List.unmodifiable(_tokens);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isValidating => _isValidating;
  bool get hasTokens => _tokens.isNotEmpty;
  int get activeTokenCount => _tokens
      .where((final ApiToken token) => token.isActive && token.canUse)
      .length;

  // === Command Methods (User Actions) ===

  /// 토큰 목록 로드
  Future<void> loadTokensCommand() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _tokens = await _tokenManager.getAllTokens();
      notifyListeners();
    } catch (e) {
      _setError('토큰 목록을 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 새 토큰 추가
  Future<void> addTokenCommand({
    required final String provider,
    required final String token,
    final int? usageLimit,
  }) async {
    try {
      _setValidating(true);
      _errorMessage = null;

      // 유효성 검증
      if (provider.isEmpty) {
        throw ValidationException.required('제공자');
      }
      if (token.isEmpty) {
        throw ValidationException.required('토큰');
      }

      // 토큰 추가
      final bool success = await _analysisService.addApiToken(
        provider,
        token,
        usageLimit: usageLimit,
      );

      if (!success) {
        throw ApiException.unauthorized();
      }

      // 목록 새로고침
      await loadTokensCommand();
    } catch (e) {
      if (e is AppException) {
        _setError(e.message);
      } else {
        _setError('토큰 추가 중 오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      _setValidating(false);
    }
  }

  /// 토큰 삭제
  Future<void> deleteTokenCommand(final String provider) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _analysisService.removeToken(provider);

      // 목록에서 즉시 제거
      _tokens.removeWhere((final ApiToken token) => token.provider == provider);
      notifyListeners();
    } catch (e) {
      _setError('토큰 삭제 중 오류가 발생했습니다: ${e.toString()}');
      // 실패 시 목록 다시 로드
      await loadTokensCommand();
    } finally {
      _setLoading(false);
    }
  }

  /// 토큰 활성화/비활성화
  Future<void> toggleTokenCommand(final ApiToken token) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _tokenManager.updateTokenStatus(token, !token.isActive);

      // 목록 새로고침
      await loadTokensCommand();
    } catch (e) {
      _setError('토큰 상태 변경 중 오류가 발생했습니다: ${e.toString()}');
      // 실패 시 목록 다시 로드
      await loadTokensCommand();
    } finally {
      _setLoading(false);
    }
  }

  /// 모든 토큰 삭제
  Future<void> clearAllTokensCommand() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      for (final ApiToken token in _tokens) {
        await _analysisService.removeToken(token.provider);
      }

      _tokens.clear();
      notifyListeners();
    } catch (e) {
      _setError('토큰 전체 삭제 중 오류가 발생했습니다: ${e.toString()}');
      // 실패 시 목록 다시 로드
      await loadTokensCommand();
    } finally {
      _setLoading(false);
    }
  }

  /// 토큰 상태 새로고침
  Future<void> refreshTokenStatusCommand() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _analysisService.getTokenStatus();

      // 토큰 목록 새로고침
      await loadTokensCommand();
    } catch (e) {
      _setError('토큰 상태 새로고침 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 에러 메시지 해제
  Future<void> clearErrorCommand() async {
    _errorMessage = null;
    notifyListeners();
  }

  // === Helper Methods ===

  /// 특정 제공자의 토큰 가져오기
  ApiToken? getTokenByProvider(final String provider) {
    try {
      return _tokens.firstWhere(
        (final ApiToken token) => token.provider == provider,
      );
    } catch (e) {
      return null;
    }
  }

  /// 활성 토큰 목록
  List<ApiToken> get activeTokens => _tokens
      .where((final ApiToken token) => token.isActive && token.canUse)
      .toList();

  /// 만료된 토큰 목록
  List<ApiToken> get expiredTokens =>
      _tokens.where((final ApiToken token) => token.isExpired).toList();

  /// 사용량 초과 토큰 목록
  List<ApiToken> get limitExceededTokens => _tokens
      .where((final ApiToken token) => token.isUsageLimitExceeded)
      .toList();

  // === Private Helper Methods ===

  void _setLoading(final bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setValidating(final bool isValidating) {
    _isValidating = isValidating;
    notifyListeners();
  }

  void _setError(final String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  // === Lifecycle Methods ===

  /// ViewModel 초기화
  Future<void> initializeCommand() async {
    await loadTokensCommand();
  }

  @override
  void dispose() {
    // 리소스 정리
    super.dispose();
  }
}

// === Riverpod Providers ===

/// TokenManagerService Provider
final tokenManagerServiceProvider = Provider<TokenManagerService>(
  (final Ref ref) => TokenManagerService(),
);

/// TokenViewModel Provider
final tokenViewModelProvider = ChangeNotifierProvider<TokenViewModel>((
  final Ref ref,
) {
  final TokenManagerService tokenManager = ref.watch(
    tokenManagerServiceProvider,
  );
  final PlantAnalysisService analysisService = ref.watch(
    plantAnalysisServiceProvider,
  );
  return TokenViewModel(
    tokenManager: tokenManager,
    analysisService: analysisService,
  );
});

/// 토큰 목록 상태 Provider
final tokensProvider = Provider<List<ApiToken>>(
  (final Ref ref) => ref.watch(tokenViewModelProvider).tokens,
);

/// 토큰 로딩 상태 Provider
final tokenLoadingProvider = Provider<bool>(
  (final Ref ref) => ref.watch(tokenViewModelProvider).isLoading,
);

/// 활성 토큰 개수 Provider
final activeTokenCountProvider = Provider<int>(
  (final Ref ref) => ref.watch(tokenViewModelProvider).activeTokenCount,
);
