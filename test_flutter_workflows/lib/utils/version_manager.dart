import 'package:shared_preferences/shared_preferences.dart';

import 'package:package_info_plus/package_info_plus.dart';

/// Value that can be supplied at compile time for quick overrides.
/// This is intentionally *not* used as the canonical version, it only
/// takes precedence when you pass `--dart-define=HYPERKYC_VERSION=…`.
const String kHyperKycEnvOverride =
    String.fromEnvironment('HYPERKYC_VERSION', defaultValue: '');

const _kPrefKey = 'hyperkyc_version';

class VersionManager {
  /// Returns the persisted version if present, otherwise the real
  /// package version from pubspec.yaml. A dart-define value can be used
  /// to short-circuit this lookup during development or build scripts.
  static Future<String> getCurrentHyperKycVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString(_kPrefKey);
    if (override != null) return override;

    if (kHyperKycEnvOverride.isNotEmpty) {
      return kHyperKycEnvOverride;
    }

    // fetch from pubspec via package_info_plus
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Persist a runtime override for the version.
  static Future<void> setHyperKycVersion(String v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, v);
  }

  /// Clear persisted override and fall back to compile-time default.
  static Future<void> clearOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefKey);
  }
}
