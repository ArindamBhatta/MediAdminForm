import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_template/core/cubit/form_state.dart';
import 'package:form_template/core/repo/form_repo_mixin.dart';
import 'package:form_template/models/data_model.dart';

class FormCubit<T extends DataModel> extends Cubit<FormViewState<T>> {
  final FormRepoMixin<T> repo;
  FormCubit({required this.repo}) : super(FormViewStateLoading<T>()) {}
}
