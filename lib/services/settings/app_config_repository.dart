import 'package:fokus/model/app_config_entry.dart';
import 'package:fokus/services/settings/app_config_provider.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppConfigRepository {
	AppConfigProvider _settingsProvider;

	AppConfigRepository(this._settingsProvider);

	Future<AppConfigRepository> initialize() async {
		await _settingsProvider.initialize();
		return this;
	}

	ObjectId getLastUser() => _settingsProvider.containsEntry(AppConfigEntry.lastUser) ? ObjectId.parse(_settingsProvider.getString(AppConfigEntry.lastUser)) : null;

	void setLastUser(ObjectId userId) => _settingsProvider.setString(AppConfigEntry.lastUser, userId.toHexString());

	void removeLastUser() => _settingsProvider.remove(AppConfigEntry.lastUser);
}