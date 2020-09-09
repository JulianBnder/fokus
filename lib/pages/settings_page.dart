import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_bar_buttons.dart';

class SettingsPage extends StatefulWidget {
	@override
	_SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
	static const String _pageKey = 'page.settings.content';
	static const String _defaultLanguageKey = 'default';

	List<String> languages = [_defaultLanguageKey, 'en', 'pl'];
	String pickedLanguage;

  @override
  Widget build(BuildContext context) {
    var authenticationBloc = context.bloc<AuthenticationBloc>();
    var isCurrentUserCaregiver = authenticationBloc.state.user.role == UserRole.caregiver;

		// Loading current locale (don't work with "default" option)
    pickedLanguage = pickedLanguage ?? AppLocales.of(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocales.of(context).translate('page.settings.header.title'))
      ),
			body: Column(
				children: [
					Expanded(
						child: ListView(
							shrinkWrap: true,
							children: [
								if(isCurrentUserCaregiver)
									..._buildSettingsList(
										AppLocales.of(context).translate('$_pageKey.profile.header'),
										_getProfileFields()
									),
								..._buildSettingsList(
										AppLocales.of(context).translate('$_pageKey.appSettings.header'),
									_getSettingsFields()
								)
							]
						)
					)
				]
			)
		);
  }

	List<Widget> _buildSettingsList(String title, List<Widget> fields) {
		return [
			Padding(
				padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding, vertical: 20.0).copyWith(bottom: 6.0),
				child: Text(
					title,
					style: TextStyle(fontWeight: FontWeight.bold),
					textAlign: TextAlign.left,
				)
			),
			ListView.separated(
				shrinkWrap: true,
				physics: NeverScrollableScrollPhysics(),
				itemCount: fields.length,
				separatorBuilder: (context, index) => Divider(color: Colors.black12, height: 1.0),
				itemBuilder: (context, index) => fields[index]
			)
		];
	}
	
	void _setLanguage(String langCode) {
		setState(() => pickedLanguage = langCode);
		if(langCode == _defaultLanguageKey) {
			// Don't overwrite system lang
		} else {
			// Change app lang to langCode
		}
	}

	void _deleteAccount() {
		showBasicDialog(
			context,
			GeneralDialog.confirm(
				title: AppLocales.of(context).translate('$_pageKey.profile.deleteAccountLabel'),
				content: AppLocales.of(context).translate('$_pageKey.profile.deleteAccountConfirmation'),
				confirmAction: () => { /* Delete the account */},
				confirmText: 'actions.delete',
				confirmColor: Colors.red
			)
		);
	}

	Widget _buildBasicListTile({String title, String subtitle, IconData icon, Color color, Function onTap}) {
		return ListTile(
			title: Text(title, style: TextStyle(color: color ?? Colors.black)),
			subtitle: subtitle != null ? Text(subtitle) : null,
			trailing: Padding(
				padding: EdgeInsets.only(left: 4.0, top: 2.0),
				child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
			),
			leading: Padding(
				padding: EdgeInsets.only(left: 8.0),
				child: Icon(icon, color: color ?? Colors.grey[600])
			),
			onTap: onTap
		);
	}

	List<Widget> _getProfileFields() {
		return [
			_buildBasicListTile(
				title: AppLocales.of(context).translate('$_pageKey.profile.editNameLabel'),
				icon: Icons.edit,
				onTap: () => showNameEditDialog(context)
			),
			_buildBasicListTile(
				title: AppLocales.of(context).translate('$_pageKey.profile.changePasswordLabel'),
				icon: Icons.lock,
				onTap: () => showPasswordChangeDialog(context)
			),
			_buildBasicListTile(
				title: AppLocales.of(context).translate('$_pageKey.profile.deleteAccountLabel'),
				subtitle: AppLocales.of(context).translate('$_pageKey.profile.deleteAccountHint'),
				icon: Icons.delete,
				color: Colors.red,
				onTap: _deleteAccount
			)
		];
	}

	List<Widget> _getSettingsFields() {
		return [
			SmartSelect.single(
				value: pickedLanguage,
				title: AppLocales.of(context).translate('$_pageKey.appSettings.changeLanguageLabel'),
				modalType: SmartSelectModalType.bottomSheet,
				options: [
					for(String lang in languages)
						SmartSelectOption(
							title: AppLocales.of(context).translate('$_pageKey.appSettings.languages.$lang'),
							value: lang
						)
				],
				modalConfig: SmartSelectModalConfig(
					trailing: ButtonSheetBarButtons(
						buttons: [
							UIButton('actions.confirm', () => { Navigator.pop(context) }, Colors.green, Icons.done)
						],
					)
				),
				leading: Padding(
					padding: EdgeInsets.only(left: 8.0),
					child: Icon(Icons.language)
				),
				onChange: (val) => _setLanguage(val)
			),
			_buildBasicListTile(
				title: AppLocales.of(context).translate('$_pageKey.appSettings.showAppInfoLabel'),
				icon: Icons.info,
				onTap: () => showAppInfoDialog(context)
			)
		];
	}

}