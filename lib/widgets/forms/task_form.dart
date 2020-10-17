import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:fokus/logic/caregiver/plan_form/plan_form_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/back_icon_button.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/forms/pointpicker_field.dart';

class TaskForm extends StatefulWidget {
	final TaskFormModel task;
	final Function createTaskCallback;
	final Function removeTaskCallback;
	final Function saveTaskCallback;

	TaskForm({
		@required this.task,
		this.createTaskCallback,
		this.removeTaskCallback,
		this.saveTaskCallback
	});

	@override
	_TaskFormState createState() => new _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
	static const String _pageKeyTaskForm = 'page.caregiverSection.taskForm';
	static const String _pageKeyPlanForm = 'page.caregiverSection.planForm';

	GlobalKey<FormState> taskFormKey;
	bool isDataChanged = false;
	bool wereSubtasksLoaded = false;
	TaskFormModel task;
	int maxSubtasks = 10;

	List<TextFormField> _subtasks = [];

	TextEditingController _titleController = TextEditingController();
	TextEditingController _descriptionController = TextEditingController();
	TextEditingController _pointsController = TextEditingController();

	bool formModeIsCreate() => widget.task == null;

	@override
  void initState() {
		taskFormKey = GlobalKey<FormState>();
		task = TaskFormModel(
			key: ValueKey(DateTime.now().toString()),
			pointCurrency: UICurrency(type: CurrencyType.diamond)
		);

		if(!formModeIsCreate())
			task.copy(widget.task);

		if(widget.task != null) {
			_titleController.text = widget.task.title;
			_descriptionController.text = widget.task.description;
			_pointsController.text = widget.task.pointsValue != null ? widget.task.pointsValue.toString() : null;
		}
    super.initState();
  }
	
	@override
  void dispose() {
		_titleController.dispose();
		_descriptionController.dispose();
		_pointsController.dispose();
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () => showExitFormDialog(context, true, isDataChanged),
			child: Scaffold(
				body: Stack(
					children: [
						Positioned.fill(
							bottom: AppBoxProperties.standardBottomNavHeight,
							child: Form(
								key: taskFormKey,
								child: Material(
									child: Column(
										children:[ 
											buildCustomHeader(),
											Expanded(child: buildFormFields())
										]
									)
								)
							)
						),
						Positioned.fill(
							top: null,
							child: buildBottomNavigation()
						)
					]
				)
			)
		);
	}

	void showDeleteTaskDialog() {
		showBasicDialog(
			context,
			GeneralDialog.confirm(
				title: AppLocales.of(context).translate('$_pageKeyTaskForm.removeTaskTitle'),
				content: AppLocales.of(context).translate('$_pageKeyTaskForm.removeTaskText'),
				confirmColor: Colors.red,
				confirmText: '$_pageKeyTaskForm.removeTaskTitle',
				confirmAction: () {
					Future.wait([
						Future(widget.removeTaskCallback())
					]);
					Navigator.of(context).pop();
					Navigator.of(context).pop();
				}
			)
		);
	}

	void saveTask() {
		if(taskFormKey.currentState.validate()) {
			setState(() {
				task.subtasks = _subtasks.where((subtask) => subtask.controller.text.isNotEmpty).toList().map((subtask) => subtask.controller.text).toList();
			});
			if(formModeIsCreate())
				Future.wait([
					Future(widget.createTaskCallback(task))
				]);
			else
				Future.wait([
					Future(widget.saveTaskCallback(task))
				]);
			Navigator.of(context).pop();
		}
	}

	Widget buildCustomHeader() {
		bool hasTitle = !formModeIsCreate() && task.title != null && task.title.length > 0;
		double appBarVerticalPadding = hasTitle ? 8.0 : 12.0;
		return Material(
			elevation: 4.0,
			color: AppColors.formColor,
			child: Container(
				child: SafeArea(
					child: ListTile(
						dense: true,
						contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
						trailing: HelpIconButton(helpPage: 'task_creation'),
						leading: BackIconButton(exitCallback: () => showExitFormDialog(context, false, isDataChanged)),
						title: Padding(
							padding: EdgeInsets.only(top: appBarVerticalPadding, bottom: appBarVerticalPadding, left: 4.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									AnimatedDefaultTextStyle(
										duration: Duration(milliseconds: 200),
										child: Text(AppLocales.of(context).translate('$_pageKeyPlanForm.${formModeIsCreate() ? 'addTaskButton' : 'editTaskButton'}')), 
										style: hasTitle ?
											Theme.of(context).textTheme.bodyText1 :
											Theme.of(context).textTheme.headline3.copyWith(color: Colors.white, fontSize: 20.0)
									),
									AnimatedSwitcher(
										duration: Duration(milliseconds: 400),
										transitionBuilder: (child, animation) {
											return SizeTransition(
												sizeFactor: animation,
												axisAlignment: 1,
												axis: Axis.vertical,
												child: child
											);
										},
										child: hasTitle ?
											Hero(
												tag: formModeIsCreate() ? "none3463634634" : widget.task.key,
												child: Text(
													task.title,
													style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white),
													overflow: TextOverflow.fade,
													softWrap: false,
													maxLines: 1
												)
											)
											: SizedBox.shrink()
									)
								]
							)
						)
					)
				)
			)
		);
	}

	Widget buildBottomNavigation() {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
			decoration: AppBoxProperties.elevatedContainer,
			height: AppBoxProperties.standardBottomNavHeight,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					!formModeIsCreate() ?
						FlatButton(
							onPressed: () => showDeleteTaskDialog(),
							textColor: Colors.red,
							child: Row(
								children: <Widget>[
									Icon(Icons.close),
									Text(AppLocales.of(context).translate('$_pageKeyPlanForm.removeTaskButton'))
								]
							)
						)
						: SizedBox.shrink(),
					FlatButton(
						onPressed: () => saveTask(),
						child: Row(
							children: <Widget>[
								Hero(
									tag: formModeIsCreate() ? "newTaskDialog" : "none12345235",
									child: Text(
										AppLocales.of(context).translate('$_pageKeyPlanForm.${formModeIsCreate() ? 'addTaskButton' : 'saveTaskButton'}'),
										style: Theme.of(context).textTheme.button.copyWith(color: AppColors.mainBackgroundColor)
									)
								)
							]
						)
					)
				]
			)
		);
	}

	Widget buildFormFields() {
		return ListView(
			shrinkWrap: true,
			children: <Widget>[
				buildNameField(),
				buildDescriptionField(),
				buildSubtasksFields(),
				buildPointsFields(),
				buildTimerField(),
				Divider(),
				buildOptionalField(),
				if(!formModeIsCreate())
					SizedBox(height: 32.0) 
			]
		);
	}

	Widget buildNameField() {
		return Padding(
			padding: EdgeInsets.only(top: 0.0, bottom: 6.0, left: 20.0, right: 20.0),
			child: TextFormField(
				autofocus: formModeIsCreate(),
				controller: _titleController,
				decoration: AppFormProperties.textFieldDecoration(Icons.edit).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskName.label')
				),
				maxLength: AppFormProperties.textFieldMaxLength,
				textCapitalization: TextCapitalization.sentences,
				validator: (value) {
					return value.trim().isEmpty ? AppLocales.of(context).translate('alert.genericEmptyValue') : null;
				},
				onChanged: (val) => setState(() {
					isDataChanged = task.title != val;
					task.title = val;
				})
			)
		);
	}

	Widget buildDescriptionField() {
		return Padding(
			padding: EdgeInsets.only(top: 5.0, bottom: 6.0, left: 20.0, right: 20.0),
			child: TextFormField(
				controller: _descriptionController,
				decoration: AppFormProperties.longTextFieldDecoration(Icons.description).copyWith(
					labelText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskDescription.label')
				),
				maxLength: AppFormProperties.longTextFieldMaxLength,
				minLines: AppFormProperties.longTextMinLines,
				maxLines: AppFormProperties.longTextMaxLines,
				textCapitalization: TextCapitalization.sentences,
				onChanged: (val) => setState(() {
					isDataChanged = task.description != val;
					task.description = val;
				}),
			)
		);
	}

	Widget buildSubtasksFields() {
		if(!wereSubtasksLoaded && widget.task != null && widget.task.subtasks != null) {
			_subtasks = List.from(
				widget.task.subtasks.map((subtask) {
					var controller = TextEditingController();
					controller.text = subtask;
					return _getSubtaskFormField(controller);
				})
			);
			setState(() {
			  wereSubtasksLoaded = true;
			});
		}
		return Padding(
			padding: EdgeInsets.only(top: 5.0, bottom: 6.0, left: 20.0, right: 20.0),
			child:
				Column(
					children: [
						for (var subtask in _subtasks)
							Padding(
							  padding:  EdgeInsets.only(top: 5.0, bottom: 6.0),
							  child: subtask,
							),
						if (_subtasks.length < maxSubtasks)
							Padding(
							  padding: EdgeInsets.only(top: 5.0, bottom: 6.0),
							  child: Row(
							  	mainAxisAlignment: MainAxisAlignment.end,
							    children: [
							      Expanded(
							        child: InputDecorator(
							  			decoration: AppFormProperties.textFieldDecoration(Icons.add),
							  			child: FlatButton(onPressed: _addSubtask, child: Text("Dodaj podzadanie"),)
							  		),
							      ),
							    ],
							  ),
							)
					],
			)
		);
	}

	Widget buildPointsFields() {
		return BlocBuilder<PlanFormCubit, PlanFormState>(
			cubit: context.bloc<PlanFormCubit>(),
			builder: (context, state) {
				if (state is PlanFormDataLoadSuccess)
					return getPointsFields(currencies: state.currencies);
				return getPointsFields(currencies: [UICurrency(type: CurrencyType.diamond)], loading: state.formType == AppFormType.create);
			}
		);
	}
	
	Widget getPointsFields({List<UICurrency> currencies = const [], bool loading = false}) {
		return PointPickerField(
			controller: _pointsController,
			pickedCurrency: task.pointCurrency,
			currencies: currencies,
			loading: loading,
			labelValueText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.valueLabel'),
			helperValueText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.hint'),
			labelCurrencyText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskPoints.currencyLabel'),
			pointValueSetter: (val) {
				setState(() {
					isDataChanged = task.pointsValue != int.tryParse(val);
					task.pointsValue = int.tryParse(val);
				});
			},
			pointCurrencySetter: (val) {
				setState(() {
					isDataChanged = task.pointCurrency != val;
					task.pointCurrency = val;
				});
			},
		);
	}

	Widget buildTimerField() {
		return Padding(
			padding: EdgeInsets.only(top: 12.0),
			child: ListTile(
				contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
				leading: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.timer)),
				title: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.label')),
				subtitle: (task.timer == 0) ?
					Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.notSet'))
					: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.set') + ' ' 
						+ AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.format', {
						'HOURS_NUM': (task.timer ~/ 60).toString(),
						'MINUTES_NUM': (task.timer % 60).toString()
					})),
				trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
				onTap: () {
					FocusManager.instance.primaryFocus.unfocus();
					showTimerPickerDialog();
				}
			)
		);
	}

	void showTimerPickerDialog() {
		Picker(
			adapter: NumberPickerAdapter(data: [
				NumberPickerColumn(
					begin: 0, 
					end: 23, 
					suffix: Padding(
						padding: EdgeInsets.only(left: 4.0, top: 4.0),
						child: Text(
							AppLocales.of(context).translate('hour'),
							style: TextStyle(fontSize: 15.0, color: Colors.grey)
						)
					)
				),
				NumberPickerColumn(
					begin: 0,
					end: 59,
					suffix: Padding(
						padding: EdgeInsets.only(left: 4.0, top: 2.0),
						child: Text(
							AppLocales.of(context).translate('minute'),
							style: TextStyle(fontSize: 15.0, color: Colors.grey)
						)
					)
				)
			]),
			selecteds: [task.timer ~/ 60, task.timer % 60],
			itemExtent: 40.0,
			height: 120.0,
			looping: true,
			hideHeader: true,
			title: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskTimer.label')),
			onConfirm: (Picker picker, List value) {
				var times = picker.getSelectedValues();
				var timeInMinutes = times[0]*60 + times[1];
				setState(() => task.timer = timeInMinutes);
			},
			confirmText: AppLocales.of(context).translate('actions.confirm'),
			onCancel: () => {},
			cancel: Wrap(
				spacing: 6.0,
				children: <Widget>[
					FlatButton(
						textColor: Colors.red,
						child: Text(AppLocales.of(context).translate('actions.clear')),
						onPressed: () {
							setState(() => task.timer = 0);
							Navigator.of(context).pop();
						}
					),
					FlatButton(
						child: Text(AppLocales.of(context).translate('actions.cancel')),
						onPressed: () {
							Navigator.of(context).pop();
						}
					)
				]
			),
			footer: SizedBox.shrink()
		).showDialog(context);
	}

	Widget buildOptionalField() {
		return Padding(
			padding: EdgeInsets.only(top: 12.0),
			child: SwitchListTile(
				value: task.optional,
				title: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskOptional.label')),
				subtitle: Text(AppLocales.of(context).translate('$_pageKeyTaskForm.fields.taskOptional.hint')),
				secondary: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.unfold_more)),
				onChanged: (val) => setState(() => task.optional = val)
			)
		);
	}

	void _addSubtask({String text}) {
		TextEditingController controller = TextEditingController();
		if(text != null) controller.text = text;
		FocusManager.instance.primaryFocus.unfocus();
		setState(() {
			_subtasks.add(_getSubtaskFormField(controller));
		});
	}

	TextFormField _getSubtaskFormField(TextEditingController controller) {
		return TextFormField(controller: controller,
			autofocus: wereSubtasksLoaded,
			decoration: AppFormProperties.textFieldDecoration(Icons.blur_circular).copyWith(
				labelText: AppLocales.of(context).translate('$_pageKeyTaskForm.fields.subtaskDescription.label'),
				suffixIcon: IconButton(
					onPressed: () {
						setState(() {
							_subtasks.removeWhere((element) => element.controller == controller);
							isDataChanged = true;
						});
					},
					icon: Icon(Icons.delete)
				)
			),
			maxLength: AppFormProperties.textFieldMaxLength,
			textCapitalization: TextCapitalization.sentences,
			onChanged: (val) => setState(() => isDataChanged = true),
		);
	}
}
