import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../domain/enums/shalloon_enums.dart';
import '../domain/models/staff_model.dart';

/// Staff plugin descriptor.
/// This is the entire surface area the developer fills in to add a new section.
final staffPlugin = PluginDescriptor<StaffModel>(
  moduleId: 'staff',
  title: ShalloonSection.staff.label,
  icon: ShalloonSection.staff.icon,
  color: ShalloonSection.staff.color,
  order: ShalloonSection.staff.order,
  features: const PluginFeatureFlags(
    supportsCrud: true,
    supportsRealtime: true,
    supportsUpload: true, // profile photo
  ),
  visibilityPolicy: PersonaPermissionPolicy({
    ShalloonPersona.admin.label,
    ShalloonPersona.manager.label,
  }),
  dataBinding: PluginDataBinding<StaffModel>(
    collectionName: 'staff',
    fromJson: StaffModel.fromJson,
    createEmpty: StaffModel.new,
  ),
  routes: [
    PluginRouteDescriptor(
      path: '/staff',
      builder: (BuildContext ctx, GoRouterState state) => StaffSectionPage(
        initialSelectedItemId: state.uri.queryParameters['selected'],
      ),
    ),
  ],
);

/// Staff section page — the developer writes this view.
/// The framework handles data, state, list, form, and dialog.
class StaffSectionPage extends StatelessWidget {
  final String? initialSelectedItemId;

  const StaffSectionPage({super.key, this.initialSelectedItemId});

  SectionRepo<StaffModel> _resolveRepo(BuildContext context) {
    try {
      return RepositoryProvider.of<SectionRepo<StaffModel>>(context);
    } catch (_) {
      final binding = staffPlugin.dataBinding;
      return SectionRepo<StaffModel>(
        moduleId: staffPlugin.moduleId,
        service: FirestoreService<StaffModel>(
          moduleId: staffPlugin.moduleId,
          collectionName: binding.collectionName,
          fromJson: binding.fromJson,
        ),
      );
    }
  }

  Widget _buildSection(BuildContext context, SectionRepo<StaffModel> repo) {
    final cubit = BlocProvider.of<FormCubit<StaffModel>>(context);

    return SectionWidget<StaffModel>(
      sectionLabel: ShalloonSection.staff.label,
      sectionIcon: ShalloonSection.staff.icon,
      sectionColor: ShalloonSection.staff.color,
      sectionTitle: 'Staff',
      repo: repo,
      formCubit: cubit,
      initialSelectedItemId: initialSelectedItemId,
      createEmptyModel: StaffModel.new,

      rebuildDataModel: (data) => StaffModel(
        id: data['id'] as String?,
        name: data['name'] as String?,
        role: data['role'] as String?,
        mobile: data['mobile'] as String?,
        email: data['email'] as String?,
        photoUrl: data['photoUrl'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      ),

      initialTabDetailBuilder: (item, ctx) => FormPageView(
        formCubit: BlocProvider.of<FormCubit<StaffModel>>(ctx),
        dataModel: item,
        rebuildDataModel: (data) => StaffModel(
          id: data['id'] as String?,
          name: data['name'] as String?,
          role: data['role'] as String?,
          mobile: data['mobile'] as String?,
          email: data['email'] as String?,
          photoUrl: data['photoUrl'] as String?,
          isActive: data['isActive'] as bool? ?? true,
        ),
        fields: [
          WidgetConfig(
            key: 'name',
            fieldType: FieldType.name,
            labelText: 'Full Name',
            initialValue: item.name,
            mandatory: true,
          ),
          WidgetConfig(
            key: 'role',
            fieldType: FieldType.name,
            labelText: 'Role',
            initialValue: item.role,
            mandatory: true,
          ),
          WidgetConfig(
            key: 'mobile',
            fieldType: FieldType.mobileNumber,
            labelText: 'Mobile',
            initialValue: item.mobile,
            mandatory: true,
          ),
          WidgetConfig(
            key: 'email',
            fieldType: FieldType.email,
            labelText: 'Email',
            initialValue: item.email,
            mandatory: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = _resolveRepo(context);
    FormCubit<StaffModel>? existingCubit;
    try {
      existingCubit = BlocProvider.of<FormCubit<StaffModel>>(context);
    } catch (_) {
      existingCubit = null;
    }

    if (existingCubit != null) {
      return _buildSection(context, repo);
    }

    return BlocProvider<FormCubit<StaffModel>>(
      create: (_) => FormCubit<StaffModel>(repo: repo),
      child: Builder(builder: (ctx) => _buildSection(ctx, repo)),
    );
  }
}
