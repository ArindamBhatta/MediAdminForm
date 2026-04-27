// ignore_for_file: must_be_immutable
import 'package:web_ui_plugins/web_ui_plugins.dart';

/// Staff model — the developer only writes this class and the framework
/// handles CRUD, real-time updates, form rendering, and list/detail UI.
class StaffModel extends DataModel {
  String? id;
  String? name;
  String? role; // ShaloonPersona.label
  String? mobile;
  String? email;
  String? photoUrl;
  bool? isActive;

  StaffModel({
    this.id,
    this.name,
    this.role,
    this.mobile,
    this.email,
    this.photoUrl,
    this.isActive = true,
  });

  factory StaffModel.empty() => StaffModel();

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
    id: json['id'] as String?,
    name: json['name'] as String?,
    role: json['role'] as String?,
    mobile: json['mobile'] as String?,
    email: json['email'] as String?,
    photoUrl: json['photoUrl'] as String?,
    isActive: json['isActive'] as bool? ?? true,
  );

  StaffModel copyWith({
    String? id,
    String? name,
    String? role,
    String? mobile,
    String? email,
    String? photoUrl,
    bool? isActive,
  }) => StaffModel(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role ?? this.role,
    mobile: mobile ?? this.mobile,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    isActive: isActive ?? this.isActive,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'mobile': mobile,
    'email': email,
    'photoUrl': photoUrl,
    'isActive': isActive,
  };

  @override
  String? get uid => id;

  @override
  String? get title => name;

  @override
  String? get subTitle => role;
}
