import 'package:bson/bson.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/services/app_locales.dart';

import 'ui_plan_base.dart';

class UIPlanInstance extends UIPlanBase {
	final int taskCount;
	final int completedTaskCount;
	final int Function() elapsedActiveTime;
	final PlanInstanceState state;
	final List<DateSpan<TimeDate>> duration;

	UIPlanInstance(ObjectId id, String name, this.taskCount, this.completedTaskCount, this.elapsedActiveTime, this.state, this.duration, [TranslateFunc description]) : super(id, name, description);
	UIPlanInstance.fromDBModel(PlanInstance plan, String planName, this.completedTaskCount, this.elapsedActiveTime, [TranslateFunc description]) :
				taskCount = plan.tasks.length, state = plan.state, duration = plan.duration, super(plan.id, planName, description);
	UIPlanInstance.fromDBPlanModel(Plan plan, [TranslateFunc description]) : completedTaskCount = 0, elapsedActiveTime = _defElapsedTime,
			taskCount = plan.tasks.length, state = PlanInstanceState.notStarted, duration = null, super(null, plan.name, description);

	@override
  List<Object> get props => super.props..addAll([taskCount, completedTaskCount, state, duration]);

	static int _defElapsedTime() => 0;
}
