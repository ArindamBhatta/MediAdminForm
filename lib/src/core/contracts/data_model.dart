import 'package:equatable/equatable.dart';

abstract class DataModel extends Equatable {
  String? get uid; // not null
  String? get title;
  String? get subTitle;

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [uid, title, subTitle];
}
