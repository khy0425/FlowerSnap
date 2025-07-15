import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../data/services/analysis_token_service.dart';
import '../../data/services/ensemble_analyzer.dart';
import '../../data/services/enhanced_plant_analysis_service.dart';
import '../../data/services/plant_analysis_service.dart';
import '../../data/services/plantid_service.dart';
import '../../data/services/plantnet_service.dart';
import '../../data/services/token_manager_service.dart';

/// 서비스 로케이터 - 의존성 주입을 위한 중앙 관리 시스템
class ServiceLocator {
  static final GetIt _instance = GetIt.instance;
  
  /// 서비스 로케이터 초기화
  static Future<void> setup() async {
    // 공통 서비스
    _instance.registerLazySingleton(() => Logger());
    
    // 기본 서비스들
    _instance.registerLazySingleton(() => AnalysisTokenService(
      logger: _instance<Logger>(),
    ));
    
    _instance.registerLazySingleton(() => TokenManagerService());
    _instance.registerLazySingleton(() => PlantNetService());
    _instance.registerLazySingleton(() => PlantIdService());
    
    _instance.registerLazySingleton(() => EnsembleAnalyzer(
      logger: _instance<Logger>(),
    ));
    
    // 복합 서비스들
    _instance.registerLazySingleton(() => PlantAnalysisService(
      logger: _instance<Logger>(),
      tokenManager: _instance<TokenManagerService>(),
      plantNetService: _instance<PlantNetService>(),
      plantIdService: _instance<PlantIdService>(),
    ));
    
    _instance.registerLazySingleton(() => EnhancedPlantAnalysisService(
      logger: _instance<Logger>(),
      ensembleAnalyzer: _instance<EnsembleAnalyzer>(),
    ));
    
    // 서비스들 초기화
    await _instance<TokenManagerService>().init();
  }
  
  /// 서비스 인스턴스 가져오기
  static T get<T extends Object>() => _instance<T>();
  
  /// 서비스 등록 (테스트용)
  static void registerForTest<T extends Object>(
    final T instance, {
    final String? instanceName,
  }) {
    _instance.registerSingleton<T>(instance, instanceName: instanceName);
  }
  
  /// 서비스 등록 해제 (테스트용)
  static void unregisterForTest<T extends Object>({
    final String? instanceName,
  }) {
    _instance.unregister<T>(instanceName: instanceName);
  }
  
  /// 모든 서비스 해제
  static Future<void> reset() async {
    await _instance.reset();
  }
} 