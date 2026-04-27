import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../../domain/models/client_model.dart';

/// Client detail view — developer writes only this.
class ClientDetailView extends StatelessWidget {
  final ClientModel client;

  const ClientDetailView({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return FormPageView(
      formCubit: BlocProvider.of<FormCubit<ClientModel>>(context),
      dataModel: client,
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
          initialValue: client.name,
          mandatory: true,
        ),
        WidgetConfig(
          key: 'mobile',
          fieldType: FieldType.mobileNumber,
          labelText: 'Mobile',
          initialValue: client.mobile,
          mandatory: true,
        ),
        WidgetConfig(
          key: 'whatsapp',
          fieldType: FieldType.whatsapp,
          labelText: 'WhatsApp',
          initialValue: client.whatsapp,
          mandatory: false,
        ),
        WidgetConfig(
          key: 'email',
          fieldType: FieldType.email,
          labelText: 'Email',
          initialValue: client.email,
          mandatory: false,
        ),
        WidgetConfig(
          key: 'address',
          fieldType: FieldType.address,
          labelText: 'Address',
          initialValue: client.address,
          mandatory: false,
        ),
      ],
    );
  }
}
