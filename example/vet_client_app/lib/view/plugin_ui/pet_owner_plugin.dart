import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../../domain/enums/vet_application_enums.dart';
import '../../domain/models/pet_owner_model.dart';

// Single Source of Truth: - It describes everything the framework needs to know about a plugin/module: its unique ID, display info, routes, data binding, permissions, and features.
final DefaultPluginDescription<PetOwnerModel>
petOwnerPlugin = DefaultPluginDescription<PetOwnerModel>(
  moduleId: 'pet-owners',
  title: VetAppSection.petOwners.label,
  icon: VetAppSection.petOwners.icon,
  color: VetAppSection.petOwners.color,
  order: VetAppSection.petOwners.order,

  /// Optional feature flags that the framework can use to conditionally enable/disable functionality. The plugin author declares which features they use, and the framework handles the rest.
  features: const PluginFeatureFlags(
    supportsCrud: true,
    supportsUpload: true,
    supportsRealtime: true,
  ),

  // All personas can view clients section, but only admin and manager can edit (enforced in the UI and in the API).
  visibilityPolicy: PersonaPermissionPolicy({
    VetApplicationEnums.admin.label,
    VetApplicationEnums.operator.label,
  }),

  /// Data binding: collection, serializer, empty factory. The framework uses this to generate a repo and sync with Firestore. The plugin author only writes the model and the fromJson logic, and the framework handles the rest.
  dataBinding: PluginDataBinding<PetOwnerModel>(
    collectionName: 'petOwners', // Firestore collection name
    fromJson: PetOwnerModel.fromJson,
    createEmpty: PetOwnerModel.new,
  ),

  /// Routes: path, builder, and optional access policy. The framework uses this to generate GoRouter routes and enforce permissions. The plugin author only writes the builder logic, and the framework handles the rest.
  routes: [
    SingleRouteDescriptionAndPolicy(
      path: '/pet-owners', //GoRouter path
      builder: (BuildContext ctx, GoRouterState state) => PetOwnerPluginPage(
        initialSelectedItemId: state.uri.queryParameters['selected'],
      ),
    ),
  ],
);

/// Single source of truth for Pet Owner state. Because this is static, the state
/// (and realtime listeners) persist even when navigating to other plugins.
class PetOwnerPluginState {
  static final repo = SectionRepo<PetOwnerModel>.fromDescriptor(petOwnerPlugin);
  static final cubit = FormCubit<PetOwnerModel>(repo: repo);
}

class PetOwnerPluginPage extends StatelessWidget {
  final String? initialSelectedItemId;

  const PetOwnerPluginPage({super.key, this.initialSelectedItemId});

  Widget _buildSection(BuildContext context, SectionRepo<PetOwnerModel> repo) {
    final cubit = BlocProvider.of<FormCubit<PetOwnerModel>>(context);

    return SectionWidget<PetOwnerModel>(
      sectionLabel: VetAppSection.petOwners.label,
      sectionIcon: VetAppSection.petOwners.icon,
      sectionColor: VetAppSection.petOwners.color,
      sectionTitle: 'Pet Owners',
      repo: repo,
      formCubit: cubit,
      initialSelectedItemId: initialSelectedItemId,
      createEmptyModel: PetOwnerModel.new,

      rebuildDataModel: (data) => PetOwnerModel(
        id: data['id'] as String?,
        name: data['name'] as String?,
        address: data['address'] as String?,
        mobile: data['mobile'] as String?,
        email: data['email'] as String?,
        whatsapp: data['whatsapp'] as String?,
      ),

      initialTabDetailBuilder: (item, ctx) => FormPageView(
        formCubit: BlocProvider.of<FormCubit<PetOwnerModel>>(ctx),
        dataModel: item,
        supportsCrud: petOwnerPlugin.features.supportsCrud,
        fields: [
          WidgetConfig(
            key: 'name',
            fieldType: FieldType.name,
            labelText: 'Full Name',
            initialValue: item.name,
            mandatory: true,
            icon: FontAwesomeIcons.solidUser,
          ),

          WidgetConfig(
            key: 'address',
            fieldType: FieldType.address,
            labelText: 'Address',
            initialValue: item.address,
            mandatory: false,
            icon: FontAwesomeIcons.house,
          ),

          WidgetConfig(
            key: 'mobile',
            fieldType: FieldType.mobileNumber,
            labelText: 'Mobile',
            initialValue: item.mobile,
            mandatory: true,
            icon: FontAwesomeIcons.mobileScreen,
          ),

          WidgetConfig(
            key: 'email',
            fieldType: FieldType.email,
            labelText: 'Email',
            initialValue: item.email,
            mandatory: false,
            icon: FontAwesomeIcons.solidEnvelope,
          ),

          WidgetConfig(
            key: 'whatsapp',
            labelText: 'WhatsApp',
            initialValue: item.whatsapp,
            fieldType: FieldType.mobileNumber,
            mandatory: false,
            icon: FontAwesomeIcons.whatsapp,
          ),
        ],

        rebuildDataModel: (data) => PetOwnerModel(
          id: data['id'] as String?,
          name: data['name'] as String?,
          address: data['address'] as String?,
          mobile: data['mobile'] as String?,
          email: data['email'] as String?,
          whatsapp: data['whatsapp'] as String?,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provide the persistent, strictly-typed cubit to the widget tree for this route.
    // FormPageView and SectionWidget will successfully find it via BlocProvider.of!
    return BlocProvider.value(
      value: PetOwnerPluginState.cubit,
      child: Builder(
        builder: (ctx) => _buildSection(ctx, PetOwnerPluginState.repo),
      ),
    );
  }
}
