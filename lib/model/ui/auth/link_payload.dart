import 'package:fokus_auth/fokus_auth.dart';

class LinkPayload {
	final String email;
	final AppLinkType type;
	final String oobCode;

  LinkPayload._({this.email, this.type, this.oobCode});
  LinkPayload.fromLink(Uri link) : this._(
	  email: Uri.parse(Uri.decodeFull(link.queryParameters['continueUrl'])).queryParameters['email'],
	  type: AppLinkType.values.firstWhere((element) => element.key == link.queryParameters['mode'], orElse: () => null),
    oobCode: link.queryParameters['oobCode']
  );
}
