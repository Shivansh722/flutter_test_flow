import 'package:shared_preferences/shared_preferences.dart';

/// Default version baked at build time. You can override it with
/// `--dart-define=HYPERKYC_VERSION=2.3.0` when building the APK.
const String kHyperKycVersion = String.fromEnvironment('HYPERKYC_VERSION', defaultValue: '2.3.0');

const _kPrefKey = 'hyperkyc_version';

class VersionManager {
  /// Returns the persisted version if present, otherwise the compile-time default.
  static Future<String> getCurrentHyperKycVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrefKey) ?? kHyperKycVersion;
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
