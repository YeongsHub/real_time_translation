import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_time_translation/core/config/env_config.dart';

/// Holds runtime configuration loaded from Firebase Remote Config.
/// API keys are NEVER embedded in the app — they are fetched at runtime.
class ConfigService {
  const ConfigService({
    this.proxyBaseUrl = '',
    this.deepLApiKey = '',
    this.cloudSttEnabled = false,
  });

  final String proxyBaseUrl;
  final String deepLApiKey;
  final bool cloudSttEnabled;
}

/// Loads config from Firebase Remote Config.
Future<ConfigService> loadRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  await remoteConfig.setDefaults({
    'proxy_base_url': EnvConfig.proxyBaseUrl,
    'deepl_api_key': '',
    'cloud_stt_enabled': false,
  });

  try {
    await remoteConfig.fetchAndActivate();
  } catch (_) {
    // Use defaults on failure — offline mode will still work.
  }

  return ConfigService(
    proxyBaseUrl: remoteConfig.getString('proxy_base_url'),
    deepLApiKey: remoteConfig.getString('deepl_api_key'),
    cloudSttEnabled: remoteConfig.getBool('cloud_stt_enabled'),
  );
}

/// Provides runtime config from Firebase Remote Config.
final configServiceProvider = FutureProvider<ConfigService>((ref) async {
  return loadRemoteConfig();
});
