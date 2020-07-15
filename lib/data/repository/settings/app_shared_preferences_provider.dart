import 'package:fokus/data/model/app_config_entry.dart';
import 'package:fokus/data/repository/settings/app_config_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferencesProvider implements AppConfigProvider {
	SharedPreferences _preferences;

	@override
	Future initialize() async => _preferences = await SharedPreferences.getInstance();

	@override
	String getString(AppConfigEntry entry) => _preferences.getString(entry.key);

	@override
	void remove(AppConfigEntry entry) => _preferences.remove(entry.key);

	@override
	void setString(AppConfigEntry entry, String value) => _preferences.setString(entry.key, value);

  @override
  bool containsEntry(AppConfigEntry entry) => _preferences.containsKey(entry.key);

  @override
  Set<AppConfigEntry> getEntries() => _preferences.getKeys().map((e) => AppConfigEntry.values.firstWhere((entry) => entry.key == e)).toSet();
}
