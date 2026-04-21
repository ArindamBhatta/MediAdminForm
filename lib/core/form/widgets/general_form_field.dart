import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FormFieldView extends StatefulWidget {
  final String? initialValue;
  final String? errorText;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final String labelText;
  final bool? enabled;
  final bool? mandatory;
  final bool keepTextVisible;
  final IconData icon;
  final TextInputType keyboardType;
  final double iconSize;
  final bool isPassword;
  final TextCapitalization textCapitalization;
  late final String? Function(String?)? _validate;

  FormFieldView({
    super.key,
    this.initialValue,
    this.errorText,
    this.onChanged,
    this.onSaved,
    required this.labelText,
    this.enabled = true,
    this.mandatory = true,
    this.keepTextVisible = false,
    this.icon = FontAwesomeIcons.pen,
    this.keyboardType = TextInputType.text,
    this.iconSize = 22,
    this.isPassword = false,
    this.textCapitalization = TextCapitalization.none,
    String? Function(String?)? validate,
  }) {
    _validate =
        validate ??
        ((value) {
          if (mandatory ?? true) {
            if (value == null || value.trim().isEmpty) {
              return '$labelText is required';
            }
          }
          return null;
        });
  }

  factory FormFieldView.name({
    Key? key,
    String? initialValue,
    String? labelText,
    bool? enable = true,
    bool? mandatory = true,
    TextCapitalization? textCapitalization,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
  }) {
    return FormFieldView(
      key: key,
      initialValue: initialValue,
      onChanged: onChanged,
      labelText: labelText ?? 'Name',
      mandatory: mandatory,
      textCapitalization: textCapitalization ?? TextCapitalization.words,
      onSaved: onSaved,
      enabled: enable,
    );
  }

  factory FormFieldView.address({
    Key? key,
    String? initialValue,
    String? labelText,
    bool? enable = true,
    bool? mandatory = true,
    TextCapitalization? textCapitalization,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
  }) {
    return FormFieldView(
      key: key,
      initialValue: initialValue,
      onChanged: onChanged,
      labelText: labelText ?? 'Address',
      mandatory: mandatory,
      textCapitalization: textCapitalization ?? TextCapitalization.sentences,
      onSaved: onSaved,
      enabled: enable,
    );
  }

  @override
  State<FormFieldView> createState() => _FormFieldViewState();
}

class _FormFieldViewState extends State<FormFieldView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
