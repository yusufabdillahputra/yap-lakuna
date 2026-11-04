import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/cash_drawer_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import 'cash_session_view_model.dart';

/// Layar *Sesi kasir* (F1-03). Memiliki [CashSessionViewModel] dan memuat
/// sesi terbuka saat dibuka.
class CashSessionScreen extends StatefulWidget {
  const CashSessionScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.session,
  });

  final CashDrawerRepository repository;
  final StoreRepository store;
  final SessionRepository session;

  @override
  State<CashSessionScreen> createState() => _CashSessionScreenState();
}

class _CashSessionScreenState extends State<CashSessionScreen> {
  late final _viewModel = CashSessionViewModel(
    repository: widget.repository,
    permissions: widget.session.current?.permissions ?? const {},
  );

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
  Widget build(BuildContext context) => CashSessionView(
    viewModel: _viewModel,
    store: widget.store.current,
    staffName: widget.session.current?.name ?? '',
  );
}

/// Pesan galat umum (bukan milik satu field).
String cashErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      NotPermitted(:final permission) => l10n.cashErrorNotPermitted(
        permission.key,
      ),
      CashSessionAlreadyOpen() => l10n.cashErrorAlreadyOpen,
      CashSessionNotOpen() => l10n.cashErrorNotOpen,
      CashSessionHasOpenSplit() => l10n.cashSessionErrorOpenSplit,
      _ => l10n.cashErrorFailed,
    };

String cashFieldError(AppLocalizations l10n, CashError error) =>
    switch (error) {
      CashError.required => l10n.errorRequired,
      CashError.negative => l10n.cashErrorNegative,
      CashError.notPositive => l10n.cashErrorNotPositive,
      CashError.tooLong => l10n.cashErrorTooLong,
    };

/// Warna jumlah dan pil selisih (sama dengan kanvas 1.3/1.3b).
class _Tone {
  const _Tone({
    required this.positive,
    required this.negative,
    required this.warnBg,
    required this.warnFg,
    required this.okBg,
    required this.okFg,
  });

  factory _Tone.of(BuildContext context) =>
      context.theme.colors.brightness == Brightness.dark
      ? const _Tone(
          positive: Color(0xFF7BF1A8),
          negative: Color(0xFFFFA2A2),
          warnBg: Color(0xFF461901),
          warnFg: Color(0xFFFFD230),
          okBg: Color(0xFF032E15),
          okFg: Color(0xFF7BF1A8),
        )
      : const _Tone(
          positive: Color(0xFF016630),
          negative: Color(0xFFC10007),
          warnBg: Color(0xFFFEF3C6),
          warnFg: Color(0xFF973C00),
          okBg: Color(0xFFDCFCE7),
          okFg: Color(0xFF016630),
        );

  final Color positive;
  final Color negative;
  final Color warnBg;
  final Color warnFg;
  final Color okBg;
  final Color okFg;
}

class CashSessionView extends StatelessWidget {
  const CashSessionView({
    super.key,
    required this.viewModel,
    required this.store,
    required this.staffName,
  });

  final CashSessionViewModel viewModel;
  final StoreContext? store;
  final String staffName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final error = viewModel.error;
        final body = switch (viewModel.stage) {
          CashStage.loading => const Center(child: FCircularProgress()),
          CashStage.loadFailed => _LoadFailed(viewModel: viewModel),
          CashStage.openForm => _OpenForm(
            viewModel: viewModel,
            store: store,
            staffName: staffName,
          ),
          CashStage.drawer => _Drawer(
            viewModel: viewModel,
            store: store,
            staffName: staffName,
          ),
          CashStage.closeForm => _CloseForm(
            viewModel: viewModel,
            store: store,
            staffName: staffName,
          ),
          CashStage.closed => _Closed(viewModel: viewModel, store: store),
        };
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              if (error != null)
                FAlert(
                  key: const ValueKey('cash-error'),
                  variant: .destructive,
                  title: Text(cashErrorMessage(l10n, error)),
                ),
              body,
            ],
          ),
        );
      },
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.viewModel});

  final CashSessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FAlert(
      key: const ValueKey('cash-load-error'),
      variant: .destructive,
      title: Text(l10n.cashLoadFailed),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FButton(
            size: .sm,
            mainAxisSize: .min,
            variant: .outline,
            onPress: viewModel.load.execute,
            child: Flexible(child: Text(l10n.loginRetry)),
          ),
        ),
      ),
    );
  }
}

/// Kepala layar: judul, subjudul, dan aksi di kanan (turun ke bawah judul
/// di layar sempit).
class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final titles = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          title,
          style: theme.typography.display.xl2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle case final s?)
          Text(
            s,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
    final action = this.action;
    if (action == null) return titles;
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [titles, action],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Expanded(child: titles),
                action,
              ],
            ),
    );
  }
}

String _storeLine(StoreContext? store) =>
    store == null ? '' : '${store.tenant.name} · ${store.outlet.name}';

/// Dua kolom (kiri lebar, kanan [sideWidth]) mulai 900 px, selain itu satu
/// kolom dengan urutan [narrowOrder].
class _TwoColumns extends StatelessWidget {
  const _TwoColumns({
    required this.main,
    required this.side,
    required this.sideWidth,
    this.sideFirstWhenNarrow = false,
  });

  final List<Widget> main;
  final Widget side;
  final double sideWidth;

  /// Di layar sempit kartu samping tampil sebelum kartu terakhir kolom
  /// utama (kanvas 1.3b mobile: kartu sesi, formulir, lalu tabel).
  final bool sideFirstWhenNarrow;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 900) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: main,
              ),
            ),
            SizedBox(width: sideWidth, child: side),
          ],
        );
      }
      final children = sideFirstWhenNarrow && main.length > 1
          ? [...main.take(main.length - 1), side, main.last]
          : [...main, side];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: children,
      );
    },
  );
}

class _Card extends StatelessWidget {
  const _Card({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            if (title case final t?)
              Text(
                t,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

Widget _rpPrefix(BuildContext context, FTextFieldStyle style, Set<Object> _) =>
    Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Text(
        'Rp',
        style: context.theme.typography.body.md.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    super.key,
    required this.label,
    required this.onChange,
    this.error,
    this.autofocus = false,
    this.onSubmit,
  });

  final String label;
  final ValueChanged<String> onChange;
  final CashError? error;
  final bool autofocus;
  final ValueChanged<String>? onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = this.error;
    return FTextField(
      label: Text(label),
      keyboardType: TextInputType.number,
      autofocus: autofocus,
      inputFormatters: const [RupiahInputFormatter()],
      prefixBuilder: _rpPrefix,
      onSubmit: onSubmit,
      error: error == null ? null : Text(cashFieldError(l10n, error)),
      control: .managed(
        onChange: (value) => onChange(value.text),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    super.key,
    required this.label,
    required this.onChange,
    this.hint,
    this.error,
    this.onSubmit,
  });

  final String label;
  final String? hint;
  final ValueChanged<String> onChange;
  final CashError? error;
  final ValueChanged<String>? onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = this.error;
    return FTextField(
      label: Text(label),
      hint: hint,
      maxLength: cashNoteMaxLength,
      onSubmit: onSubmit,
      error: error == null ? null : Text(cashFieldError(l10n, error)),
      control: .managed(onChange: (value) => onChange(value.text)),
    );
  }
}

// --- Buka sesi -------------------------------------------------------------

class _OpenForm extends StatelessWidget {
  const _OpenForm({
    required this.viewModel,
    required this.store,
    required this.staffName,
  });

  final CashSessionViewModel viewModel;
  final StoreContext? store;
  final String staffName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final store = this.store;
    final running = viewModel.open.running;
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: _Card(
          key: const ValueKey('cash-open-card'),
          title: l10n.cashOpenTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              if (store != null)
                Text(
                  '${_storeLine(store)} · ${store.device.code} · $staffName',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              Text(l10n.cashOpenBody, style: theme.typography.body.sm),
              _MoneyField(
                key: const ValueKey('cash-opening-cash'),
                label: l10n.cashOpeningCash,
                autofocus: true,
                error: viewModel.openingCashError,
                onChange: viewModel.setOpeningCash,
                onSubmit: viewModel.canOpen
                    ? (_) => viewModel.open.execute()
                    : null,
              ),
              _NoteField(
                key: const ValueKey('cash-opening-note'),
                label: l10n.cashOpeningNote,
                error: viewModel.openingNoteError,
                onChange: viewModel.setOpeningNote,
              ),
              FButton(
                key: const ValueKey('cash-open'),
                onPress: viewModel.canOpen && !running
                    ? viewModel.open.execute
                    : null,
                prefix: running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.lockOpen),
                child: Flexible(child: Text(l10n.cashOpenButton)),
              ),
              if (!viewModel.canOpen)
                _PermissionNote(permission: Permission.cashSessionOpen),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionNote extends StatelessWidget {
  const _PermissionNote({required this.permission});

  final Permission permission;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      AppLocalizations.of(context).cashNeedsPermission(permission.key),
      style: theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
      ),
    );
  }
}

// --- Kas laci (1.3b) -------------------------------------------------------

class _Drawer extends StatelessWidget {
  const _Drawer({
    required this.viewModel,
    required this.store,
    required this.staffName,
  });

  final CashSessionViewModel viewModel;
  final StoreContext? store;
  final String staffName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = viewModel.active!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _Header(
          title: l10n.cashDrawerTitle,
          subtitle:
              '${_storeLine(store)} · ${l10n.cashCashierLabel(staffName)}',
          action: viewModel.canClose
              ? FButton(
                  key: const ValueKey('cash-start-close'),
                  variant: .outline,
                  mainAxisSize: .min,
                  prefix: const Icon(TablerIcons.lock),
                  onPress: viewModel.startClosing,
                  child: Flexible(child: Text(l10n.cashCloseButton)),
                )
              : null,
        ),
        _TwoColumns(
          sideWidth: 360,
          sideFirstWhenNarrow: true,
          main: [
            _ActiveCard(active: active, store: store),
            _MovementsCard(active: active, store: store),
          ],
          side: _MovementForm(viewModel: viewModel),
        ),
      ],
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.active, required this.store});

  final ActiveCashSession active;
  final StoreContext? store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final session = active.session;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          l10n.cashActive,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          l10n.cashOpenedBy(
            formatClock(session.openedAt, store?.outlet.timezone),
            active.openedByName,
            store?.device.code ?? '',
          ),
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
    final expected = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 4,
      children: [
        Text(
          l10n.cashExpected,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        Text(
          formatMoney(context, active.drawer.expectedCash),
          key: const ValueKey('cash-expected'),
          style: theme.typography.display.xl2.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    return _Card(
      key: const ValueKey('cash-active-card'),
      child: LayoutBuilder(
        builder: (context, c) => c.maxWidth < 420
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  info,
                  Align(alignment: Alignment.centerRight, child: expected),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(child: info),
                  expected,
                ],
              ),
      ),
    );
  }
}

class _MovementsCard extends StatelessWidget {
  const _MovementsCard({required this.active, required this.store});

  final ActiveCashSession active;
  final StoreContext? store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tone = _Tone.of(context);
    final timezone = store?.outlet.timezone;
    final session = active.session;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return _Card(
      key: const ValueKey('cash-movements-card'),
      title: l10n.cashMovementsTitle,
      child: LayoutBuilder(
        builder: (context, c) {
          // Kolom Sumber dilipat ke bawah Keterangan bila kartu sempit.
          final narrow = c.maxWidth < 440;
          Widget row({
            required String time,
            required String note,
            required String source,
            required Widget amount,
            Key? key,
            bool header = false,
          }) {
            final style = header ? muted : theme.typography.body.sm;
            final noteCell = narrow && !header
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note, style: style),
                      Text(source, style: muted),
                    ],
                  )
                : Text(note, style: style);
            return Padding(
              key: key,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  SizedBox(width: 48, child: Text(time, style: style)),
                  Expanded(flex: 3, child: noteCell),
                  if (!narrow)
                    Expanded(flex: 2, child: Text(source, style: style)),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: amount,
                    ),
                  ),
                ],
              ),
            );
          }

          final divider = const _Rule();
          final rows = <Widget>[
            row(
              time: l10n.cashColTime,
              note: narrow
                  ? '${l10n.cashColNote} · ${l10n.cashColSource}'
                  : l10n.cashColNote,
              source: l10n.cashColSource,
              amount: Text(l10n.cashColAmount, style: muted),
              header: true,
            ),
            divider,
            row(
              key: const ValueKey('cash-row-opening'),
              time: formatClock(session.openedAt, timezone),
              note: l10n.cashOpeningRow,
              source: l10n.cashSourceOpening,
              amount: Text(
                formatMoney(context, Money(session.openingCash)),
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final m in active.movements) ...[
              divider,
              row(
                key: ValueKey('cash-row-${m.id.uuid}'),
                time: formatClock(m.createdAt, timezone),
                note: m.note,
                source: switch (m.source) {
                  'manual' => l10n.cashSourceManual,
                  purchaseCashSource => l10n.cashSourcePurchase,
                  debtPaymentCashSource => l10n.cashSourceDebtPayment,
                  final other => other,
                },
                amount: Text(
                  '${m.direction == CashDirection.inflow ? '+' : '−'}'
                  '${formatMoney(context, Money(m.amount))}',
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: m.direction == CashDirection.inflow
                        ? tone.positive
                        : tone.negative,
                  ),
                ),
              ),
            ],
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...rows,
              const SizedBox(height: 12),
              Text(l10n.cashMovementsFootnote, style: muted),
            ],
          );
        },
      ),
    );
  }
}

class _MovementForm extends StatelessWidget {
  const _MovementForm({required this.viewModel});

  final CashSessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final enabled = viewModel.canRecordMovement;
    final running = viewModel.saveMovement.running;
    final version = viewModel.movementFormVersion;
    final directions = [CashDirection.outflow, CashDirection.inflow];
    return _Card(
      key: const ValueKey('cash-movement-card'),
      title: l10n.cashRecordTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          FTabs(
            key: const ValueKey('cash-direction'),
            control: .managed(
              initial: directions.indexOf(viewModel.direction),
              onChange: (i) => viewModel.setDirection(directions[i]),
            ),
            children: [
              FTabEntry(
                label: Text(
                  l10n.cashOutflow,
                  key: const ValueKey('cash-direction-outflow'),
                ),
                child: const SizedBox.shrink(),
              ),
              FTabEntry(
                label: Text(
                  l10n.cashInflow,
                  key: const ValueKey('cash-direction-inflow'),
                ),
                child: const SizedBox.shrink(),
              ),
            ],
          ),
          // Kunci versi memasang ulang kedua field (kosong) setiap formulir
          // dikosongkan view model, agar yang tampak sama dengan isinya.
          KeyedSubtree(
            key: ValueKey('cash-movement-form-$version'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _MoneyField(
                  key: const ValueKey('cash-movement-amount'),
                  label: l10n.cashAmount,
                  error: viewModel.movementAmountError,
                  onChange: viewModel.setMovementAmount,
                ),
                _NoteField(
                  key: const ValueKey('cash-movement-note'),
                  label: l10n.cashNote,
                  hint: l10n.cashNoteHint,
                  error: viewModel.movementNoteError,
                  onChange: viewModel.setMovementNote,
                  onSubmit: enabled
                      ? (_) => viewModel.saveMovement.execute()
                      : null,
                ),
              ],
            ),
          ),
          FButton(
            key: const ValueKey('cash-movement-save'),
            onPress: enabled && !running
                ? viewModel.saveMovement.execute
                : null,
            prefix: running ? const FCircularProgress() : null,
            child: Flexible(child: Text(l10n.cashSave)),
          ),
          Text(
            l10n.cashNeedsPermission(Permission.cashMovementsCreate.key),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Tutup sesi (1.3) ------------------------------------------------------

class _CloseForm extends StatelessWidget {
  const _CloseForm({
    required this.viewModel,
    required this.store,
    required this.staffName,
  });

  final CashSessionViewModel viewModel;
  final StoreContext? store;
  final String staffName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _Header(
          title: l10n.cashCloseTitle(staffName),
          subtitle: _storeLine(store),
          action: FButton(
            key: const ValueKey('cash-back-to-drawer'),
            variant: .outline,
            mainAxisSize: .min,
            prefix: const Icon(TablerIcons.arrowLeft),
            onPress: viewModel.cancelClosing,
            child: Flexible(child: Text(l10n.cashBackToDrawer)),
          ),
        ),
        _TwoColumns(
          sideWidth: 400,
          main: [
            _Stats(sales: viewModel.active!.sales),
            _Recap(active: viewModel.active!, store: store),
          ],
          side: _CountCard(viewModel: viewModel),
        ),
      ],
    );
  }
}

/// Tiga kartu angka: jumlah nota, penjualan, dan void/retur (0 sampai
/// F1-11).
class _Stats extends StatelessWidget {
  const _Stats({required this.sales});

  final SessionSalesSummary sales;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 420;
        Widget stat(String label, String value) => FCard(
          child: Padding(
            padding: EdgeInsets.all(narrow ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  label,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style:
                        (narrow
                                ? theme.typography.display.lg
                                : theme.typography.display.xl)
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
        // Tetap satu baris di ponsel (kanvas 1.3): angkanya pendek.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: narrow ? 8 : 12,
            children: [
              Expanded(
                child: stat(l10n.cashStatTransactions, '${sales.count}'),
              ),
              Expanded(
                child: stat(
                  l10n.cashStatSales,
                  formatMoney(context, sales.total),
                ),
              ),
              Expanded(
                child: stat(
                  l10n.cashStatVoids,
                  '${sales.voidCount + sales.returnCount}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Recap extends StatelessWidget {
  const _Recap({required this.active, required this.store});

  final ActiveCashSession active;
  final StoreContext? store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final drawer = active.drawer;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    Widget line(String label, String value, {bool strong = false, Key? key}) {
      final style = strong
          ? theme.typography.body.md.copyWith(fontWeight: FontWeight.w700)
          : theme.typography.body.sm;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          spacing: 12,
          children: [
            Expanded(child: Text(label, style: style)),
            Flexible(
              child: Text(
                value,
                key: key,
                style: style,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return _Card(
      key: const ValueKey('cash-recap-card'),
      title: l10n.cashRecapTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(
            l10n.cashRecapOpening(
              formatClock(active.session.openedAt, store?.outlet.timezone),
            ),
            formatMoney(context, drawer.openingCash),
          ),
          line(
            l10n.cashRecapCashSales,
            '+${formatMoney(context, drawer.cashSales)}',
          ),
          if (drawer.cashRefunds != Money.zero)
            line(
              l10n.cashRecapCashRefunds,
              '−${formatMoney(context, drawer.cashRefunds)}',
              key: const ValueKey('cash-recap-refunds'),
            ),
          line(
            l10n.cashRecapInflow,
            '+${formatMoney(context, drawer.inflow)}',
          ),
          line(
            l10n.cashRecapOutflow,
            '−${formatMoney(context, drawer.outflow)}',
          ),
          const _Rule(vertical: 6),
          line(
            l10n.cashRecapExpected,
            formatMoney(context, drawer.expectedCash),
            strong: true,
            key: const ValueKey('cash-recap-expected'),
          ),
          const _Rule(vertical: 6),
          line(
            l10n.cashRecapNonCash,
            formatMoney(context, active.sales.nonCash),
          ),
          if (active.sales.credit.value > 0)
            line(
              l10n.cashRecapCredit,
              formatMoney(context, active.sales.credit),
              key: const ValueKey('cash-recap-credit'),
            ),
          const SizedBox(height: 8),
          Text(l10n.cashRecapFootnote, style: muted),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.viewModel});

  final CashSessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tone = _Tone.of(context);
    final difference = viewModel.difference;
    final exact = difference == Money.zero;
    final running = viewModel.close.running;
    final noteError = viewModel.closingNoteError;
    final diffText = exact
        ? l10n.cashDifferenceExact
        : '${difference.isNegative ? '−' : '+'}'
              '${formatMoney(context, Money(difference.value.abs()))}';
    return _Card(
      key: const ValueKey('cash-count-card'),
      title: l10n.cashCountTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          for (final d in cashDenominations)
            _CountRow(
              key: ValueKey('cash-count-$d'),
              label: formatMoney(context, Money(d)),
              semanticsLabel: l10n.cashSheetsLabel(
                groupThousands(d, '.'),
              ),
              subtotal: formatMoney(context, viewModel.subtotal(d)),
              onChange: (text) => viewModel.setSheets(d, text),
            ),
          _CountRow(
            key: const ValueKey('cash-count-coins'),
            label: l10n.cashCoins,
            semanticsLabel: l10n.cashCoins,
            subtotal: formatMoney(context, viewModel.coins),
            money: true,
            onChange: viewModel.setCoins,
          ),
          const _Rule(vertical: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.cashCounted,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  formatMoney(context, viewModel.countedTotal),
                  key: const ValueKey('cash-counted'),
                  textAlign: TextAlign.right,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.cashDifference,
                  style: theme.typography.body.sm,
                ),
              ),
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: exact ? tone.okBg : tone.warnBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    child: Text(
                      diffText,
                      key: const ValueKey('cash-difference'),
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: exact ? tone.okFg : tone.warnFg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FTextField(
            key: const ValueKey('cash-closing-note'),
            label: Text(l10n.cashClosingNote),
            hint: exact ? null : l10n.cashClosingNoteHint,
            minLines: 2,
            maxLines: 3,
            maxLength: cashNoteMaxLength,
            error: noteError == null
                ? null
                : Text(cashFieldError(l10n, noteError)),
            control: .managed(
              onChange: (value) => viewModel.setClosingNote(value.text),
            ),
          ),
          FButton(
            key: const ValueKey('cash-close'),
            onPress: viewModel.canClose && !running
                ? viewModel.close.execute
                : null,
            prefix: running
                ? const FCircularProgress()
                : const Icon(TablerIcons.lock),
            child: Flexible(child: Text(l10n.cashCloseButton)),
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.subtotal,
    required this.onChange,
    this.money = false,
  });

  final String label;
  final String semanticsLabel;
  final String subtotal;
  final ValueChanged<String> onChange;

  /// Receh: nominal langsung (dengan titik ribuan), bukan jumlah lembar.
  final bool money;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, c) {
        // Ponsel 320 px: kolom label dan field diperkecil agar subtotal muat.
        final narrow = c.maxWidth < 320;
        return Row(
          spacing: narrow ? 8 : 12,
          children: [
            SizedBox(
              width: narrow ? 76 : 96,
              child: Text(label, style: theme.typography.body.sm),
            ),
            SizedBox(
              width: money ? (narrow ? 100 : 120) : (narrow ? 64 : 80),
              child: Semantics(
                label: semanticsLabel,
                child: FTextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  hint: '0',
                  inputFormatters: [
                    if (money)
                      const RupiahInputFormatter()
                    else ...[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ],
                  control: .managed(
                    onChange: (value) => onChange(value.text),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(subtotal, style: theme.typography.body.sm),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Hasil -----------------------------------------------------------------

class _Closed extends StatelessWidget {
  const _Closed({required this.viewModel, required this.store});

  final CashSessionViewModel viewModel;
  final StoreContext? store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tone = _Tone.of(context);
    final closed = viewModel.closed!;
    final difference = Money(closed.difference ?? 0);
    Widget line(String label, String value, {Color? color, Key? key}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label, style: theme.typography.body.md)),
              Flexible(
                child: Text(
                  value,
                  key: key,
                  textAlign: TextAlign.right,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: _Card(
          key: const ValueKey('cash-closed-card'),
          title: l10n.cashClosedTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                l10n.cashClosedBody(
                  formatClock(
                    closed.closedAt ?? closed.updatedAt,
                    store?.outlet.timezone,
                  ),
                ),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              line(
                l10n.cashRecapExpected,
                formatMoney(context, Money(closed.expectedCash ?? 0)),
              ),
              line(
                l10n.cashCounted,
                formatMoney(context, Money(closed.countedCash ?? 0)),
              ),
              line(
                l10n.cashDifference,
                difference == Money.zero
                    ? l10n.cashDifferenceExact
                    : '${difference.isNegative ? '−' : '+'}'
                          '${formatMoney(context, Money(difference.value.abs()))}',
                color: difference == Money.zero
                    ? tone.positive
                    : (difference.isNegative ? tone.negative : tone.positive),
                key: const ValueKey('cash-closed-difference'),
              ),
              if (closed.closingNote case final note?)
                Text(note, style: theme.typography.body.sm),
              const SizedBox(height: 8),
              FButton(
                key: const ValueKey('cash-start-new'),
                onPress: viewModel.canOpen ? viewModel.startNew : null,
                child: Flexible(child: Text(l10n.cashStartNew)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Garis pemisah tipis antarbaris.
class _Rule extends StatelessWidget {
  const _Rule({this.vertical = 0});

  final double vertical;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: vertical),
    child: SizedBox(
      height: 1,
      child: ColoredBox(color: context.theme.colors.border),
    ),
  );
}
