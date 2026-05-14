import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../../domain/enums/vet_application_enums.dart';
import '../../domain/models/doctor_model.dart';

/// Doctors plugin descriptor.
/// This is the entire surface area the developer fills in to add a new section.
final DefaultPluginDescription<DoctorModel>
doctorsPlugin = DefaultPluginDescription<DoctorModel>(
  moduleId: 'doctors',
  title: VetAppSection.doctors.label,
  icon: VetAppSection.doctors.icon,
  color: VetAppSection.doctors.color,
  order: VetAppSection.doctors.order,
  // Optional feature flags that the framework can use to conditionally enable/disable functionality. The plugin author declares which features they use, and the framework handles the rest.
  features: const PluginFeatureFlags(
    supportsCrud: true,
    supportsRealtime: true,
    supportsUpload: true,
  ),

  visibilityPolicy: PersonaPermissionPolicy({
    VetApplicationEnums.admin.label,
    VetApplicationEnums.operator.label,
  }),

  dataBinding: PluginDataBinding<DoctorModel>(
    collectionName: 'doctors', // Firestore collection name
    fromJson: DoctorModel.fromJson,
    createEmpty: DoctorModel.new,
  ),
  routes: [
    SingleRouteDescriptionAndPolicy(
      path: '/doctors', // Navigates
      builder: (BuildContext ctx, GoRouterState state) => DoctorsSectionPage(
        initialSelectedItemId: state.uri.queryParameters['selected'],
      ),
    ),
  ],
);

/// Doctors section page — the developer writes this view.
/// The framework handles data, state, list, form, and dialog.
class DoctorsSectionPage extends StatelessWidget {
  final String? initialSelectedItemId;

  const DoctorsSectionPage({super.key, this.initialSelectedItemId});

  Widget _buildSection(BuildContext context, SectionRepo<DoctorModel> repo) {
    final cubit = BlocProvider.of<FormCubit<DoctorModel>>(context);

    return SectionWidget<DoctorModel>(
      sectionLabel: VetAppSection.doctors.label,
      sectionIcon: VetAppSection.doctors.icon,
      sectionColor: VetAppSection.doctors.color,
      sectionTitle: 'Doctors',
      repo: repo,
      formCubit: cubit,
      initialSelectedItemId: initialSelectedItemId,
      // If SectionWidget supported this flag, you would pass it here to hide the FAB/Add button
      // supportsCrud: doctorsPlugin.features.supportsCrud,
      createEmptyModel: DoctorModel.new,

      rebuildDataModel: (data) => DoctorModel(
        id: data['id'] as String?,
        active: data['active'] as String?,
        name: data['name'] as String?,
        qualifications: data['qualifications'] as String?,
        registrationNumber: data['registrationNumber'] as String?,
        mobile: data['mobile'] as String?,
        whatsapp: data['whatsapp'] as String?,
        email: data['email'] as String?,
        fee: data['fee'] as String?,
        dob: data['dob'] as String?,
      ),

      initialTabDetailBuilder: (item, ctx) => FormPageView(
        formCubit: BlocProvider.of<FormCubit<DoctorModel>>(ctx),
        dataModel: item,
        supportsCrud: doctorsPlugin.features.supportsCrud,
        fields: [
          WidgetConfig(
            key: 'name',
            fieldType: FieldType.name,
            labelText: 'Full Name',
            initialValue: item.name,
            mandatory: true,
            icon: FontAwesomeIcons.userDoctor,
          ),
          WidgetConfig(
            key: 'qualifications',
            fieldType: FieldType.name,
            labelText: 'Qualifications',
            initialValue: item.qualifications,
            mandatory: false,
            icon: FontAwesomeIcons.graduationCap,
          ),
          WidgetConfig(
            key: 'registrationNumber',
            fieldType: FieldType.name,
            labelText: 'Registration Number',
            initialValue: item.registrationNumber,
            mandatory: false,
            icon: FontAwesomeIcons.idCard,
          ),
          WidgetConfig(
            key: 'mobile',
            fieldType: FieldType.mobileNumber,
            labelText: 'Mobile',
            initialValue: item.mobile,
            mandatory: false,
            icon: FontAwesomeIcons.mobile,
          ),
          WidgetConfig(
            key: 'whatsapp',
            fieldType: FieldType.mobileNumber,
            labelText: 'WhatsApp',
            initialValue: item.whatsapp,
            icon: FontAwesomeIcons.whatsapp,
          ),
          WidgetConfig(
            key: 'email',
            fieldType: FieldType.email,
            labelText: 'Email',
            initialValue: item.email,
            icon: FontAwesomeIcons.envelope,
          ),
          WidgetConfig(
            key: 'fee',
            fieldType: FieldType.name,
            labelText: 'Fee',
            initialValue: item.fee,
            icon: FontAwesomeIcons.moneyBill,
          ),
          WidgetConfig(
            key: 'dob',
            fieldType: FieldType.date,
            labelText: 'Date of Birth',
            initialValue: item.dob,
            icon: FontAwesomeIcons.birthdayCake,
          ),
        ],

        rebuildDataModel: (data) => DoctorModel(
          id: data['id'] as String?,
          active: data['active'] as String?,
          name: data['name'] as String?,
          qualifications: data['qualifications'] as String?,
          registrationNumber: data['registrationNumber'] as String?,
          mobile: data['mobile'] as String?,
          whatsapp: data['whatsapp'] as String?,
          email: data['email'] as String?,
          fee: data['fee'] as String?,
          dob: data['dob'] as String?,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      final cubit = BlocProvider.of<FormCubit<DoctorModel>>(context);
      return _buildSection(context, cubit.repo as SectionRepo<DoctorModel>);
    } catch (_) {
      final repo = SectionRepo<DoctorModel>.fromDescriptor(doctorsPlugin);
      return BlocProvider<FormCubit<DoctorModel>>(
        create: (_) => FormCubit<DoctorModel>(repo: repo),
        child: Builder(builder: (ctx) => _buildSection(ctx, repo)),
      );
    }
  }
}
