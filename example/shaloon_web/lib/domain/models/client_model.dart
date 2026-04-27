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

  factory ClientModel.empty() => ClientModel();

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    id: json['id'] as String?,
    name: json['name'] as String?,
    mobile: json['mobile'] as String?,
    email: json['email'] as String?,
    whatsapp: json['whatsapp'] as String?,
    address: json['address'] as String?,
    photoUrl: json['photoUrl'] as String?,
    tags: (json['tags'] as List?)?.cast<String>(),
  );

  ClientModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? whatsapp,
    String? address,
    String? photoUrl,
    List<String>? tags,
  }) => ClientModel(
    id: id ?? this.id,
    name: name ?? this.name,
    mobile: mobile ?? this.mobile,
    email: email ?? this.email,
    whatsapp: whatsapp ?? this.whatsapp,
    address: address ?? this.address,
    photoUrl: photoUrl ?? this.photoUrl,
    tags: tags ?? this.tags,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'email': email,
    'whatsapp': whatsapp,
    'address': address,
    'photoUrl': photoUrl,
    'tags': tags,
  };

  @override
  String? get uid => id;

  @override
  String? get title => name;

  @override
  String? get subTitle => mobile;
}
