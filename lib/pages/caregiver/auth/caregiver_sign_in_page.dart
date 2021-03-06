import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/caregiver/auth/sign_in/caregiver_sign_in_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';

class CaregiverSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: BlocListener<CaregiverSignInCubit, CaregiverSignInState>(
				  listener: (context, state) {
					  if (state.status.isSubmissionFailure) {
					  	if (state.signInError != null)
							  showFailSnackbar(context, state.signInError?.key);
					  	else if (state.passwordResetError != null)
								showFailSnackbar(context, 'authentication.error.emailLink', {
	                'TYPE': '${AppLinkType.passwordReset.index}',
	                'ERR': '${state.passwordResetError.index}'
	              });
				    }
				  },
				  child: ListView(
						padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
						shrinkWrap: true,
						children: [
							_buildSignInForm(context),
							_buildSignUpButtons(context),
							AuthFloatingButton(
								icon: Icons.arrow_back,
								action: () => Navigator.of(context).pop(),
								text: AppLocales.of(context).translate('page.loginSection.backToStartPage')
							)
						]
					)
			  )
	    ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
		return BlocBuilder<CaregiverSignInCubit, CaregiverSignInState>(
			cubit: BlocProvider.of<CaregiverSignInCubit>(context),
			builder: (context, state) { 
				return AuthGroup(
					title: AppLocales.of(context).translate('$_pageKey.logInTitle'),
					hint: AppLocales.of(context).translate('$_pageKey.logInHint'),
					isLoading: state.status.isSubmissionInProgress,
					action: PopupMenuList(
						lightTheme: true,
						customIcon: Icons.settings,
						items: _buildAdditionalLoginSettings(context)
					),
					content: Column(
						children: <Widget>[
							AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
								getField: (state) => state.email,
								changedAction: (cubit, value) => cubit.emailChanged(value),
								labelKey: 'authentication.email',
								icon: Icons.email,
								getErrorKey: (state) => [state.email.error.key],
								inputType: TextInputType.emailAddress
							),
							AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
								getField: (state) => state.password,
								changedAction: (cubit, value) => cubit.passwordChanged(value),
								labelKey: 'authentication.password',
								icon: Icons.lock,
								getErrorKey: (state) => [state.password.error.key],
								hideInput: true
							),
							AuthButton(
								button: UIButton.ofType(
									ButtonType.signIn,
									() => BlocProvider.of<CaregiverSignInCubit>(context).logInWithCredentials(),
									Colors.teal
								)
							),
							AuthDivider(),
							AuthButton.google(
								UIButton(
									'authentication.googleSignIn',
									() => BlocProvider.of<CaregiverSignInCubit>(context).logInWithGoogle()
								)
							)
						]
					)
				);
			}
		);
  }

	List<UIButton> _buildAdditionalLoginSettings(BuildContext context) {
		return [
			UIButton(
				'$_pageKey.resetPassword',
				() async {
					if (!await context.read<CaregiverSignInCubit>().resetPassword())
						showInfoSnackbar(context, '$_pageKey.enterEmail');
					else
						showSuccessSnackbar(context, '$_pageKey.resetEmailSent');
				},
				null,
				Icons.settings_backup_restore
			),
			UIButton(
				'$_pageKey.resetVerificationEmail',
				() async {
					var result = await context.read<CaregiverSignInCubit>().resendVerificationEmail();
					if (result == VerificationAttemptOutcome.emailSent)
						showSuccessSnackbar(context, 'authentication.emailVerificationSent');
					else if (result == VerificationAttemptOutcome.accountAlreadyVerified)
						showInfoSnackbar(context, 'authentication.error.accountAlreadyVerified');
				},
				null,
				Icons.mark_email_read
			),
		];
  }
	
  Widget _buildSignUpButtons(BuildContext context) {
		return AuthGroup(
			title: AppLocales.of(context).translate('$_pageKey.registerTitle'),
			hint: AppLocales.of(context).translate('$_pageKey.registerHint'),
			content: Column(
				children: <Widget>[
					AuthButton(
						button: UIButton.ofType(
							ButtonType.signUp,
							() => Navigator.of(context).pushNamed(AppPage.caregiverSignUpPage.name),
							Colors.teal
						)
					)
				]
			)
		);
	}

}
