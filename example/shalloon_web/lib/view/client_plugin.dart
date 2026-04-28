import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../domain/enums/shalloon_enums.dart';
import '../domain/models/client_model.dart';

// Single Source of Truth: - It describes everything the framework needs to know about a plugin/module: its unique ID, display info, routes, data binding, permissions, and features.
final PluginDescriptor<ClientModel>
clientPlugin = PluginDescriptor<ClientModel>(
  moduleId: 'clients',
  title: ShalloonSection.clients.label,
  icon: ShalloonSection.clients.icon,
  color: ShalloonSection.clients.color,
  order: ShalloonSection.clients.order,

  /// Optional feature flags that the framework can use to conditionally enable/disable functionality. The plugin author declares which features they use, and the framework handles the rest.
  features: const PluginFeatureFlags(
    supportsCrud: true,
    supportsRealtime: true,
    supportsUpload: true,
  ),

  // All personas can view clients section, but only admin and manager can edit (enforced in the UI and in the API).
  visibilityPolicy: PersonaPermissionPolicy({
    ShalloonPersona.admin.label,
    ShalloonPersona.manager.label,
    ShalloonPersona.receptionist.label,
    ShalloonPersona.stylist.label,
  }),

  /// Data binding: collection, serializer, empty factory. The framework uses this to generate a repo and sync with Firestore. The plugin author only writes the model and the fromJson logic, and the framework handles the rest.
  dataBinding: PluginDataBinding<ClientModel>(
    collectionName: 'clients',
    fromJson: ClientModel.formJson,
    createEmpty: ClientModel.new,
  ),

  /// Routes: path, builder, and optional access policy. The framework uses this to generate GoRouter routes and enforce permissions. The plugin author only writes the builder logic, and the framework handles the rest.
  routes: [
    PluginRouteDescriptor(
      path: '/clients',
      builder: (BuildContext ctx, GoRouterState state) => ClientSectionPage(
        initialSelectedItemId: state.uri.queryParameters['selected'],
      ),
    ),
  ],
);

class ClientSectionPage extends StatelessWidget {
  final String? initialSelectedItemId;

  const ClientSectionPage({super.key, this.initialSelectedItemId});

  SectionRepo<ClientModel> _resolveRepo(BuildContext context) {
    try {
      return RepositoryProvider.of<SectionRepo<ClientModel>>(context);
    } catch (_) {
      final binding = clientPlugin.dataBinding;
      return SectionRepo<ClientModel>(
        moduleId: clientPlugin.moduleId,
        service: FirestoreService<ClientModel>(
          moduleId: clientPlugin.moduleId,
          collectionName: binding.collectionName,
          fromJson: binding.fromJson,
        ),
      );
    }
  }

  Widget _buildSection(BuildContext context, SectionRepo<ClientModel> repo) {
    final cubit = BlocProvider.of<FormCubit<ClientModel>>(context);

    return SectionWidget<ClientModel>(
      sectionLabel: ShalloonSection.clients.label,
      sectionIcon: ShalloonSection.clients.icon,
      sectionColor: ShalloonSection.clients.color,
      sectionTitle: 'Clients',
      repo: repo,
      formCubit: cubit,
      initialSelectedItemId: initialSelectedItemId,
      createEmptyModel: ClientModel.new,

      rebuildDataModel: (data) => ClientModel(
        id: data['id'] as String?,
        name: data['name'] as String?,
        mobile: data['mobile'] as String?,
        email: data['email'] as String?,
        whatsapp: data['whatsapp'] as String?,
        address: data['address'] as String?,
        photoUrl: data['photoUrl'] as String?,
        tags: (data['tags'] as List<dynamic>?)?.cast<String>(),
      ),

      initialTabDetailBuilder: (item, ctx) => FormPageView(
        formCubit: BlocProvider.of<FormCubit<ClientModel>>(ctx),
        dataModel: item,
        rebuildDataModel: (data) => ClientModel(
          id: data['id'] as String?,
          name: data['name'] as String?,
          mobile: data['mobile'] as String?,
          email: data['email'] as String?,
          whatsapp: data['whatsapp'] as String?,
          address: data['address'] as String?,
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
            key: 'mobile',
            fieldType: FieldType.mobileNumber,
            labelText: 'Mobile',
            initialValue: item.mobile,
            mandatory: true,
          ),
          WidgetConfig(
            key: 'whatsapp',
            fieldType: FieldType.whatsapp,
            labelText: 'WhatsApp',
            initialValue: item.whatsapp,
            mandatory: false,
          ),
          WidgetConfig(
            key: 'email',
            fieldType: FieldType.email,
            labelText: 'Email',
            initialValue: item.email,
            mandatory: false,
          ),
          WidgetConfig(
            key: 'address',
            fieldType: FieldType.address,
            labelText: 'Address',
            initialValue: item.address,
            mandatory: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = _resolveRepo(context);
    FormCubit<ClientModel>? existingCubit;
    try {
      existingCubit = BlocProvider.of<FormCubit<ClientModel>>(context);
    } catch (_) {
      existingCubit = null;
    }

    if (existingCubit != null) {
      return _buildSection(context, repo);
    }

    return BlocProvider<FormCubit<ClientModel>>(
      create: (_) => FormCubit<ClientModel>(repo: repo),
      child: Builder(builder: (ctx) => _buildSection(ctx, repo)),
    );
  }
}
