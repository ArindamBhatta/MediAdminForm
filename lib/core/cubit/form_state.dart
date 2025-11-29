import 'package:form_template/models/data_model.dart';

sealed class FormViewState<T extends DataModel> {}

final class FormViewStateLoading<T extends DataModel>
    extends FormViewState<T> {}

final class FormViewStateSuccess<T extends DataModel>
    extends FormViewState<T> {}

final class FormViewStateError<T extends DataModel> extends FormViewState<T> {}
