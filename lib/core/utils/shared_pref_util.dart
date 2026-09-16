import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences so the rest of the app never
/// touches the plugin directly. Call [init] once in main() before
/// runApp, then use the static getters/setters anywhere.
class SharedPrefUtil {
  SharedPrefUtil._();

  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static const _kHasSeenOnboarding = 'has_seen_onboarding';
  static const _kRememberedEmail = 'remembered_email';
  static const _kThemeModeOverride = 'theme_mode_override'; // 'light' | 'dark' | 'system'
  static const _kCachedUid = 'cached_uid';
  static const _kLastSelectedGameId = 'last_selected_game_id';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static void _assertInitialized() {
    if (!_initialized) {
      throw StateError('SharedPrefUtil.init() must be called before use (typically in main()).');
    }
  }

  // --- Onboarding ---

  static bool get hasSeenOnboarding {
    _assertInitialized();
    return _prefs.getBool(_kHasSeenOnboarding) ?? false;
  }

  static Future<void> setHasSeenOnboarding(bool value) async {
    _assertInitialized();
    await _prefs.setBool(_kHasSeenOnboarding, value);
  }

  // --- Remembered login email ---

  static String? get rememberedEmail {
    _assertInitialized();
    return _prefs.getString(_kRememberedEmail);
  }

  static Future<void> setRememberedEmail(String? email) async {
    _assertInitialized();
    if (email == null || email.isEmpty) {
      await _prefs.remove(_kRememberedEmail);
    } else {
      await _prefs.setString(_kRememberedEmail, email);
    }
  }

  // --- Theme override (independent of system ThemeMode) ---

  static String get themeModeOverride {
    _assertInitialized();
    return _prefs.getString(_kThemeModeOverride) ?? 'system';
  }

  static Future<void> setThemeModeOverride(String mode) async {
    _assertInitialized();
    assert(['light', 'dark', 'system'].contains(mode));
    await _prefs.setString(_kThemeModeOverride, mode);
  }

  // --- Cached UID (for instant "am I logged in?" checks before Firebase resolves) ---

  static String? get cachedUid {
    _assertInitialized();
    return _prefs.getString(_kCachedUid);
  }

  static Future<void> setCachedUid(String? uid) async {
    _assertInitialized();
    if (uid == null) {
      await _prefs.remove(_kCachedUid);
    } else {
      await _prefs.setString(_kCachedUid, uid);
    }
  }

  // --- Last selected game filter (e.g. on tournaments screen) ---

  static String? get lastSelectedGameId {
    _assertInitialized();
    return _prefs.getString(_kLastSelectedGameId);
  }

  static Future<void> setLastSelectedGameId(String? gameId) async {
    _assertInitialized();
    if (gameId == null) {
      await _prefs.remove(_kLastSelectedGameId);
    } else {
      await _prefs.setString(_kLastSelectedGameId, gameId);
    }
  }

  // --- Full reset (e.g. on logout, if you want to clear local prefs too) ---

  static Future<void> clearAll() async {
    _assertInitialized();
    await _prefs.clear();
  }
}