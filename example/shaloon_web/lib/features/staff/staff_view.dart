import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../../domain/models/staff_model.dart';

/// Detail view shown in the right pane when a staff member is selected.
/// Developer writes only this; list, search, add-dialog come from framework.
class StaffDetailView extends StatelessWidget {
  final StaffModel staff;

  const StaffDetailView({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return FormPageView(
      formCubit: BlocProvider.of<FormCubit<StaffModel>>(context),
      dataModel: staff,
      rebuildDataModel: (data) => StaffModel(
        id: data['id'] as String?,
        name: data['name'] as String?,
        role: data['role'] as String?,
        mobile: data['mobile'] as String?,
        email: data['email'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      ),
      fields: [
        WidgetConfig(
          key: 'name',
          fieldType: FieldType.name,
          labelText: 'Full Name',
          initialValue: staff.name,
          mandatory: true,
        ),
        WidgetConfig(
          key: 'role',
          fieldType: FieldType.general,
          labelText: 'Role',
          initialValue: staff.role,
          mandatory: true,
        ),
        WidgetConfig(
          key: 'mobile',
          fieldType: FieldType.mobileNumber,
          labelText: 'Mobile',
          initialValue: staff.mobile,
          mandatory: true,
        ),
        WidgetConfig(
          key: 'email',
          fieldType: FieldType.email,
          labelText: 'Email',
          initialValue: staff.email,
          mandatory: false,
        ),
      ],
    );
  }
}
