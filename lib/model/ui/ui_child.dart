import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/ui_user.dart';

class UIChild extends UIUser {
	final int todayPlanCount;
	final bool hasActivePlan;
	final Map<CurrencyType, int> points;

  UIChild(ObjectId id, String name, {this.todayPlanCount = 0, this.hasActivePlan = false, this.points = const {}, int avatar = -1}) :
			  super(id, name, role: UserRole.child, avatar: avatar);
  UIChild.fromDBModel(Child child) : this(child.id, child.name, avatar: child.avatar);

	@override
	List<Object> get props => [id, todayPlanCount, hasActivePlan, points];
}