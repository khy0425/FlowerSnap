import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/analysis_result.dart';
import 'data/models/api_token.dart';
import 'data/services/reward_ad_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(ApiTokenAdapter());
  Hive.registerAdapter(AnalysisResultAdapter());

  // Google Mobile Ads 초기화
  await RewardAdService.initialize();
  await RewardAdService.setPrivacySettings();

  // 앱 실행
  runApp(const ProviderScope(child: FloraSnapApp()));
}
