import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fokus/model/currency_type.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/theme_config.dart';

class AttributeChip extends StatelessWidget {
	final String content;
	final Color color;
	final Widget icon;
	final String tooltip;

	final Color defaultColor = Colors.grey[200];

	AttributeChip({this.content, this.color, this.icon, this.tooltip});

	AttributeChip.withIcon({
		String content,
		Color color,
		IconData icon,
		String tooltip
	}) : this(
		content: content,
		color: color,
		icon: (icon != null) ? Icon(icon, size: 22, color: color) : null,
		tooltip: tooltip
	);

	AttributeChip.withCurrency({
		String content,
		CurrencyType currencyType,
		String tooltip
	}) : this(
		content: content,
		color: AppColors.currencyColor[currencyType],
		icon: SvgPicture.asset(currencySvgPath(currencyType), width: 22, fit: BoxFit.cover),
		tooltip: tooltip
	);

	@override
	Widget build(BuildContext context) {
		return Tooltip(
			message: (tooltip != null) ? AppLocales.of(context).translate(tooltip) : 
				(content != null) ? content : AppLocales.of(context).translate('alert.noHint'),
			child: Chip(
				avatar: icon,
				materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
				backgroundColor: (color != null) ? color.withAlpha(30) : defaultColor, 
				labelPadding: (content != null) ? EdgeInsets.only(left: (icon != null) ? 3.0 : 6.0, right: 6.0) : EdgeInsets.zero,
				label: (content != null) ? Text(
					content, 
					style: TextStyle(color: color, fontWeight: FontWeight.bold),
					overflow: TextOverflow.fade,
				) : SizedBox(width: 0),
				visualDensity: VisualDensity.compact
			)
		);
	}

}