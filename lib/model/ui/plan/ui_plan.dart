import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/utils/app_locales.dart';

import 'ui_plan_base.dart';

class UIPlan extends UIPlanBase {
	final int taskCount;

  UIPlan(ObjectId id, String name, this.taskCount, TranslateFunc description) : super(id, name, description);
	UIPlan.fromDBModel(Plan plan, TranslateFunc description) : this(plan.id, plan.name, plan.tasks.length, description);

  @override
  List<Object> get props => super.props..addAll([[taskCount]]);

  String print(BuildContext context) {
    return 'UIPlan{name: $name, repeatabilityDescription: ${description(context)}, taskCount: $taskCount}';
  }
}
