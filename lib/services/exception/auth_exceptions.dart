import 'package:fokus_auth/fokus_auth.dart';

extension EmailSignUpErrorTextKey on EmailSignUpError {
	String get key => const {
		EmailSignUpError.emailAlreadyUsed: 'authentication.error.emailAlreadyUsed',
		EmailSignUpError.emailInvalid: 'authentication.error.emailInvalid',
	}[this];
}

extension EmailSignInErrorTextKey on EmailSignInError {
	String get key => const {
		EmailSignInError.wrongPassword: 'authentication.error.incorrectData',
		EmailSignInError.userNotFound: 'authentication.error.incorrectEmail',
		EmailSignInError.userDisabled: 'authentication.error.userDisabled',
	}[this];
}

extension PasswordChangeErrorTextKey on PasswordConfirmError {
	String get key => const {
		PasswordConfirmError.wrongPassword: 'authentication.error.incorrectPassword',
	}[this];
}

extension PasswordResetErrorTextKey on PasswordResetError {
	String get key => const {
		PasswordResetError.invalidCode: 'authentication.error.passwordResetCodeInvalid',
		PasswordResetError.codeExpired: 'authentication.error.passwordResetCodeExpired',
	}[this];
}
