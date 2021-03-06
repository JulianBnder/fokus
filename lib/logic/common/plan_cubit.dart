import 'package:flutter/material.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/task/ui_task.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanCubit extends ReloadableCubit {
	final ObjectId _planId;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  PlanCubit( this._planId, ModalRoute pageRoute) : super(pageRoute);

  @override
  doLoadData() async {
		var getDescription = (Plan plan) => _repeatabilityService.buildPlanDescription(plan.repeatability);
		Plan plan = await _dataRepository.getPlan(id: _planId);
		var children = await _dataRepository.getUserNames(plan.assignedTo);
		List<Task> tasks = await _dataRepository.getTasks(planId: _planId);
		emit(CaregiverTasksLoadSuccess(UIPlan.fromDBModel(plan, getDescription(plan)), tasks.map((task) => UITask.fromDBModel(task: task)).toList(), children));
	}

	Future deletePlan() async {
		var instances = await _dataRepository.getPlanInstances(planId: _planId, fields: ['_id']);
		return Future.wait([
			_dataRepository.removePlans(ids: [_planId]),
			_dataRepository.removePlanInstances(planId: _planId),
			_dataRepository.removeTasks(planIds: [_planId]),
			_dataRepository.removeTaskInstances(planInstancesIds: instances.map((plan) => plan.id).toList()),
		]);
	}
}

class CaregiverTasksLoadSuccess extends DataLoadSuccess{
	final UIPlan uiPlan;
	final List<UITask> tasks;
	final Map<ObjectId, String> children;

  CaregiverTasksLoadSuccess(this.uiPlan, this.tasks, this.children);

  @override
  List<Object> get props => [uiPlan, tasks];
}
