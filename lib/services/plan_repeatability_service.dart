import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/db/plan/plan_repeatability.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/string_utils.dart';

import 'data/data_repository.dart';

class PlanRepeatabilityService {
	final DataRepository _dbRepository = GetIt.I<DataRepository>();

	Future<List<Plan>> getPlansByDate(ObjectId childId, Date date, {bool activeOnly = true}) async {
		return filterPlansByDate(await _dbRepository.getChildPlans(childId, activeOnly: activeOnly), date);
	}

	Future<List<Plan>> filterPlansByDate(List<Plan> plans, Date date, {bool activeOnly = true}) async {
		return plans.where((plan) => _planInstanceExistsByDate(plan, date)).toList();
	}

  bool _planInstanceExistsByDate(Plan plan, Date date) {
  	var rules = plan.repeatability;
	  if (rules.range.from > date)
		  return false;
  	if (rules.type == RepeatabilityType.once && rules.range.from == date)
  		return true;
	  if (rules.type == RepeatabilityType.weekly && rules.days.contains(date.weekday))
		  return true;
	  if (rules.type == RepeatabilityType.monthly && rules.days.contains(date.day))
		  return true;
	  return false;
  }

	TranslateFunc buildPlanDescription(PlanRepeatability rules, {Date instanceDate, bool detailed = false}) {
  	return (context) {
		  var formatDate = (date) => DateFormat.yMd(Localizations.localeOf(context).toString()).format(date);
  		String description = '';
		  if (rules.untilCompleted && instanceDate != null)
			  description += AppLocales.of(context).translate('repeatability.startedOn', {'DAY': formatDate(instanceDate)});
		  else if (rules.type == RepeatabilityType.once)
		  	description += AppLocales.of(context).translate('repeatability.once', {'DAY': formatDate(rules.range.from)});
			else {
				String andWord = AppLocales.of(context).translate('and');
			  if (rules.type == RepeatabilityType.weekly) {
					List<String> weekdays = rules.days.map((day) => AppLocales.of(context).translate('repeatability.weekday', {'WEEKDAY': '$day'})).toList();
					String weekdayString = displayJoin(weekdays, andWord);
				  description += '${AppLocales.of(context).translate('repeatability.weekly', {'WEEKDAY': '${rules.days[0]}'})} $weekdayString';
			  }
			  else if (rules.type == RepeatabilityType.monthly) {
				  String dayString = displayJoin(rules.days.map((day) => '$day').toList(), andWord);
				  description += AppLocales.of(context).translate('repeatability.monthly', {'DAYS': dayString});
			  }
		  }
			if (!detailed)
				return description;
			if (rules.range.to != null)
		    description += ', ${AppLocales.of(context).translate('repeatability.range', {'FROM': formatDate(rules.range.from), 'TO': formatDate(rules.range.to)})}';
			if (rules.untilCompleted)
		  description += ', ${AppLocales.of(context).translate('repeatability.untilCompleted')}';
		  return description;
	  };
  }
}
