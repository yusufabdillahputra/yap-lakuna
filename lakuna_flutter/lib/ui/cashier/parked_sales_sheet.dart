import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show ParkedNoteTooLong, ParkedSaleRow, parkedNoteMaxLength;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import 'cashier_view_model.dart';

// Nota tersimpan Kasir retail (F1-04d, 1.4b): dialog *Simpan nota* dan
// daftar *Nota tersimpan* (lanjutkan / hapus).

/// Membuka dialog *Simpan nota* untuk keranjang saat ini.
Future<void> parkCashierSale(BuildContext context, CashierViewModel vm) async {
  if (!vm.canPark) return;
  vm.park.clearResult();
  await showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) => ParkDialog(viewModel: vm),
    ),
  );
}

/// Isi dialog *Simpan nota*: catatan opsional bila tanpa pelanggan.
class ParkDialog extends StatefulWidget {
  const ParkDialog({super.key, required this.viewModel});

  final CashierViewModel viewModel;

  @override
  State<ParkDialog> createState() => _ParkDialogState();
}

class _ParkDialogState extends State<ParkDialog> {
  late String _note = widget.viewModel.parkedNote ?? '';
  var _submitted = false;

  bool get _tooLong => _note.trim().characters.length > parkedNoteMaxLength;

  Future<void> _save() async {
    setState(() => _submitted = true);
    final vm = widget.viewModel;
    final withNote = vm.customer == null;
    if (withNote && _tooLong) return;
    await vm.park.execute(withNote ? _note : null);
    if (!mounted) return;
    if (vm.park.completed) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final customer = vm.customer;
        final failure = vm.park.result;
        final tooLong =
            (_submitted && customer == null && _tooLong) ||
            (failure is Error && failure.error is ParkedNoteTooLong);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('park-dialog'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.cashierParkTitle,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(l10n.cashierParkBody, style: muted),
              if (customer != null)
                Text(
                  l10n.cashierParkFor(customer.name),
                  key: const ValueKey('park-customer'),
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                FTextField(
                  key: const ValueKey('park-note'),
                  label: Text(l10n.cashierParkNote),
                  hint: l10n.cashierParkNoteHint,
                  autofocus: true,
                  error: tooLong
                      ? Text(l10n.cashierParkNoteTooLong(parkedNoteMaxLength))
                      : null,
                  onSubmit: (_) => _save(),
                  control: .managed(
                    initial: TextEditingValue(
                      text: _note,
                      selection: TextSelection(
                        baseOffset: 0,
                        extentOffset: _note.length,
                      ),
                    ),
                    onChange: (v) => setState(() => _note = v.text),
                  ),
                ),
              if (vm.park.error && !tooLong)
                FAlert(
                  key: const ValueKey('park-error'),
                  variant: .destructive,
                  title: Text(l10n.cashierParkFailed),
                ),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FButton(
                      variant: .outline,
                      onPress: vm.park.running
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Flexible(
                        child: Text(
                          l10n.cashierCancel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FButton(
                      key: const ValueKey('park-save'),
                      onPress: vm.park.running ? null : _save,
                      child: Flexible(
                        child: Text(
                          l10n.cashierPark,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Membuka daftar *Nota tersimpan* cabang ini.
Future<void> showParkedSales(BuildContext context, CashierViewModel vm) async {
  vm.resumeParked.clearResult();
  vm.deleteParked.clearResult();
  vm.parked.execute();
  await showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
      builder: (context, style) => ParkedSalesList(viewModel: vm),
    ),
  );
}

/// Judul baris nota tersimpan: pelanggan/catatan atau *Tanpa nama*.
String parkedTitle(AppLocalizations l10n, ParkedSaleRow row) =>
    row.title ?? l10n.cashierParkedNoName;

/// Isi dialog *Nota tersimpan*.
class ParkedSalesList extends StatelessWidget {
  const ParkedSalesList({super.key, required this.viewModel});

  final CashierViewModel viewModel;

  Future<void> _resume(BuildContext context, ParkedSaleRow row) async {
    await viewModel.resumeParked.execute(row.id);
    if (!context.mounted) return;
    if (viewModel.resumeParked.completed) Navigator.of(context).pop();
  }

  Future<void> _delete(BuildContext context, ParkedSaleRow row) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        builder: (context, style) {
          final theme = context.theme;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('parked-confirm'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.cashierParkedDeleteTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.cashierParkedDeleteBody(parkedTitle(l10n, row)),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FButton(
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(false),
                      child: Flexible(child: Text(l10n.cashierCancel)),
                    ),
                    FButton(
                      key: const ValueKey('parked-confirm-delete'),
                      variant: .destructive,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(true),
                      child: Flexible(child: Text(l10n.cashierParkedDelete)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    if (ok ?? false) await viewModel.deleteParked.execute(row.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final rows = vm.parkedRows;
        final busy = vm.resumeParked.running || vm.deleteParked.running;
        final Widget body;
        if (rows.isEmpty && vm.parked.running) {
          body = const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: FCircularProgress()),
          );
        } else if (rows.isEmpty && vm.parked.error) {
          body = LoadFailedAlert(
            key: const ValueKey('parked-load-error'),
            message: l10n.cashierParkedLoadFailed,
            onRetry: vm.parked.execute,
          );
        } else if (rows.isEmpty) {
          body = Text(
            l10n.cashierParkedEmpty,
            key: const ValueKey('parked-empty'),
            style: muted,
          );
        } else {
          body = Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, r) in rows.indexed) ...[
                    if (i > 0) Container(height: 1, color: theme.colors.border),
                    _ParkedTile(
                      row: r,
                      timezone: vm.data?.timezone,
                      canResume: vm.canResume && !busy,
                      canDelete: !busy,
                      onResume: () => _resume(context, r),
                      onDelete: () => _delete(context, r),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('parked-list'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.cashierParkedTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!vm.cartIsEmpty && rows.isNotEmpty)
                  Text(
                    l10n.cashierParkedCartBusy,
                    key: const ValueKey('parked-cart-busy'),
                    style: muted,
                  ),
                if (vm.resumeParked.error)
                  FAlert(
                    key: const ValueKey('parked-resume-error'),
                    variant: .destructive,
                    title: Text(l10n.cashierParkedResumeFailed),
                  ),
                if (vm.deleteParked.error)
                  FAlert(
                    key: const ValueKey('parked-delete-error'),
                    variant: .destructive,
                    title: Text(l10n.cashierParkedDeleteFailed),
                  ),
                body,
                FButton(
                  key: const ValueKey('parked-close'),
                  variant: .outline,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(
                    child: Text(
                      l10n.cashierParkedClose,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParkedTile extends StatelessWidget {
  const _ParkedTile({
    required this.row,
    required this.timezone,
    required this.canResume,
    required this.canDelete,
    required this.onResume,
    required this.onDelete,
  });

  final ParkedSaleRow row;
  final String? timezone;
  final bool canResume;
  final bool canDelete;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          parkedTitle(l10n, row),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          l10n.cashierParkedMeta(
            row.itemCount,
            formatClock(row.savedAt, timezone),
            row.staffName,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        Text(
          formatMoney(context, row.total),
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
    final resume = FButton(
      key: ValueKey('parked-resume-${row.id.uuid}'),
      mainAxisSize: .min,
      onPress: canResume ? onResume : null,
      child: Flexible(
        child: Text(
          l10n.cashierParkedResume,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    Widget actions({required bool stretch}) => Row(
      mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
      spacing: 8,
      children: [
        FButton.icon(
          key: ValueKey('parked-delete-${row.id.uuid}'),
          variant: .ghost,
          onPress: canDelete ? onDelete : null,
          child: Semantics(
            label: l10n.cashierParkedDelete,
            child: Icon(TablerIcons.trash, color: theme.colors.destructive),
          ),
        ),
        if (stretch) Expanded(child: resume) else resume,
      ],
    );
    return Padding(
      key: ValueKey('parked-${row.id.uuid}'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      // Dialog sempit (ponsel): tombol pindah ke bawah info.
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 320
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  info,
                  actions(stretch: true),
                ],
              )
            : Row(
                spacing: 10,
                children: [
                  Expanded(child: info),
                  actions(stretch: false),
                ],
              ),
      ),
    );
  }
}
