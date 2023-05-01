/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:card_settings/card_settings.dart';
import 'package:card_settings/interfaces/minimum_field_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardFieldLayoutBase extends StatelessWidget implements CardSettingsWidget {
  const CardFieldLayoutBase({
    super.key,
    this.visible = true,
    this.showMaterialonIOS,
    required this.child,
  });

  final Widget child;

  /// Force the widget to use Material style on an iOS device
  @override
  final bool? showMaterialonIOS;

  /// If false hides the widget on the card setting panel
  @override
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const Offstage();
    return child;
  }
}

class CardFieldLayout2 extends StatelessWidget implements CardSettingsWidget {
  const CardFieldLayout2(
      this.children, {super.key,
        this.flexValues,
        this.visible = true,
        this.showMaterialonIOS,
      });

  /// the field widgets to place into the layout
  final List<Widget> children;

  /// the values that control the relative widths of the layed out widgets
  final List<int>? flexValues;

  /// Force the widget to use Material style on an iOS device
  @override
  final bool? showMaterialonIOS;

  /// If false hides the widget on the card setting panel
  @override
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 18),
      child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
      ),
    );
  }
}

class CardSettingsDescription extends StatelessWidget
    implements CardSettingsWidget {

  const CardSettingsDescription({super.key,
    this.text = 'Description here...',
    this.title,
    this.backgroundColor,
    this.textColor,
    this.showMaterialonIOS,
    this.visible = true,
    this.fieldPadding,
  });

  final String? title;

  /// The text for the instructions
  final String text;

  /// the color for the background
  final Color? backgroundColor;

  /// The color of the text
  final Color? textColor;

  /// Force the widget to use Material style on an iOS device
  @override
  final bool? showMaterialonIOS;

  /// If false hides the widget on the card setting panel
  @override
  final bool visible;

  /// padding to place around then entire field
  final EdgeInsetsGeometry? fieldPadding;

  @override
  Widget build(BuildContext context) {
    if (!visible) return Container();
    var textTheme = Theme.of(context).textTheme;
    //TextStyle titleStyle = textTheme.labelLarge!;
    TextStyle labelStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
    );
    TextStyle titleStyle = labelStyle.merge(Theme.of(context).inputDecorationTheme.labelStyle);
    TextStyle textStyle = textTheme.bodyLarge!;
    EdgeInsetsGeometry padding = (fieldPadding ??
        CardSettings.of(context)?.fieldPadding ??
        const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5));

    return Container(
      margin: const EdgeInsets.all(0.0),
      decoration:
      BoxDecoration(color: backgroundColor ?? Theme.of(context).cardColor),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title!=null)
            Text(
              title!,
              style: titleStyle,
            ),
          if (title!=null)
            const SizedBox(height: 5),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  text,
                  style: textStyle,
                  softWrap: true,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CardSettingsButton2 extends StatelessWidget
    implements IMinimumFieldSettings {
  const CardSettingsButton2({super.key,
    required this.label,
    required this.onPressed,
    this.visible = true,
    this.backgroundColor,
    this.textColor,
    this.enabled = true,
    this.bottomSpacing = 0.0,
    this.isDestructive = false,
    this.showMaterialonIOS,
  });

  /// The text to place in the button
  final String label;

  /// tells the Ui the button is destructive. Helps select color.
  final bool isDestructive;

  /// The background color for normal buttons
  final Color? backgroundColor;

  /// The text color for normal buttons
  final Color? textColor;

  /// allows adding extra padding at the bottom
  final double bottomSpacing;

  /// If false, grays out the field and makes it unresponsive
  final bool enabled;

  /// Force the widget to use Material style on an iOS device
  @override
  final bool? showMaterialonIOS;

  /// If false hides the widget on the card setting panel
  @override
  final bool visible;

  /// Fires when the button is pressed
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    TextStyle buttonStyle =
    Theme.of(context).textTheme.labelLarge!.copyWith(color: textColor);

    if (visible) {
      return _showMaterialButton(context, buttonStyle);
    } else {
      return Container();
    }
  }

  Widget _showMaterialButton(BuildContext context, TextStyle buttonStyle) {
    var style = Theme.of(context).textButtonTheme.style ?? const ButtonStyle();
    if (backgroundColor != null) {
      style = style.copyWith(
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor!));
    }
    if (textColor != null) {
      style = style.copyWith(
          foregroundColor: MaterialStateProperty.all<Color>(textColor!));
    }
    if (!enabled) {
      style = style.copyWith(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey));
    }

    return TextButton(
      style: style,
      onPressed: (enabled)
          ? onPressed
          : null,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Text(
          label,
        ),
      ), // to disable, we need to not provide an onPressed function
    );
  }
}

class CardSettingsInt2 extends CardSettingsText  {
  CardSettingsInt2({
    Key? key,
    String label = 'Label',
    TextAlign? labelAlign,
    double? labelWidth,
    TextAlign? contentAlign,
    String? hintText,
    int initialValue = 0,
    Icon? icon,
    Widget? requiredIndicator,
    String? unitLabel,
    int maxLength = 10,
    bool visible = true,
    bool enabled = true,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldValidator<int>? validator,
    FormFieldSetter<int>? onSaved,
    ValueChanged<int?>? onChanged,
    TextEditingController? controller,
    FocusNode? focusNode,
    TextInputAction? inputAction,
    FocusNode? inputActionNode,
    TextInputType? keyboardType,
    TextStyle? style,
    MaxLengthEnforcement? maxLengthEnforcement = MaxLengthEnforcement.enforced,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? showMaterialonIOS,
    EdgeInsetsGeometry? fieldPadding,
    bool allowNegative = false,
  }) : super(
    key: key,
    label: label,
    hintText: hintText,
    labelAlign: labelAlign,
    labelWidth: labelWidth,
    showMaterialonIOS: showMaterialonIOS,
    contentAlign: contentAlign,
    initialValue: initialValue.toString(),
    unitLabel: unitLabel,
    icon: icon,
    requiredIndicator: requiredIndicator,
    maxLength: maxLength,
    visible: visible,
    enabled: enabled,
    autofocus: autofocus,
    obscureText: obscureText,
    autocorrect: autocorrect,
    autovalidateMode: autovalidateMode,
    fieldPadding: fieldPadding,
    validator: (value) {
      if (validator == null) return null;
      return validator(int.tryParse(value ?? 'null'));
    },
    onSaved: (value) {
      if (onSaved == null) return;
      onSaved(int.tryParse(value ?? 'null'));
    },
    onChanged: (value) {
      if (onChanged == null) return;
      onChanged(int.tryParse(value));
    },
    controller: controller,
    focusNode: focusNode,
    inputAction: inputAction,
    inputActionNode: inputActionNode,
    keyboardType: keyboardType ?? TextInputType.numberWithOptions(decimal: false, signed: allowNegative),
    style: style,
    maxLengthEnforcement: maxLengthEnforcement,
    onFieldSubmitted: onFieldSubmitted,
    inputFormatters: [
      LengthLimitingTextInputFormatter(maxLength),
      FilteringTextInputFormatter.allow(RegExp(allowNegative ? "^-?[0-9]*" : "[0-9]+")),
    ],
  );
}
