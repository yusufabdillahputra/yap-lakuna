import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/master_data_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;
import '../products/product_widgets.dart';
import 'master_data_view_model.dart';

/// Layar *Master data* (1.17, F1-09). Memiliki [MasterDataViewModel].
class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({
    super.key,
    required this.repository,
    required this.session,
  });

  final MasterDataRepository repository;
  final SessionRepository session;

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  late final _viewModel = MasterDataViewModel(repository: widget.repository);

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = widget.session.current;
    return MasterDataView(
      viewModel: _viewModel,
      canManageStock: staff?.can(Permission.stockAdjust) ?? false,
      canManageSettings: staff?.can(Permission.settingsManage) ?? false,
    );
  }
}

class MasterDataView extends StatelessWidget {
  const MasterDataView({
    super.key,
    required this.viewModel,
    this.canManageStock = false,
    this.canManageSettings = false,
  });

  final MasterDataViewModel viewModel;
  final bool canManageStock;
  final bool canManageSettings;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context);
        final vm = viewModel;
        final width = constraints.maxWidth;
        final header = PageHeader(
          title: l10n.masterTitle,
          subtitle: l10n.masterSubtitle,
        );
        if (vm.load.running && vm.categories.isEmpty && vm.units.isEmpty) {
          return const Center(child: FCircularProgress());
        }
        if (vm.load.error) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                header,
                LoadFailedAlert(
                  key: const ValueKey('master-load-error'),
                  message: l10n.masterLoadFailed,
                  onRetry: vm.load.execute,
                ),
              ],
            ),
          );
        }
        final sideTabs = width >= 900;
        final content = switch (vm.tab) {
          MasterTab.categories => _CategoriesTab(viewModel: vm),
          MasterTab.units => _UnitsTab(viewModel: vm),
          MasterTab.locations => _LocationsTab(
            viewModel: vm,
            canManage: canManageStock,
          ),
          MasterTab.payments => _PaymentsTab(canManage: canManageSettings),
        };
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              header,
              if (sideTabs)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    SizedBox(width: 220, child: _SideTabs(viewModel: vm)),
                    Expanded(child: content),
                  ],
                )
              else ...[
                _TabPills(viewModel: vm),
                content,
              ],
            ],
          ),
        );
      },
    ),
  );
}

String _tabLabel(AppLocalizations l10n, MasterTab tab) => switch (tab) {
  MasterTab.categories => l10n.masterTabCategories,
  MasterTab.units => l10n.masterTabUnits,
  MasterTab.locations => l10n.masterTabLocations,
  MasterTab.payments => l10n.masterTabPayments,
};

IconData _tabIcon(MasterTab tab) => switch (tab) {
  MasterTab.categories => TablerIcons.category,
  MasterTab.units => TablerIcons.ruler2,
  MasterTab.locations => TablerIcons.buildingWarehouse,
  MasterTab.payments => TablerIcons.creditCard,
};

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

TextStyle _errorStyle(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.destructive);

class _SideTabs extends StatelessWidget {
  const _SideTabs({required this.viewModel});

  final MasterDataViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 2,
          children: [
            for (final tab in MasterTab.values)
              FItem(
                key: ValueKey('master-tab-${tab.name}'),
                prefix: Icon(_tabIcon(tab), size: 18),
                title: Text(_tabLabel(l10n, tab)),
                selected: viewModel.tab == tab,
                onPress: () => viewModel.setTab(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabPills extends StatelessWidget {
  const _TabPills({required this.viewModel});

  final MasterDataViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          for (final tab in MasterTab.values)
            ChoicePill(
              key: ValueKey('master-pill-${tab.name}'),
              label: _tabLabel(l10n, tab),
              selected: viewModel.tab == tab,
              onTap: () => viewModel.setTab(tab),
            ),
        ],
      ),
    );
  }
}

// --- Kategori ---------------------------------------------------------------

String _categoryErrorMessage(AppLocalizations l10n, CategoryError e) =>
    switch (e) {
      CategoryError.nameEmpty => l10n.masterErrNameEmpty,
      CategoryError.nameTooLong => l10n.masterErrNameTooLong(
        MasterLimits.categoryName,
      ),
      CategoryError.nameDuplicate => l10n.masterErrNameDuplicate,
      CategoryError.parentMissing => l10n.masterErrParentMissing,
      CategoryError.parentSelf => l10n.masterErrParentSelf,
      CategoryError.parentNested => l10n.masterErrParentNested,
      CategoryError.hasChildren => l10n.masterErrHasChildren,
      CategoryError.colorInvalid => l10n.masterErrColor,
    };

String _actionErrorMessage(AppLocalizations l10n, Object error) =>
    switch (error) {
      MasterInUse(:final products) when products > 0 =>
        l10n.masterInUseProducts(products),
      MasterInUse(:final children) => l10n.masterInUseChildren(children),
      _ => l10n.masterActionFailed,
    };

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.viewModel});

  final MasterDataViewModel viewModel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final narrow = width < 600;
      final list = _CategoryList(viewModel: viewModel, narrow: narrow);
      if (narrow) return list;
      final form = _CategoryForm(viewModel: viewModel);
      if (width >= 860) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(child: list),
            SizedBox(width: 340, child: form),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [list, form],
      );
    },
  );
}

/// Ponsel: form kategori di lembar bawah.
void _openFormSheet(BuildContext context, MasterDataViewModel vm) {
  showFSheet<void>(
    context: context,
    side: .btt,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: sheetContext.theme.colors.background,
        border: Border.all(color: sheetContext.theme.colors.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: ListenableBuilder(
            listenable: vm,
            builder: (_, _) => _CategoryForm(
              viewModel: vm,
              bare: true,
              onDone: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.viewModel, required this.narrow});

  final MasterDataViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final rows = vm.categories;
    final error = vm.categoryError;
    return SectionCard(
      title: l10n.masterTabCategories,
      trailing: FButton(
        key: const ValueKey('master-category-new'),
        size: .sm,
        mainAxisSize: .min,
        prefix: const Icon(TablerIcons.plus, size: 16),
        onPress: vm.busy
            ? null
            : () {
                vm.startNew();
                if (narrow) _openFormSheet(context, vm);
              },
        child: Flexible(child: Text(l10n.masterCategoryAdd)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          if (vm.savedName case final name? when narrow)
            FAlert(
              key: const ValueKey('master-category-saved'),
              title: Text(l10n.masterCategorySaved(name)),
            ),
          if (error != null && !vm.editing)
            Text(
              _actionErrorMessage(l10n, error),
              key: const ValueKey('master-category-action-error'),
              style: _errorStyle(context),
            ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.masterCategoryEmpty,
                key: const ValueKey('master-categories-empty'),
                style: _muted(context),
              ),
            )
          else ...[
            if (!narrow)
              DefaultTextStyle.merge(
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    spacing: 12,
                    children: [
                      const SizedBox(width: 104),
                      Expanded(child: Text(l10n.masterColCategory)),
                      SizedBox(
                        width: 64,
                        child: Text(
                          l10n.masterColProducts,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      SizedBox(width: 52, child: Text(l10n.masterColActive)),
                      const SizedBox(width: 64),
                    ],
                  ),
                ),
              ),
            for (var i = 0; i < rows.length; i++)
              _CategoryRowView(
                key: ValueKey('master-category-${rows[i].category.id.uuid}'),
                viewModel: vm,
                row: rows[i],
                first: i == 0,
                last: i == rows.length - 1,
                narrow: narrow,
              ),
          ],
          Text(l10n.masterOrderHint, style: _muted(context)),
        ],
      ),
    );
  }
}

class _CategoryName extends StatelessWidget {
  const _CategoryName({required this.row});

  final CategoryRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final c = row.category;
    final color = categoryColor(c.color);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (color != null) ColorDot(color: color),
        if (row.parentName case final parent?)
          Text('$parent ›', style: _muted(context)),
        Text(
          c.name,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: c.isActive
                ? theme.colors.foreground
                : theme.colors.mutedForeground,
          ),
        ),
        if (!c.isActive)
          FBadge(
            variant: .outline,
            child: Text(l10n.masterCategoryInactive),
          )
        else if (!c.showInCashier)
          FBadge(
            variant: .secondary,
            child: Text(l10n.masterCategoryHidden),
          ),
      ],
    );
  }
}

class _CategoryRowView extends StatelessWidget {
  const _CategoryRowView({
    super.key,
    required this.viewModel,
    required this.row,
    required this.first,
    required this.last,
    required this.narrow,
  });

  final MasterDataViewModel viewModel;
  final CategoryRow row;
  final bool first;
  final bool last;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final c = row.category;
    final id = c.id.uuid;
    final selected = vm.editingId == c.id;
    final order = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          TablerIcons.gripVertical,
          size: 16,
          color: theme.colors.mutedForeground,
        ),
        FButton.icon(
          key: ValueKey('master-category-up-$id'),
          variant: .ghost,
          size: .sm,
          semanticsLabel: l10n.masterMoveUp(c.name),
          onPress: first || vm.busy ? null : () => vm.move.execute((c.id, -1)),
          child: const Icon(TablerIcons.chevronUp, size: 16),
        ),
        FButton.icon(
          key: ValueKey('master-category-down-$id'),
          variant: .ghost,
          size: .sm,
          semanticsLabel: l10n.masterMoveDown(c.name),
          onPress: last || vm.busy ? null : () => vm.move.execute((c.id, 1)),
          child: const Icon(TablerIcons.chevronDown, size: 16),
        ),
      ],
    );
    final active = FSwitch(
      key: ValueKey('master-category-active-$id'),
      semanticsLabel: '${l10n.masterColActive} ${c.name}',
      value: c.isActive,
      enabled: !vm.busy,
      onChange: (v) => vm.toggleActive.execute((c.id, v)),
    );
    final edit = FButton(
      key: ValueKey('master-category-edit-$id'),
      variant: .outline,
      size: .sm,
      mainAxisSize: .min,
      onPress: vm.busy
          ? null
          : () {
              vm.edit(row);
              if (narrow) _openFormSheet(context, vm);
            },
      child: Flexible(child: Text(l10n.masterCategoryEdit)),
    );
    final decoration = BoxDecoration(
      color: selected ? theme.colors.secondary : null,
      border: Border(top: BorderSide(color: theme.colors.border)),
    );
    if (narrow) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              _CategoryName(row: row),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.masterProductCount(row.productCount),
                      style: _muted(context),
                    ),
                  ),
                  active,
                ],
              ),
              Row(
                children: [
                  order,
                  const Spacer(),
                  edit,
                ],
              ),
            ],
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          spacing: 12,
          children: [
            SizedBox(width: 104, child: order),
            Expanded(child: _CategoryName(row: row)),
            SizedBox(
              width: 64,
              child: Text(
                '${row.productCount}',
                textAlign: TextAlign.end,
                style: theme.typography.body.sm,
              ),
            ),
            SizedBox(width: 52, child: active),
            SizedBox(width: 64, child: edit),
          ],
        ),
      ),
    );
  }
}

class _CategoryForm extends StatelessWidget {
  const _CategoryForm({
    required this.viewModel,
    this.bare = false,
    this.onDone,
  });

  final MasterDataViewModel viewModel;

  /// Tanpa kartu (di lembar bawah ponsel).
  final bool bare;

  /// Dipanggil setelah simpan/hapus berhasil atau *Batal* (menutup lembar).
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final rev = vm.formRevision;
    final errors = vm.formErrors;
    String? fieldError(Set<CategoryError> kinds) {
      final e = errors.where(kinds.contains).firstOrNull;
      return e == null ? null : _categoryErrorMessage(l10n, e);
    }

    final nameError = fieldError(const {
      CategoryError.nameEmpty,
      CategoryError.nameTooLong,
      CategoryError.nameDuplicate,
    });
    final parentError = fieldError(const {
      CategoryError.parentMissing,
      CategoryError.parentSelf,
      CategoryError.parentNested,
      CategoryError.hasChildren,
    });
    final colorError = fieldError(const {CategoryError.colorInvalid});
    final options = vm.parentOptions;
    final none = l10n.masterFormParentNone;
    final busy = vm.busy;

    Future<void> save() async {
      await vm.saveCategory.execute();
      if (vm.saveCategory.completed) onDone?.call();
    }

    Future<void> delete() async {
      await vm.deleteCategory.execute();
      if (vm.deleteCategory.completed) onDone?.call();
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        if (bare)
          Text(
            vm.editing ? l10n.masterFormEdit : l10n.masterFormNew,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (vm.savedName case final name? when !bare)
          FAlert(
            key: const ValueKey('master-category-saved'),
            title: Text(l10n.masterCategorySaved(name)),
          ),
        FTextField(
          key: ValueKey('master-category-name-$rev'),
          label: Text(l10n.masterFormName),
          maxLength: MasterLimits.categoryName,
          enabled: !busy,
          error: nameError == null ? null : Text(nameError),
          control: .managed(
            initial: TextEditingValue(text: vm.name),
            onChange: (v) => vm.setName(v.text),
          ),
          onSubmit: (_) => save(),
        ),
        if (vm.editing &&
            options.isEmpty &&
            vm.categories.any((r) => r.category.parentId == vm.editingId))
          Text(
            l10n.masterFormParentLocked,
            key: const ValueKey('master-category-parent-locked'),
            style: _muted(context),
          )
        else
          FSelect<String>(
            key: ValueKey('master-category-parent-$rev'),
            label: Text(l10n.masterFormParent),
            hint: none,
            enabled: !busy,
            forceErrorText: parentError,
            items: {
              none: '',
              for (final c in options)
                if (c.name != none) c.name: c.id.uuid,
            },
            control: .managed(
              initial: vm.parentId ?? '',
              onChange: (v) => vm.setParent(v == null || v.isEmpty ? null : v),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              l10n.masterFormColor,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorChoice(
                  key: const ValueKey('master-color-none'),
                  color: null,
                  label: l10n.masterColorNone,
                  selected: vm.color == null,
                  onTap: busy ? null : () => vm.setColor(null),
                ),
                for (var i = 0; i < categoryColors.length; i++)
                  _ColorChoice(
                    key: ValueKey('master-color-$i'),
                    color: categoryColor(categoryColors[i]),
                    label: l10n.masterColorPick(i + 1),
                    selected: vm.color == categoryColors[i],
                    onTap: busy ? null : () => vm.setColor(categoryColors[i]),
                  ),
              ],
            ),
            if (colorError != null)
              Text(colorError, style: _errorStyle(context)),
          ],
        ),
        FSwitch(
          key: const ValueKey('master-category-cashier'),
          label: Text(l10n.masterFormShowInCashier),
          description: Text(l10n.masterFormShowInCashierHint),
          value: vm.showInCashier,
          enabled: !busy,
          onChange: vm.setShowInCashier,
        ),
        if (vm.editing)
          FSwitch(
            key: const ValueKey('master-category-form-active'),
            label: Text(l10n.masterFormActive),
            description: Text(l10n.masterFormActiveHint),
            value: vm.isActive,
            enabled: !busy,
            onChange: vm.setActive,
          ),
        if (vm.categoryError case final error? when vm.editing)
          Text(
            _actionErrorMessage(l10n, error),
            key: const ValueKey('master-category-error'),
            style: _errorStyle(context),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            if (vm.editing)
              FButton(
                key: const ValueKey('master-category-delete'),
                variant: .destructive,
                mainAxisSize: .min,
                onPress: busy ? null : delete,
                child: Flexible(child: Text(l10n.masterFormDelete)),
              ),
            FButton(
              key: const ValueKey('master-category-cancel'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: busy
                  ? null
                  : () {
                      vm.startNew();
                      onDone?.call();
                    },
              child: Flexible(child: Text(l10n.masterFormCancel)),
            ),
            FButton(
              key: const ValueKey('master-category-save'),
              mainAxisSize: .min,
              onPress: busy ? null : save,
              child: Flexible(child: Text(l10n.masterFormSave)),
            ),
          ],
        ),
      ],
    );
    if (bare) {
      return Padding(padding: const EdgeInsets.all(20), child: body);
    }
    return SectionCard(
      key: const ValueKey('master-category-form'),
      title: vm.editing ? l10n.masterFormEdit : l10n.masterFormNew,
      child: body,
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    super.key,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color? color;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FTappable(
      onPress: onTap,
      semanticsLabel: label,
      selected: selected,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? theme.colors.foreground : theme.colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: color == null
            ? Icon(
                TablerIcons.ban,
                size: 18,
                color: theme.colors.mutedForeground,
              )
            : DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
      ),
    );
  }
}

// --- Satuan -----------------------------------------------------------------

String _unitErrorMessage(AppLocalizations l10n, UnitNameError e) => switch (e) {
  UnitNameError.empty => l10n.masterUnitErrEmpty,
  UnitNameError.tooLong => l10n.masterUnitErrTooLong(MasterLimits.unitName),
  UnitNameError.duplicate => l10n.masterUnitErrDuplicate,
};

class _UnitsTab extends StatefulWidget {
  const _UnitsTab({required this.viewModel});

  final MasterDataViewModel viewModel;

  @override
  State<_UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends State<_UnitsTab> {
  final _newName = TextEditingController();
  UuidValue? _editing;
  var _editName = '';

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  MasterDataViewModel get _vm => widget.viewModel;

  Future<void> _add() async {
    if (await _vm.addUnit(_newName.text) && mounted) _newName.clear();
  }

  Future<void> _rename(UuidValue id) async {
    if (await _vm.renameUnit(id, _editName) && mounted) {
      setState(() => _editing = null);
    }
  }

  void _startEdit(MeasureUnit u) {
    _vm.clearUnitError();
    setState(() {
      _editing = u.id;
      _editName = u.name;
    });
  }

  void _cancelEdit() {
    _vm.clearUnitError();
    setState(() => _editing = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = _vm;
    final busy = vm.busy;
    Widget? errorFor(UuidValue? id) {
      if (vm.unitError case final e? when vm.unitErrorId == id) {
        return Text(
          _unitErrorMessage(l10n, e),
          key: const ValueKey('master-unit-error'),
          style: _errorStyle(context),
        );
      }
      if (vm.unitInUse case final e? when id != null && vm.unitInUseId == id) {
        return Text(
          l10n.masterInUseProducts(e.products),
          key: const ValueKey('master-unit-in-use'),
          style: _errorStyle(context),
        );
      }
      return null;
    }

    return SectionCard(
      title: l10n.masterTabUnits,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(l10n.masterUnitsHint, style: _muted(context)),
          if (vm.units.isEmpty)
            Text(
              l10n.masterUnitEmpty,
              key: const ValueKey('master-units-empty'),
              style: _muted(context),
            ),
          for (final r in vm.units)
            if (_editing == r.unit.id)
              Column(
                key: ValueKey('master-unit-${r.unit.id.uuid}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  FTextField(
                    key: ValueKey('master-unit-edit-${r.unit.id.uuid}'),
                    label: Text(l10n.masterUnitName),
                    maxLength: MasterLimits.unitName,
                    autofocus: true,
                    enabled: !busy,
                    control: .managed(
                      initial: TextEditingValue(text: r.unit.name),
                      onChange: (v) => _editName = v.text,
                    ),
                    onSubmit: (_) => _rename(r.unit.id),
                  ),
                  ?errorFor(r.unit.id),
                  Wrap(
                    spacing: 8,
                    children: [
                      FButton(
                        key: ValueKey('master-unit-save-${r.unit.id.uuid}'),
                        mainAxisSize: .min,
                        onPress: busy ? null : () => _rename(r.unit.id),
                        child: Flexible(child: Text(l10n.masterUnitSave)),
                      ),
                      FButton(
                        variant: .outline,
                        mainAxisSize: .min,
                        onPress: busy ? null : _cancelEdit,
                        child: Flexible(child: Text(l10n.masterUnitCancel)),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                key: ValueKey('master-unit-${r.unit.id.uuid}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        TablerIcons.ruler2,
                        size: 18,
                        color: theme.colors.mutedForeground,
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              r.unit.name,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l10n.masterProductCount(r.productCount),
                              style: _muted(context),
                            ),
                          ],
                        ),
                      ),
                      FButton.icon(
                        key: ValueKey('master-unit-rename-${r.unit.id.uuid}'),
                        variant: .ghost,
                        size: .sm,
                        semanticsLabel: l10n.masterUnitRename(r.unit.name),
                        onPress: busy || _editing != null
                            ? null
                            : () => _startEdit(r.unit),
                        child: const Icon(TablerIcons.pencil, size: 16),
                      ),
                      FButton.icon(
                        key: ValueKey('master-unit-delete-${r.unit.id.uuid}'),
                        variant: .ghost,
                        size: .sm,
                        semanticsLabel: l10n.masterUnitDelete(r.unit.name),
                        onPress: busy || _editing != null
                            ? null
                            : () => vm.deleteUnit(r.unit.id),
                        child: const Icon(TablerIcons.trash, size: 16),
                      ),
                    ],
                  ),
                  ?errorFor(r.unit.id),
                ],
              ),
          if (_editing == null) ...[
            FTextField(
              key: const ValueKey('master-unit-new'),
              label: Text(l10n.masterUnitName),
              maxLength: MasterLimits.unitName,
              enabled: !busy,
              control: .managed(controller: _newName),
              onSubmit: (_) => _add(),
            ),
            ?errorFor(null),
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                key: const ValueKey('master-unit-add'),
                mainAxisSize: .min,
                prefix: const Icon(TablerIcons.plus, size: 16),
                onPress: busy ? null : _add,
                child: Flexible(child: Text(l10n.masterUnitAdd)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Lokasi stok & metode bayar ---------------------------------------------

class _LocationsTab extends StatelessWidget {
  const _LocationsTab({required this.viewModel, required this.canManage});

  final MasterDataViewModel viewModel;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return SectionCard(
      title: l10n.masterTabLocations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(l10n.masterLocationsHint, style: _muted(context)),
          for (final l in viewModel.locations)
            Row(
              key: ValueKey('master-location-${l.id.uuid}'),
              spacing: 8,
              children: [
                Icon(
                  TablerIcons.buildingWarehouse,
                  size: 18,
                  color: theme.colors.mutedForeground,
                ),
                Flexible(
                  child: Text(
                    l.name,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (l.isDefault)
                  FBadge(
                    variant: .secondary,
                    child: Text(l10n.stockLocationDefault),
                  ),
              ],
            ),
          if (canManage)
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                key: const ValueKey('master-locations-manage'),
                variant: .outline,
                mainAxisSize: .min,
                suffix: const Icon(TablerIcons.arrowRight, size: 16),
                onPress: () => context.go(Routes.stockTab('locations')),
                child: Flexible(child: Text(l10n.masterLocationsManage)),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    IconData icon(PaymentMethod m) => switch (m) {
      PaymentMethod.cash => TablerIcons.cash,
      PaymentMethod.card => TablerIcons.creditCard,
      PaymentMethod.transfer => TablerIcons.buildingBank,
      PaymentMethod.qrisStatic => TablerIcons.qrcode,
    };
    return SectionCard(
      title: l10n.masterTabPayments,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(l10n.masterPaymentsHint, style: _muted(context)),
          for (final m in PaymentMethod.values)
            Row(
              key: ValueKey('master-payment-${m.name}'),
              spacing: 8,
              children: [
                Icon(icon(m), size: 18, color: theme.colors.mutedForeground),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        paymentMethodLabel(l10n, m),
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        m == PaymentMethod.qrisStatic
                            ? l10n.masterPaymentQrisHint
                            : l10n.masterPaymentAlways,
                        style: _muted(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (canManage)
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                key: const ValueKey('master-payments-open'),
                variant: .outline,
                mainAxisSize: .min,
                suffix: const Icon(TablerIcons.arrowRight, size: 16),
                onPress: () => context.go(Routes.settings),
                child: Flexible(child: Text(l10n.masterPaymentsOpen)),
              ),
            ),
        ],
      ),
    );
  }
}
