import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_template/core/form/cubit/form_cubit.dart';
import 'package:form_template/core/widgets/custom_button.dart';
import 'package:form_template/core/widgets/enums.dart';
import 'package:form_template/core/widgets/globals.dart';
import 'package:form_template/models/interface/data_model.dart';

class FormPageview extends StatefulWidget {
  final FormCubit formCubit;
  final DataModel dataModel;
  final List<WidgetConfig> fields;

  /// A function that takes the current form data and returns a new DataModel to rebuild the form with. This is useful for cases where the form structure or initial values need to change based on user input.
  final DataModel? Function(Map<String, dynamic> formData)? rebuildDataModel;

  ///optional parameter
  final List<CustomButton> actionButtons;
  final String? saveButtonText;
  final String? cancelButtonText;
  final VoidCallback? onCancel;
  final VoidCallback? onSaveSuccess;

  const FormPageview({
    super.key,
    required this.formCubit,
    required this.dataModel,
    required this.fields,
    this.rebuildDataModel,
    this.actionButtons = const [],
    this.saveButtonText,
    this.cancelButtonText,
    this.onCancel,
    this.onSaveSuccess,
  });

  @override
  State<FormPageview> createState() => _FormPageviewState();
}

class _FormPageviewState extends State<FormPageview> {
  //final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    // BlocProvider.value is the recommended way to provide an existing bloc/cubit instance to a subtree, especially when the instance is managed outside the subtree (like in your widget).
    return BlocProvider.value(
      value: widget.formCubit,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Globals.sidePadding),
            child: Column(
              spacing: Globals.formFieldGap,
              children: widget.fields
                  .where((field) {
                    if (field.isVisible != null) {
                      return field.isVisible!(_formData);
                    }
                    return true;
                  })
                  .map((field) {
                    return Placeholder();
                  })
                  .toList(),
            ),
          ),

          //save and cancel buttons
          Column(),
        ],
      ),
    );
  }
}

void getWidgetForFieldType(WidgetConfig fields) {}

//UI access Model so user can access easily
class WidgetConfig {
  final FieldType fieldType;
  final String key;
  final String? initialValue;
  final String? labelText;
  final IconData? icon;
  final double? iconSize;
  final bool? enabled;
  final bool? mandatory;
  final bool keepTextVisible; //globally access
  final bool Function(String)? isDuplicate;
  final TextCapitalization? textCapitalization;
  final bool Function(Map<String, dynamic> formData)? isVisible;

  const WidgetConfig({
    required this.fieldType,
    required this.key,
    this.initialValue,
    this.labelText,
    this.icon,
    this.iconSize,
    this.enabled,
    this.mandatory,
    this.keepTextVisible = false,
    this.isDuplicate,
    this.textCapitalization,
    this.isVisible,
  });
}

class ListingWidgetConfig extends WidgetConfig {
  final List<DataModel> items;
  final DataModel? initialData;
  final String? Function(DataModel?)? itemLabel;
  final SortBy? sortBy;
  final SortOrder? sortOrder;
  final List<DataModel> Function(Map<String, dynamic> formData)? itemsBuilder;
  final void Function(DataModel?, Map<String, dynamic>)? onChanged;
  final String? dialogFooterMessage;
  final String? emptyStateMessage;
  final IconData? emptyStateIcon;
  final bool enableTextFieldTap;

  ListingWidgetConfig({
    required super.key,
    super.initialValue,
    super.labelText,
    super.icon,
    super.iconSize,
    super.enabled,
    super.mandatory,
    super.keepTextVisible,
    required this.items,
    this.initialData,
    this.itemLabel,
    this.sortBy,
    this.sortOrder,
    this.itemsBuilder,
    this.onChanged,
    this.dialogFooterMessage,
    this.emptyStateMessage,
    this.emptyStateIcon,
    this.enableTextFieldTap = true,
    super.isVisible,
  }) : super(fieldType: FieldType.dropdown);
}

// Widget getWidgetForFieldType(WidgetConfig field) {
//   final fieldType = field.fieldType;
//   final key = field.key;
//   final initialValue = field.initialValue;
//   final labelText = field.labelText;
//   final enabled = field.enabled;
//   final mandatory = field.mandatory;
//   final icon = field.icon ?? Icons.text_fields_sharp;
//   final iconSize = field.iconSize ?? 20.0;
// }
