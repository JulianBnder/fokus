import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/logic/common/formz_state.dart';

class AuthenticationInputField<Bloc extends Cubit<State>, State extends FormzState> extends StatelessWidget {
	final List<dynamic> Function(State) getErrorKey;
	final FormzInput Function(State) getField;
	final Function(Bloc, String) changedAction;

	final String labelKey;
	final TextInputType inputType;
	final bool hideInput;
	final IconData icon;

  AuthenticationInputField({
		this.getField,
		this.changedAction,
		this.labelKey,
		this.getErrorKey,
		this.inputType = TextInputType.text,
		this.hideInput = false,
		this.icon = Icons.edit
	});
	
  @override
  Widget build(BuildContext context) {
	  return BlocBuilder<Bloc, State>(
		  buildWhen: (previous, current) => getField(previous).status != getField(current).status,
		  builder: (context, state) {
			  return Padding(
			    padding: const EdgeInsets.all(8.0),
			    child: TextField(
					  onChanged: (value) => changedAction(context.bloc<Bloc>(), value),
					  keyboardType: inputType,
					  obscureText: hideInput,
						decoration: InputDecoration(
							icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(icon)),
							contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
							border: OutlineInputBorder(),
							labelText: AppLocales.of(context).translate(labelKey),
						  errorText: getField(state).invalid ? Function.apply(AppLocales.of(context).translate, getErrorKey(state)) : null,
						)
			    ),
			  );
		  },
	  );
  }
}
