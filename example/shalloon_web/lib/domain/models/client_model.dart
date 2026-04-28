// ignore_for_file: must_be_immutable
import 'package:web_ui_plugins/web_ui_plugins.dart';

/// Client model — the minimal model a developer defines to onboard a new section.
class ClientModel extends DataModel {
  String? id;
  String? name;
  String? mobile;
  String? email;
  String? whatsapp;
  String? address;
  String? photoUrl;
  List<String>? tags; // e.g. 'VIP', 'Regular', 'New'

  ClientModel({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.whatsapp,
    this.address,
    this.photoUrl,
    this.tags,
  });

  ClientModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? whatsapp,
    String? address,
    String? photoUrl,
    List<String>? tags,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      tags: tags ?? this.tags,
    );
  }

  ClientModel.formJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    whatsapp = json['whatsapp'];
    address = json['address'] as String?;
    photoUrl = json['photoUrl'] as String?;
    tags = json['tags'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['email'] = email;
    data['whatsapp'] = whatsapp;
    data['address'] = address;
    data['photoUrl'] = photoUrl;
    data['tags'] = tags;
    return data;
  }

  @override
  String? get uid => id;

  @override
  String? get title => name;

  @override
  String? get subTitle => mobile;
}
