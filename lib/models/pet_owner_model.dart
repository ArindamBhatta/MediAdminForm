// ignore_for_file: must_be_immutable
import 'package:form_template/models/interface/data_model.dart';

class PetOwnerModel extends DataModel {
  String? id;
  String? name;
  String? address;
  String? mobile;
  String? alternateMobile;
  String? email;
  String? whatsapp;
  List<String>? pets;

  PetOwnerModel({
    this.id,
    this.name,
    this.address,
    this.mobile,
    this.alternateMobile,
    this.email,
    this.whatsapp,
    this.pets,
  });

  PetOwnerModel copyWith({
    String? id,
    String? name,
    String? address,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? whatsapp,
    List<String>? pets,
  }) {
    return PetOwnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      pets: pets ?? this.pets,
    );
  }

  PetOwnerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    mobile = json['mobile'] as String?;
    alternateMobile = json['alternateMobile'] as String?;
    email = json['email'];
    whatsapp = json['whatsapp'];

    // Handle pets array
    if (json['pets'] is List) {
      pets = (json['pets'] as List).cast<String>();
    } else {
      pets = null;
    }
  }
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['mobile'] = mobile;
    data['alternateMobile'] = alternateMobile;
    data['email'] = email;
    data['whatsapp'] = whatsapp;
    data['pets'] = pets;
    return data;
  }

  @override
  String? get title => name;

  @override
  String? get subTitle => mobile;

  @override
  String? get uid => id;
}
