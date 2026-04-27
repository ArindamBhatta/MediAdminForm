import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/core/widgets/enums.dart';

class NavigationState extends Equatable {
  final Section selectedSection;
  final String? sectionSubItemId;
  final bool isNavRailCollapsed;

  const NavigationState(
    this.selectedSection, {
    this.sectionSubItemId,
    this.isNavRailCollapsed = false,
  });

  NavigationState copyWith({
    Section? selectedSection,
    String? sectionSubItemId,
    bool clearSubItemId = false,
    bool? isNavRailCollapsed,
  }) {
    return NavigationState(
      selectedSection ?? this.selectedSection,
      sectionSubItemId: clearSubItemId
          ? null
          : (sectionSubItemId ?? this.sectionSubItemId),
      isNavRailCollapsed: isNavRailCollapsed ?? this.isNavRailCollapsed,
    );
  }

  @override
  List<Object?> get props => [
    selectedSection,
    sectionSubItemId,
    isNavRailCollapsed,
  ];
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(Section.petOwners));

  void navigate(Section section, {String? sectionSubItemId}) {
    emit(
      state.copyWith(
        selectedSection: section,
        sectionSubItemId: sectionSubItemId,
        clearSubItemId: sectionSubItemId == null,
      ),
    );
  }

  void toggleNavRail() {
    emit(state.copyWith(isNavRailCollapsed: !state.isNavRailCollapsed));
  }
}
