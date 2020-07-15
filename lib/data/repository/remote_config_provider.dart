import 'package:flutter/foundation.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fokus/exception/config_fetch_failed_exception.dart';

class RemoteConfigProvider {
	RemoteConfig _remoteConfig;
	
	String _dbAccessString;
	String get dbAccessString => _dbAccessString;

	static const String _DB_CONFIG_KEY = "db_access_string";

	Future<void> initialize() async {
		_remoteConfig = await RemoteConfig.instance;
		await _remoteConfig.fetch();
		await _remoteConfig.activateFetched();

		var dbConfig = _remoteConfig.getString(_DB_CONFIG_KEY);
		if (dbConfig == '') {
			debugPrint('Could not retrieve the database configuration');
			throw ConfigFetchFailedException();
		}
		_dbAccessString = dbConfig;
	}
}