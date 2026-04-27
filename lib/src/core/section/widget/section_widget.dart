import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/src/core/form/cubit/form_cubit.dart';
import 'package:web_ui_plugins/src/core/form/form_page.dart';
import 'package:web_ui_plugins/src/core/form/repo/form_repo_mixin.dart';
import 'package:web_ui_plugins/src/core/section/cubit/section_cubit.dart';
import 'package:web_ui_plugins/src/core/section/widget/custom_list_view.dart';
import 'package:web_ui_plugins/src/core/section/widget/no_data_view.dart';
import 'package:web_ui_plugins/src/core/section/widget/section_view.dart';
import 'package:web_ui_plugins/src/core/section/widget/sub_section_view.dart';
import 'package:web_ui_plugins/src/core/widgets/custom_button.dart';
import 'package:web_ui_plugins/src/core/widgets/custom_dialog_box.dart';
import 'package:web_ui_plugins/src/core/widgets/custom_snack_bar.dart';
import 'package:web_ui_plugins/src/core/widgets/customizable_search_bar.dart';
import 'package:web_ui_plugins/src/core/widgets/enums.dart';
import 'package:web_ui_plugins/src/core/widgets/globals.dart' show Globals;

import 'package:web_ui_plugins/src/core/contracts/data_model.dart';

// Cubit for Section UI state

// Section widget
class SectionWidget<T extends DataModel> extends StatefulWidget {
  final Section section;
  final String sectionTitle;
  final FormRepoMixin<T> repo;
  final FormCubit<T> formCubit;
  final Widget Function(T item, BuildContext context) initialTabDetailBuilder;
  // Optional functions to extract status
  final String? Function(T item)? statusKeyOf;
  final DateTime? Function(T item)? dateOf;

  final List<Widget> Function(BuildContext context, T item)? headerLeftWidgets;
  final List<Widget> Function(BuildContext context, T item)? headerRightWidgets;
  final List<CustomButton> Function(BuildContext context, T item)?
  footerActionButtons;

  final List<String> Function(T item)? filterExtraTabs;
  final List<Widget Function(String itemId)> Function(T item)?
  extraTabViewsBuilder;

  final T Function() createEmptyModel;
  final DataModel Function(Map<String, dynamic> data) rebuildDataModel;
  final String? initialSelectedItemId;
  final bool showAddButton;
  final Set<String> initialSelectedStatuses;
  final String firstTabLabel;

  const SectionWidget({
    super.key,
    required this.section,
    required this.repo,
    required this.formCubit,
    required this.sectionTitle,
    required this.initialTabDetailBuilder,
    this.statusKeyOf,
    this.dateOf,
    this.headerLeftWidgets,
    this.headerRightWidgets,
    this.footerActionButtons,
    required this.createEmptyModel,
    required this.rebuildDataModel,
    this.filterExtraTabs,
    this.extraTabViewsBuilder,
    this.initialSelectedItemId,
    this.showAddButton = true,
    this.initialSelectedStatuses = const <String>{},
    this.firstTabLabel = 'Details',
  });

  @override
  State<SectionWidget<T>> createState() => _SectionState<T>();
}

class _SectionState<T extends DataModel> extends State<SectionWidget<T>> {
  late final SectionCubit<T> cubit;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _leftPaneKey = GlobalKey();
  double _headerLeftActionsInset = 0;
  bool _mobileViewingDetail = false;

  @override
  void initState() {
    super.initState();
    cubit = SectionCubit<T>(
      repo: widget.repo,
      formCubit: widget.formCubit,
      statusKeyOf: widget.statusKeyOf,
      dateOf: widget.dateOf,
      initialSelectedStatuses: widget.initialSelectedStatuses,
    );
    cubit.loadAll();

    if (widget.initialSelectedItemId != null) {
      final item = widget.repo.items.firstWhere(
        (e) => e.uid == widget.initialSelectedItemId,
        orElse: () => widget.createEmptyModel.call(),
      );
      if (item.uid != null) {
        cubit.selectItem(item);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _titleAnchorWidth(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500);
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.section.name.toUpperCase(),
        style: titleStyle,
      ),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();

    return 24 + Globals.sidePadding + textPainter.width + Globals.sidePadding;
  }

  void _scheduleHeaderInsetMeasurement(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderObject = _leftPaneKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox) return;

      final leftPaneWidth = renderObject.size.width;
      final desiredInset = (leftPaneWidth - _titleAnchorWidth(context)).clamp(
        0.0,
        double.infinity,
      );

      if ((desiredInset - _headerLeftActionsInset).abs() > 0.5) {
        setState(() {
          _headerLeftActionsInset = desiredInset;
        });
      }
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final emptyModel = widget.createEmptyModel();
        final initialDetail = widget.initialTabDetailBuilder(
          emptyModel,
          context,
        );
        final initialFormPage = initialDetail is FormPageView
            ? initialDetail
            : null;

        return BlocProvider.value(
          value: widget.formCubit,
          child: CustomDialogBox(
            title: 'Add New ${widget.sectionTitle}',
            width: 600,
            height: 450,
            child: FormPageView(
              key: ValueKey('new_${widget.sectionTitle}'),
              formCubit: widget.formCubit,
              dataModel: emptyModel,
              fields: initialFormPage?.fields ?? [],
              rebuildDataModel: widget.rebuildDataModel,
              primaryButtonText: initialFormPage?.primaryButtonText ?? "Add",
              onSaveSuccess: () {
                Navigator.of(ctx).pop();
              },
              onCancel: () {
                Navigator.of(ctx).pop();
              },
            ),
          ),
        );
      },
    ).then((_) {
      cubit.clearSearch();
      _searchController.clear();
      cubit.loadAll();
    });
  }

  void _mobileGoBackToList() {
    setState(() => _mobileViewingDetail = false);
  }

  Widget _buildMobileDetailView(BuildContext context, T selected) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _mobileGoBackToList();
      },
      child: Column(
        children: [
          Container(
            height: Globals.topBarHeight,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: EdgeInsets.only(right: Globals.sidePadding / 2),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _mobileGoBackToList,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: Text(
                      selected.title ?? widget.sectionTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1, height: 1),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: SubSectionView(
                dataModel: selected,
                footerActionButtons:
                    widget.footerActionButtons?.call(context, selected) ??
                    const [],
                tabs: [
                  Tab(text: widget.firstTabLabel),
                  ...(widget.filterExtraTabs?.call(selected) ??
                          const <String>[])
                      .map((tabTitle) => Tab(text: tabTitle)),
                ],
                tabViews: [
                  widget.initialTabDetailBuilder(selected, context),
                  ...(widget.extraTabViewsBuilder?.call(selected) ??
                          const <Widget Function(String itemId)>[])
                      .map((builder) => builder(selected.uid!)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<SectionCubit<T>, SectionState<T>>(
        builder: (context, state) {
          final bool isWaiting = state.status == SuccessStatus.waiting;
          final bool hasItems = state.items.isNotEmpty;

          if (state.status == SuccessStatus.error) {
            return Center(
              child: Text(
                'Error loading ${widget.sectionTitle}. Please try again.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          // On mobile: show the detail view as a full-screen replacement
          if (isMobile && _mobileViewingDetail && state.selectedItem != null) {
            return _buildMobileDetailView(context, state.selectedItem!);
          }

          final headerAnchorItem =
              state.selectedItem ??
              (state.filteredItems.isNotEmpty
                  ? state.filteredItems.first
                  : (state.items.isNotEmpty ? state.items.first : null));
          final headerLeftItems =
              headerAnchorItem != null && widget.headerLeftWidgets != null
              ? widget.headerLeftWidgets!.call(context, headerAnchorItem)
              : const <Widget>[];
          final headerRightItems =
              headerAnchorItem != null && widget.headerRightWidgets != null
              ? widget.headerRightWidgets!.call(context, headerAnchorItem)
              : const <Widget>[];
          final List<Widget> leftSectionActions = <Widget>[...headerLeftItems];
          final List<Widget> rightSectionActions = <Widget>[
            ...headerRightItems,
            if (widget.showAddButton)
              CustomButton(
                text: 'Add ${widget.sectionTitle}',
                buttonType: ButtonType.secondary,
                height: Globals.formButtonHeight - 6,
                icon: Icons.add,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
                onPressed: _showAddDialog,
              ),
          ];

          if (!isMobile && hasItems && leftSectionActions.isNotEmpty) {
            _scheduleHeaderInsetMeasurement(context);
          }

          // Shared list pane used in both mobile and desktop layouts
          final Widget listPane = Column(
            children: [
              CustomizableSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  cubit.search(value);
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: state.filteredItems.isNotEmpty
                    ? CustomListView(
                        data: state.filteredItems,
                        selectedItem: state.selectedItem,
                        onItemTap: (item) {
                          final tappedItem = item as T;
                          final selectedUid = state.selectedItem?.uid;

                          if (selectedUid != tappedItem.uid) {
                            if (Globals.hasUnsavedFormChanges) {
                              CustomSnackBar.show(
                                context,
                                'You have unsaved changes. Changes were discarded when switching item.',
                                category: SnackBarCategory.warning,
                              );
                              Globals.hasUnsavedFormChanges = false;
                            }
                            cubit.selectItem(tappedItem);
                          }

                          if (isMobile) {
                            setState(() => _mobileViewingDetail = true);
                          }
                        },
                      )
                    : NoDataView(
                        title: 'No ${widget.sectionTitle} Found',
                        subtitle:
                            'No matching ${widget.sectionTitle.toLowerCase()} found.',
                        icon: Icons.search_outlined,
                        iconColor: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ],
          );

          final Widget sectionBody;

          if (!hasItems) {
            sectionBody = isWaiting
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : NoDataView(
                    title: 'No ${widget.sectionTitle} Information',
                    subtitle:
                        'Start adding ${widget.sectionTitle.toLowerCase()}.',
                    icon: Icons.search_outlined,
                    iconColor: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                  );
          } else if (isMobile) {
            // Mobile: list fills the full width
            sectionBody = Stack(
              children: [
                AbsorbPointer(absorbing: isWaiting, child: listPane),
                if (isWaiting)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.45),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            // Desktop: side-by-side list and detail panes
            sectionBody = Stack(
              children: [
                AbsorbPointer(
                  absorbing: isWaiting,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(key: _leftPaneKey, child: listPane),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 3,
                        child: Builder(
                          builder: (context) {
                            final selected = state.selectedItem;

                            return selected != null
                                ? SubSectionView(
                                    dataModel: selected,
                                    footerActionButtons:
                                        widget.footerActionButtons?.call(
                                          context,
                                          selected,
                                        ) ??
                                        const [],
                                    tabs: [
                                      Tab(text: widget.firstTabLabel),
                                      ...(widget.filterExtraTabs?.call(
                                                selected,
                                              ) ??
                                              const <String>[])
                                          .map(
                                            (tabTitle) => Tab(text: tabTitle),
                                          ),
                                    ],
                                    tabViews: [
                                      widget.initialTabDetailBuilder(
                                        selected,
                                        context,
                                      ),
                                      ...(widget.extraTabViewsBuilder?.call(
                                                selected,
                                              ) ??
                                              const <Widget Function(String)>[])
                                          .map(
                                            (builder) => builder(selected.uid!),
                                          ),
                                    ],
                                  )
                                : NoDataView(
                                    title:
                                        'No ${widget.sectionTitle} Information',
                                    subtitle:
                                        'Please select ${widget.sectionTitle.toLowerCase()} to view details.',
                                    icon: widget.section.icon,
                                    iconColor: widget.section.color,
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWaiting)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.45),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return SectionView(
            section: widget.section,
            headerLeftActions: leftSectionActions.isEmpty
                ? null
                : leftSectionActions,
            headerRightActions: rightSectionActions.isEmpty
                ? null
                : rightSectionActions,
            headerLeftActionsInset: _headerLeftActionsInset,
            child: sectionBody,
          );
        },
      ),
    );
  }
}
