import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/caregiver_awards_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';

import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class CaregiverAwardsPage extends StatefulWidget {
	@override
	_CaregiverAwardsPageState createState() => new _CaregiverAwardsPageState();
}

class _CaregiverAwardsPageState extends State<CaregiverAwardsPage> {
	static const String _pageKey = 'page.caregiverSection.awards';
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: CustomAppBar(type: CustomAppBarType.normal, title: '$_pageKey.header.title', subtitle: '$_pageKey.header.pageHint', icon: Icons.stars),
			body: LoadableBlocBuilder<CaregiverAwardsCubit>(
				builder: (context, state) => AppSegments(segments: _buildPanelSegments(state, context), fullBody: true),
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}

	void _deleteReward(Mongo.ObjectId id) {
		BlocProvider.of<CaregiverAwardsCubit>(context).removeReward(id);
		Navigator.of(context).pop(); // closing confirm dialog before pushing snackbar
		showSuccessSnackbar(context, '$_pageKey.content.rewardRemovedText');
	}

	void _deleteBadge(UIBadge badge) {
		BlocProvider.of<CaregiverAwardsCubit>(context).removeBadge(badge);
		Navigator.of(context).pop(); // closing confirm dialog before pushing snackbar
		showSuccessSnackbar(context, '$_pageKey.content.badgeRemovedText');
	}

	List<Segment> _buildPanelSegments(CaregiverAwardsLoadSuccess state, BuildContext context) {
		return [
			Segment(
				title: '$_pageKey.content.addedRewardsTitle',
				subtitle: '$_pageKey.content.addedRewardsSubtitle',
				headerAction: UIButton('$_pageKey.header.addReward', () => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name), AppColors.caregiverButtonColor, Icons.add),
				noElementsMessage: '$_pageKey.content.noRewardsAdded',
				elements: <Widget>[
					for (var reward in state.rewards)
						RewardItemCard(
							reward: reward,
							menuItems: [
								UIButton.ofType(ButtonType.edit, () => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name, arguments: reward.id), null, Icons.edit),
								UIButton.ofType(ButtonType.delete, () {
									showBasicDialog(
										context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('$_pageKey.content.removeRewardTitle'),
											content: AppLocales.of(context).translate('$_pageKey.content.removeRewardText'),
											confirmColor: Colors.red,
											confirmText: 'actions.delete',
											confirmAction: () => _deleteReward(reward.id)
										)
									);
								}, null, Icons.delete)
							],
							onTapped: () => showRewardDialog(context, reward, showHeader: false),
						)
				]
			),
			Segment(
				title: '$_pageKey.content.addedBadgesTitle',
				subtitle: '$_pageKey.content.addedBadgesSubtitle',
				headerAction: UIButton('$_pageKey.header.addBadge', () => Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name), AppColors.caregiverButtonColor, Icons.add),
				noElementsMessage: '$_pageKey.content.noBadgesAdded',
				elements: <Widget>[
					for (var badge in state.badges)
						ItemCard(
							title: badge.name, 
							subtitle: badge.description != null ? badge.description : AppLocales.of(context).translate('$_pageKey.content.noDescriptionSubtitle'),
							menuItems: [
								UIButton.ofType(ButtonType.delete, () {
									showBasicDialog(context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('$_pageKey.content.removeBadgeTitle'),
											content: AppLocales.of(context).translate('$_pageKey.content.removeBadgeText'),
											confirmColor: Colors.red,
											confirmText: 'actions.delete',
											confirmAction: () => _deleteBadge(badge)
										)
									);
								}, null, Icons.delete)
							],
							onTapped: () => showBadgeDialog(context, badge, showHeader: false),
							graphicType: AssetType.badges,
							graphic: badge.icon,
							graphicHeight: 44.0
						)
				]
			)
		];
	}
}
