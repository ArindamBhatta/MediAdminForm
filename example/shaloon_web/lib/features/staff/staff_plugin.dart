import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../../domain/enums/shaloon_enums.dart';
import '../../domain/models/staff_model.dart';
import 'staff_view.dart';

/// Staff plugin descriptor.
/// This is the entire surface area the developer fills in to add a new section.
final staffPlugin = PluginDescriptor<StaffModel>(
  moduleId: 'staff',
  title: ShaloonSection.staff.label,
  icon: ShaloonSection.staff.icon,
  color: ShaloonSection.staff.color,
  order: ShaloonSection.staff.order,
  features: const PluginFeatureFlags(
    supportsCrud: true,
    supportsRealtime: true,
    supportsUpload: true, // profile photo
  ),
  visibilityPolicy: PersonaPermissionPolicy({
    ShaloonPersona.admin.label,
    ShaloonPersona.manager.label,
  }),
  dataBinding: PluginDataBinding<StaffModel>(
    collectionName: 'staff',
    fromJson: StaffModel.fromJson,
    createEmpty: StaffModel.empty,
  ),
  routes: [
    PluginRouteDescriptor(
      path: '/staff',
      builder: (ctx) => const StaffSectionPage(),
    ),
  ],
);

/// Staff section page — the developer writes this view.
/// The framework handles data, state, list, form, and dialog.
class StaffSectionPage extends StatelessWidget {
  const StaffSectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<ScopedRepo<StaffModel>>(context);
    final cubit = BlocProvider.of<FormCubit<StaffModel>>(context);

    return SectionWidget<StaffModel>(
      section: Section.values.byName('staff'),
      sectionTitle: 'Staff',
      repo: repo,
      formCubit: cubit,
      createEmptyModel: StaffModel.empty,
      rebuildDataModel: (data) => StaffModel(
        id: data['id'] as String?,
        name: data['name'] as String?,
        role: data['role'] as String?,
        mobile: data['mobile'] as String?,
        email: data['email'] as String?,
        photoUrl: data['photoUrl'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      ),
      initialTabDetailBuilder: (item, ctx) => StaffDetailView(staff: item),
    );
  }
}
