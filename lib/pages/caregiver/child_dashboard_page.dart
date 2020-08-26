import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:fokus/model/ui/award/ui_badge.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_bar_buttons.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/general/app_alert.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:smart_select/smart_select.dart';

class CaregiverChildDashboardPage extends StatefulWidget {
  @override
  _CaregiverChildDashboardPageState createState() =>
      new _CaregiverChildDashboardPageState();
}

class _CaregiverChildDashboardPageState extends State<CaregiverChildDashboardPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.childDashboard';
	TabController _tabController;
	int _currentIndex = 0;
	double customBottomBarHeight = 40;
	Duration bottomBarDuration = Duration(milliseconds: 300);

	// Mock-ups
	List<UIPlan> plans = [
		UIPlan(Mongo.ObjectId.fromHexString('fa7462a054295e915a20755d'), "Sprzątanie pokoju", true, 4, [], null),
		UIPlan(Mongo.ObjectId.fromHexString('30e8cf66a27822d4ea56f383'), "Odrabianie pracy domowej", true, 1, [], null),
		UIPlan(Mongo.ObjectId.fromHexString('c2248a28572d9f90a4f958f6'), "Inne bardzo długie zadanie, tekst tekst i tak dalej", true, 2, [], null)
	];
	List<UIPlan> pickedPlans = List<UIPlan>();

	List<UIBadge> badges = [
		UIBadge(name: "Król czegośtam", icon: 0),
		UIBadge(name: "ehhhhh", icon: 5),
		UIBadge(name: "Puchar planowicza", icon: 12),
	];
	List<UIBadge> pickedBadges = List<UIBadge>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value).round();
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: ItemCard(
							title: 'Maciek',
							subtitle: '2 plany na dziś',
							graphicType: GraphicAssetType.childAvatars,
							graphic: 16,
							chips: <Widget>[
								AttributeChip.withCurrency(content: '69420', currencyType: CurrencyType.amethyst)
							]
						),
						popupMenuWidget: PopupMenuList(
							lightTheme: true,
							items: [
								UIButton('$_pageKey.header.childCode', () => {}),
								UIButton.ofType(ButtonType.edit, () => {}),
								UIButton.ofType(ButtonType.unpair, () => {})
							],
						),
						tabs: TabBar(
							controller: _tabController,
							indicatorColor: Colors.white,
							indicatorWeight: 3.0,
							tabs: [
								Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.plans')),
								Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.awards')),
								Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.achievements'))
							]
						)
					),
					Expanded(
						child: TabBarView(
							controller: _tabController,
							children: [
								_buildPlansTab(),
								_buildAwardsTab(),
								_buildAchievementsTab()
							]
						)
					)
				]
			),
			bottomNavigationBar: AnimatedContainer(
				duration: bottomBarDuration,
				height: _currentIndex == 1 ? 0 : customBottomBarHeight,
				decoration: AppBoxProperties.elevatedContainer,
				child: SizedBox.shrink()
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
			floatingActionButton: AnimatedSwitcher(
				duration: bottomBarDuration,
				switchOutCurve: Curves.easeInOut,
				transitionBuilder: (child, animation) {
					return ScaleTransition(
						scale: animation,
						child: FadeTransition(
							opacity: animation,
							child: child
						)
					);
				},
				child: _currentIndex != 1 ? (_currentIndex == 0 ? _assignPlan() : _assignBadge()) : SizedBox.shrink()
			)
		);
	}
	
	Widget _buildFloatingButtonPicker<T>({
		String label, IconData buttonIcon, String disabledDialogTitle, String disabledDialogText,
		List<T> pickedValues, List<T> options,
		Function builder, Function(List<T>) onChange, Function(T) getName
	}) {
		bool buttonDisabled = options.isEmpty;
		return SmartSelect<T>.multiple(
			value: pickedValues,
			title: label,
			options: [
				for(T element in options)
					SmartSelectOption(
						title: getName(element),
						value: element
					)
			],
			onChange: (val) => onChange(val),
			modalType: SmartSelectModalType.bottomSheet,
			choiceConfig: SmartSelectChoiceConfig(builder: builder),
			modalConfig: SmartSelectModalConfig(
				trailing: ButtonSheetBarButtons(
					buttons: [
						UIButton('actions.confirm', () => { Navigator.pop(context) }, Colors.green, Icons.done)
					],
				)
			),
			builder: (context, state, function) {
				return FloatingActionButton.extended(
					heroTag: null,
					materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
					backgroundColor: buttonDisabled ? Colors.grey : AppColors.formColor,
					elevation: 4.0,
					icon: Icon(buttonIcon),
					label: Text(label),
					onPressed: () => buttonDisabled ?
						showBasicDialog(context,
							GeneralDialog.discard(
								title: disabledDialogTitle,
								content: disabledDialogText
							)
						) : function(context)
				);
			}
		);
	}

	Widget _assignPlan() {
		return _buildFloatingButtonPicker<UIPlan>(
			label: AppLocales.of(context).translate('$_pageKey.header.assignPlanButton'),
			buttonIcon: Icons.description,
			disabledDialogTitle: AppLocales.of(context).translate('$_pageKey.header.assignPlanButton'),
			disabledDialogText: 'Nie dodano jeszcze żadnego planu. Dodaj plan, aby móc przypisać go dziecku.',
			pickedValues: pickedPlans,
			options: plans,
			onChange: (val) => setState(() {
				pickedPlans = val;
			}),
			getName: (plan) => plan.name,
			builder: (item, checked, onChange) {
				return Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: item.title,
						subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
						icon: Padding(
							padding: EdgeInsets.all(6.0).copyWith(right: 0.0),
								child: CircleAvatar(
								backgroundColor: checked ? Colors.green : Colors.grey,
								radius: 16.0,
								child: Icon(checked ? Icons.check : Icons.remove, color: Colors.white, size: 20.0)
							)
						),
						onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
						isActive: checked
					)
				);
			}
		);
	}

	Widget _assignBadge() {
		return _buildFloatingButtonPicker<UIBadge>(
			label: AppLocales.of(context).translate('$_pageKey.header.assignBadgeButton'),
			buttonIcon: Icons.star,
			disabledDialogTitle: AppLocales.of(context).translate('$_pageKey.header.assignBadgeButton'),
			disabledDialogText: 'Lista możliwych do przyznania odznak jest pusta. Dodaj odznakę, aby móc przydzielić ją dziecku.',
			pickedValues: pickedBadges,
			options: badges,
			onChange: (val) => setState(() {
				pickedBadges = val;
			}),
			getName: (badge) => badge.name,
			builder: (item, checked, onChange) {
				return Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: item.title,
						subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
						graphic: item.value.icon,
						graphicType: GraphicAssetType.badgeIcons,
						graphicShowCheckmark: checked,
						graphicHeight: 40.0,
						onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
						isActive: checked
					)
				);
			}
		);
	}

	Widget _buildPlansTab() {
		return ListView(
			padding: EdgeInsets.zero,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				// Show only if there are not rated tasks
				AppAlert(
					text: 'Istnieją nieocenione zadania. Odwiedź stronę oceniania, aby przynać punkty za wykonane zadania.',
					onTap: () { /* Go to rating page */ },
				),
				// Show only if there are no plans added
				AppAlert(
					text: 'Nie dodano jeszcze żadnego planu. Dodaj plan, aby móc przypisać go dziecku.',
					onTap: () { /* Go to plans page */ },
				),
				Segment(
					title: '$_pageKey.content.plansTitle',
					noElementsMessage: '$_pageKey.content.noPlansText',
					noElementsIcon: Icons.description,
					noElementsAction: FlatButton(
						onPressed: () {},
						child: Text(AppLocales.of(context).translate('$_pageKey.content.openCalendarButton')),
						color: AppColors.caregiverButtonColor,
						textColor: AppColors.lightTextColor,
					),
					elements: [
						ItemCard(
							title: 'Sprzątanie pokoju',
							subtitle: 'Rozpoczęty',
							chips: [
								AttributeChip.withIcon(
									content: 'Wykonano 2/3',
									color: Colors.lightGreen,
									icon: Icons.layers
								)
							],
							isActive: true,
							progressPercentage: 0.33
						),
						ItemCard(
							title: 'Jakiś inny plan',
							subtitle: 'Oczekujący'
						),
					]
				),
				SizedBox(height: 30.0)
			]
		);
	}

	Widget _buildAwardsTab() {
		return ListView(
			padding: EdgeInsets.zero,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				// Show only if there are no awards child can buy
				AppAlert(
					text: 'Lista możliwych do kupienia nagród jest pusta. Dodaj nagrodę, aby dziecko mogo ją zdobyć.',
					onTap: () => { /* Go to award/badge list page */ },
				),
				Segment(
					title: '$_pageKey.content.awardsTitle',
					noElementsMessage: '$_pageKey.content.noAwardsText',
					elements: [
						ItemCard(
							title: "Wycieczka do Zoo", 
							subtitle: "Odebrano dnia 25.08.2020 18:34",
							graphicType: GraphicAssetType.awardsIcons,
							graphic: 16,
							chips: <Widget>[
								AttributeChip.withCurrency(content: "30", currencyType: CurrencyType.diamond)
							],
						)
					]
				)
			]
		);
	}

	Widget _buildAchievementsTab() {
		return ListView(
			padding: EdgeInsets.zero,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				// Show only if there are no badges child can get
				AppAlert(
					text: 'Lista możliwych do przyznania odznak jest pusta. Dodaj odznakę, aby móc przydzielić ją dziecku.',
					onTap: () => { /* Go to award/badge list page */ },
				),
				Segment(
					title: '$_pageKey.content.achievementsTitle',
					noElementsMessage: '$_pageKey.content.noAchievementsText',
					noElementsIcon: Icons.star,
					elements: [
						// ItemCard(
						// 	title: "Super planista", 
						// 	subtitle: "Przyznano dnia 26.08.2020 20:10",
						// 	graphicType: GraphicAssetType.badgeIcons,
						// 	graphic: 3,
						// 	graphicHeight: 44.0,
						// )
					]
				)
			]
		);
	}

}
