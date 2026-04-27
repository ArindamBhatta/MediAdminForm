part of 'form_cubit.dart';

enum FormOperation { create, read, update, delete }

sealed class FormViewState extends Equatable {
  const FormViewState();

  @override
  List<Object?> get props => [];
}

final class FromInitial extends FormViewState {}

final class FormInProgress extends FormViewState {
  final FormOperation operation;

  const FormInProgress({required this.operation});

  @override
  List<Object?> get props => [operation];
}

//In Dart, <T> is required because the compiler won’t assume generics — must explicitly tell it: “this class is generic.”
final class FormLoaded<T> extends FormViewState {
  final List<T> items;

  const FormLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

final class FormSuccess<T> extends FormViewState {
  final T data;
  final FormOperation operation;

  const FormSuccess({required this.data, required this.operation});

  @override
  List<Object?> get props => [data, operation];
}

final class FormFailure extends FormViewState {
  final String error;

  const FormFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
