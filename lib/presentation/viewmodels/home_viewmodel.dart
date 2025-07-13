import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../data/models/analysis_result.dart';
import '../../data/services/plant_analysis_service.dart';

/// 홈 화면 ViewModel (MVVM + Command 패턴)
class HomeViewModel extends ChangeNotifier {
  final PlantAnalysisService _analysisService;
  final ImagePicker _imagePicker;

  // === State Properties ===
  final List<AnalysisResult> _analysisHistory = <AnalysisResult>[];
  bool _isAnalyzing = false;
  String? _errorMessage;
  int _selectedTabIndex = 0;

  // === Constructor ===
  HomeViewModel({
    required final PlantAnalysisService analysisService,
    final ImagePicker? imagePicker,
  }) : _analysisService = analysisService,
       _imagePicker = imagePicker ?? ImagePicker();

  // === Getters (State Exposure) ===
  List<AnalysisResult> get analysisHistory =>
      List.unmodifiable(_analysisHistory);
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;
  bool get hasHistory => _analysisHistory.isNotEmpty;
  int get historyCount => _analysisHistory.length;

  // === Command Methods (User Actions) ===

  /// 카메라에서 이미지 촬영 후 분석
  Future<void> captureFromCameraCommand() async {
    await _executeImageAnalysisCommand(ImageSource.camera);
  }

  /// 갤러리에서 이미지 선택 후 분석
  Future<void> selectFromGalleryCommand() async {
    await _executeImageAnalysisCommand(ImageSource.gallery);
  }

  /// 탭 선택 변경
  Future<void> changeTabCommand(final int index) async {
    if (index < 0 || index > 2) return;
    if (_selectedTabIndex == index) return;

    _selectedTabIndex = index;
    notifyListeners();
  }

  /// 분석 결과 삭제
  Future<void> deleteAnalysisResultCommand(final String resultId) async {
    try {
      _errorMessage = null;

      final int indexToRemove = _analysisHistory.indexWhere(
        (final AnalysisResult result) => result.id == resultId,
      );
      if (indexToRemove == -1) return;

      _analysisHistory.removeAt(indexToRemove);
      notifyListeners();
    } catch (e) {
      _setError('결과 삭제 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 분석 기록 전체 삭제
  Future<void> clearAllHistoryCommand() async {
    try {
      _errorMessage = null;
      _analysisHistory.clear();
      notifyListeners();
    } catch (e) {
      _setError('기록 삭제 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 에러 메시지 해제
  Future<void> clearErrorCommand() async {
    _errorMessage = null;
    notifyListeners();
  }

  /// 분석 결과 새로고침
  Future<void> refreshHistoryCommand() async {
    try {
      _errorMessage = null;
      // 향후: 로컬 저장소에서 기록 다시 로드 구현 예정
      notifyListeners();
    } catch (e) {
      _setError('새로고침 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // === Private Helper Methods ===

  /// 이미지 분석 실행 (공통 로직)
  Future<void> _executeImageAnalysisCommand(final ImageSource source) async {
    try {
      _setAnalyzing(true);
      _errorMessage = null;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _setAnalyzing(false);
        return; // 사용자가 취소한 경우
      }

      final File imageFile = File(pickedFile.path);

      // 이미지 분석 실행 (토큰 유무에 따라 자동 선택)
      final AnalysisResult result = await _analysisService.analyzeImage(
        imageFile,
      );

      _analysisHistory.insert(0, result); // 최신 결과를 맨 앞에 추가
    } catch (e) {
      if (e is AppException) {
        _setError(e.message);
      } else {
        _setError('이미지 분석 중 오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      _setAnalyzing(false);
    }
  }

  /// 로딩 상태 설정
  void _setAnalyzing(final bool isAnalyzing) {
    _isAnalyzing = isAnalyzing;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(final String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  // === Lifecycle Methods ===

  /// ViewModel 초기화
  Future<void> initializeCommand() async {
    try {
      _errorMessage = null;
      await refreshHistoryCommand();
    } catch (e) {
      _setError('초기화 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    // 리소스 정리
    super.dispose();
  }
}

// === Riverpod Providers ===

/// PlantAnalysisService Provider
final plantAnalysisServiceProvider = Provider<PlantAnalysisService>(
  (final Ref ref) => PlantAnalysisService(),
);

/// HomeViewModel Provider
final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>((
  final Ref ref,
) {
  final PlantAnalysisService analysisService = ref.watch(
    plantAnalysisServiceProvider,
  );
  return HomeViewModel(analysisService: analysisService);
});

/// 분석 기록 상태만 제공하는 Provider
final analysisHistoryProvider = Provider<List<AnalysisResult>>(
  (final Ref ref) => ref.watch(homeViewModelProvider).analysisHistory,
);

/// 현재 탭 인덱스 Provider
final selectedTabProvider = Provider<int>(
  (final Ref ref) => ref.watch(homeViewModelProvider).selectedTabIndex,
);

/// 로딩 상태 Provider
final isAnalyzingProvider = Provider<bool>(
  (final Ref ref) => ref.watch(homeViewModelProvider).isAnalyzing,
);
