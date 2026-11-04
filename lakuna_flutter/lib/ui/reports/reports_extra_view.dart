part of 'reports_view.dart';

// Tab lanjutan (F1-16 v0.21.0): Stok, Kas & sesi, Piutang & hutang, Retur.

/// Kolom tabel tab lanjutan.
class _Col {
  const _Col(this.label, {this.flex = 2, this.right = true});

  final String label;
  final int flex;
  final bool right;
}

/// Baris tabel: sel teks; sel terakhir di kartu 360 px tampil di kanan.
class _Line {
  const _Line(this.id, this.cells, {this.strong = false, this.tone});

  final String id;
  final List<String> cells;
  final bool strong;

  /// Warna sel terakhir (mis. selisih kurang).
  final Color? tone;
}

/// KPI berjajar seperti ringkasan: 4 kolom ≥ 900, 2 kolom ≥ 560, lalu 1.
class _KpiRow extends StatelessWidget {
  const _KpiRow(this.kpis);

  final List<_Kpi> kpis;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => _Grid(
      columns: c.maxWidth >= 900
          ? kpis.length
          : c.maxWidth >= 560
          ? 2
          : 1,
      equalHeight: true,
      children: kpis,
    ),
  );
}

/// Tabel kartu: kepala kolom dan baris di ≥ 600 px; di bawahnya tiap baris
/// jadi kartu (sel pertama judul, sel tengah `label: nilai`, sel terakhir di
/// kanan).
class _Table extends StatelessWidget {
  const _Table({
    required this.id,
    required this.title,
    required this.columns,
    required this.lines,
    required this.empty,
    this.cardWidth = _cardListWidth,
  });

  final String id;
  final String title;
  final List<_Col> columns;
  final List<_Line> lines;
  final String empty;

  /// Di bawah lebar ini baris tampil sebagai kartu.
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    return SectionCard(
      key: ValueKey('reports-$id'),
      title: title,
      child: lines.isEmpty
          ? Text(
              empty,
              key: ValueKey('reports-$id-empty'),
              style: _muted(context),
            )
          : LayoutBuilder(
              builder: (context, c) {
                final cards = c.maxWidth < cardWidth;
                Widget cell(String text, int i, {bool strong = false}) {
                  final col = columns[i];
                  return Expanded(
                    flex: col.flex,
                    child: Text(
                      text,
                      textAlign: col.right ? TextAlign.right : TextAlign.left,
                      style: theme.typography.body.sm.copyWith(
                        fontFeatures: _tabular,
                        fontWeight: strong || i == 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  );
                }

                Widget row(_Line l, int index) {
                  final last = l.cells.length - 1;
                  final child = cards
                      ? Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    l.cells.first,
                                    style: theme.typography.body.sm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  for (var i = 1; i < last; i++)
                                    if (l.cells[i].isNotEmpty)
                                      Text(
                                        '${columns[i].label}: ${l.cells[i]}',
                                        style: _muted(context),
                                      ),
                                ],
                              ),
                            ),
                            Text(
                              l.cells[last],
                              style: _amountStyle(
                                context,
                                strong: true,
                              ).copyWith(color: l.tone),
                            ),
                          ],
                        )
                      : Row(
                          spacing: 12,
                          children: [
                            for (var i = 0; i < l.cells.length; i++)
                              if (i == last && l.tone != null)
                                Expanded(
                                  flex: columns[i].flex,
                                  child: Text(
                                    l.cells[i],
                                    textAlign: TextAlign.right,
                                    style: _amountStyle(
                                      context,
                                      strong: true,
                                    ).copyWith(color: l.tone),
                                  ),
                                )
                              else
                                cell(l.cells[i], i, strong: l.strong),
                          ],
                        );
                  return DecoratedBox(
                    key: ValueKey('reports-$id-${l.id}'),
                    decoration: BoxDecoration(
                      color: l.strong ? theme.colors.muted : null,
                      border: index == 0 && cards
                          ? null
                          : Border(
                              top: BorderSide(color: theme.colors.border),
                            ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: child,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!cards)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            for (final col in columns)
                              Expanded(
                                flex: col.flex,
                                child: Text(
                                  col.label,
                                  textAlign: col.right
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: head,
                                ),
                              ),
                          ],
                        ),
                      ),
                    for (final (i, l) in lines.indexed) row(l, i),
                  ],
                );
              },
            ),
    );
  }
}

/// Pemuat / galat tab lanjutan.
Widget _extraState(
  BuildContext context,
  ReportsViewModel vm,
  Object? value,
  Widget Function() build,
) {
  final l10n = AppLocalizations.of(context);
  if (vm.extraError case final error?) {
    return LoadFailedAlert(
      key: const ValueKey('reports-extra-error'),
      message: reportErrorMessage(l10n, error),
      onRetry: vm.load.execute,
    );
  }
  if (value == null) {
    return const Padding(
      key: ValueKey('reports-extra-loading'),
      padding: EdgeInsets.all(24),
      child: Center(child: FCircularProgress()),
    );
  }
  return build();
}

// --- Stok ---------------------------------------------------------------------

class _Stock extends StatelessWidget {
  const _Stock({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) => _extraState(
    context,
    viewModel,
    viewModel.stock,
    () {
      final l10n = AppLocalizations.of(context);
      final r = viewModel.stock!;
      final value = r.totalValue != null;
      String q(StockMovementRow x, Qty qty) =>
          unitQty(l10n, r.unitOf, x.key, qty);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          _KpiRow([
            if (r.totalValue case final v?)
              _Kpi(
                id: 'stock-value',
                label: l10n.reportsStockValue,
                value: formatMoney(context, v),
                note: l10n.reportsStockValueNote,
              ),
            _Kpi(
              id: 'stock-items',
              label: l10n.reportsStockItems,
              value: '${r.variantCount}',
              note: l10n.reportsStockItemsNote,
            ),
            _Kpi(
              id: 'stock-low',
              label: l10n.reportsStockLow,
              value: '${r.lowCount}',
              note: l10n.reportsStockLowNote,
            ),
            _Kpi(
              id: 'stock-out',
              label: l10n.reportsStockOut,
              value: '${r.outCount}',
              note: l10n.reportsStockOutNote,
            ),
          ]),
          _Table(
            id: 'stock-table',
            title: l10n.reportsStockMovement,
            empty: l10n.reportsStockEmpty,
            columns: [
              _Col(l10n.reportsColProduct, flex: 4, right: false),
              _Col(l10n.reportsColOpening),
              _Col(l10n.reportsColIn),
              _Col(l10n.reportsColOut),
              _Col(l10n.reportsColClosing),
              if (value) _Col(l10n.reportsColClosingValue, flex: 3),
            ],
            lines: [
              for (final x in r.rows)
                _Line(x.key, [
                  x.name,
                  q(x, x.opening),
                  q(x, x.inflow),
                  q(x, x.outflow),
                  q(x, x.closing),
                  if (value) formatMoney(context, x.value!),
                ]),
              if (value && r.rows.isNotEmpty)
                _Line('total', [
                  l10n.reportsTotal,
                  '',
                  '',
                  '',
                  '',
                  formatMoney(context, Money.sum(r.rows.map((x) => x.value!))),
                ], strong: true),
            ],
          ),
          Text(l10n.reportsStockNote, style: _muted(context)),
        ],
      );
    },
  );
}

// --- Kas & sesi ---------------------------------------------------------------

class _Cash extends StatelessWidget {
  const _Cash({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) =>
      _extraState(context, viewModel, viewModel.cash, () {
        final l10n = AppLocalizations.of(context);
        final r = viewModel.cash!;
        final danger = context.theme.colors.destructive;
        Color? tone(Money? m) => m == null || m.value >= 0 ? null : danger;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            _KpiRow([
              _Kpi(
                id: 'cash-sessions',
                label: l10n.reportsCashSessions,
                value: '${r.sessions.length}',
                note: l10n.reportsCashSessionsNote(r.openCount),
              ),
              _Kpi(
                id: 'cash-difference',
                label: l10n.reportsCashDifference,
                value: signedMoneyLabel(l10n, r.totalDifference),
                note: l10n.reportsCashDifferenceNote,
              ),
              _Kpi(
                id: 'cash-in',
                label: l10n.reportsCashIn,
                value: formatMoney(context, r.inflow),
                note: l10n.reportsCashMovementsNote,
              ),
              _Kpi(
                id: 'cash-out',
                label: l10n.reportsCashOut,
                value: formatMoney(context, r.outflow),
                note: l10n.reportsCashMovementsNote,
              ),
            ]),
            _Table(
              id: 'cash-sessions',
              title: l10n.reportsCashSessions,
              empty: l10n.reportsCashEmpty,
              columns: [
                _Col(l10n.reportsColOpened, flex: 3, right: false),
                _Col(l10n.reportsColStaff, flex: 3, right: false),
                _Col(l10n.reportsColOpeningCash),
                _Col(l10n.reportsColExpected),
                _Col(l10n.reportsColCounted),
                _Col(l10n.reportsColDifference),
              ],
              lines: [
                for (final (i, s) in r.sessions.indexed)
                  _Line('$i', [
                    receiptDate(s.openedAt),
                    s.staffName,
                    formatMoney(context, s.opening),
                    formatMoney(context, s.expected),
                    if (s.counted case final c?)
                      formatMoney(context, c)
                    else
                      l10n.reportsCashOpen,
                    if (s.difference case final d?)
                      signedMoneyLabel(l10n, d)
                    else
                      '–',
                  ], tone: tone(s.difference)),
              ],
            ),
            _Table(
              id: 'cash-movements',
              title: l10n.reportsCashMovements,
              empty: l10n.reportsCashNoMovements,
              columns: [
                _Col(l10n.reportsColSource, flex: 4, right: false),
                _Col(l10n.reportsColEntries),
                _Col(l10n.reportsColAmount, flex: 3),
              ],
              lines: [
                for (final g in r.inflows)
                  _Line('in-${g.key.name}', [
                    cashSourceLabel(l10n, g.key),
                    '${g.count}',
                    signedMoneyLabel(l10n, g.total),
                  ]),
                for (final g in r.outflows)
                  _Line('out-${g.key.name}', [
                    cashSourceLabel(l10n, g.key),
                    '${g.count}',
                    signedMoneyLabel(l10n, -g.total),
                  ]),
              ],
            ),
            Text(l10n.reportsCashNote, style: _muted(context)),
          ],
        );
      });
}

// --- Piutang & hutang ---------------------------------------------------------

class _Debts extends StatelessWidget {
  const _Debts({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) =>
      _extraState(context, viewModel, viewModel.debts, () {
        final l10n = AppLocalizations.of(context);
        final r = viewModel.debts!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              l10n.reportsDebtAsOf(formatLongDate(l10n, r.today)),
              key: const ValueKey('reports-debts-as-of'),
              style: _muted(context),
            ),
            _KpiRow([
              _Kpi(
                id: 'debt-receivable',
                label: l10n.reportsDebtReceivable,
                value: formatMoney(context, r.receivable),
                note: l10n.reportsDebtCustomersNote(r.customers.length),
              ),
              _Kpi(
                id: 'debt-overdue',
                label: l10n.reportsKpiOverdue,
                value: formatMoney(context, r.overdue),
                note: l10n.reportsKpiOverdueNote(r.overdueCustomers),
              ),
              _Kpi(
                id: 'debt-payable',
                label: l10n.reportsDebtPayable,
                value: formatMoney(context, r.payable),
                note: l10n.reportsDebtSuppliersNote(r.suppliers.length),
              ),
              _Kpi(
                id: 'debt-overdue-purchases',
                label: l10n.reportsDebtOverduePurchases,
                value: '${r.overduePurchases}',
                note: l10n.reportsDebtOverduePurchasesNote,
              ),
            ]),
            _Table(
              id: 'debt-customers',
              title: l10n.reportsDebtCustomers,
              empty: l10n.reportsDebtNoReceivable,
              columns: [
                _Col(l10n.reportsColCustomer, flex: 4, right: false),
                _Col(l10n.reportsColOpenCount),
                _Col(l10n.reportsColOverdueCount),
                _Col(l10n.reportsColRemaining, flex: 3),
              ],
              lines: [
                for (final c in r.customers)
                  _Line(c.customer.id.uuid, [
                    c.customer.name,
                    '${c.openCount}',
                    '${c.overdueCount}',
                    formatMoney(context, c.outstanding),
                  ]),
              ],
            ),
            _Table(
              id: 'debt-suppliers',
              title: l10n.reportsDebtSuppliers,
              empty: l10n.reportsDebtNoPayable,
              columns: [
                _Col(l10n.reportsColSupplier, flex: 4, right: false),
                _Col(l10n.reportsColOpenCount),
                _Col(l10n.reportsColOverdueCount),
                _Col(l10n.reportsColNearestDue, flex: 3),
                _Col(l10n.reportsColRemaining, flex: 3),
              ],
              lines: [
                for (final s in r.suppliers)
                  _Line(s.supplier.id.uuid, [
                    s.supplier.name,
                    '${s.openCount}',
                    '${s.overdueCount}',
                    if (s.nearestDue case final d?)
                      formatCalendarDate(d)
                    else
                      '–',
                    formatMoney(context, s.debt),
                  ]),
              ],
            ),
            Text(l10n.reportsDebtNote, style: _muted(context)),
          ],
        );
      });
}

// --- Retur --------------------------------------------------------------------

class _Returns extends StatelessWidget {
  const _Returns({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) =>
      _extraState(context, viewModel, viewModel.returns, () {
        final l10n = AppLocalizations.of(context);
        final r = viewModel.returns!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            _KpiRow([
              _Kpi(
                id: 'returns-count',
                label: l10n.reportsTabReturns,
                value: '${r.lines.length}',
                note: l10n.reportsReturnsCountNote,
              ),
              _Kpi(
                id: 'returns-total',
                label: l10n.reportsReturnsTotal,
                value: formatMoney(context, r.total),
                note: l10n.reportsReturnsTotalNote,
              ),
              _Kpi(
                id: 'returns-restock',
                label: l10n.reportsReturnsRestock,
                value: '${r.restockCount}',
                note: l10n.reportsReturnsOfCount(r.lines.length),
              ),
              _Kpi(
                id: 'returns-damaged',
                label: l10n.reportsReturnsDamaged,
                value: '${r.damagedCount}',
                note: l10n.reportsReturnsOfCount(r.lines.length),
              ),
            ]),
            _Table(
              id: 'returns-reasons',
              title: l10n.reportsReturnsByReason,
              empty: l10n.reportsReturnsEmpty,
              columns: [
                _Col(l10n.reportsColReason, flex: 4, right: false),
                _Col(l10n.reportsColEntries),
                _Col(l10n.reportsColAmount, flex: 3),
              ],
              lines: [
                for (final g in r.byReason)
                  _Line(g.key.name, [
                    returnReasonLabel(l10n, g.key),
                    '${g.count}',
                    formatMoney(context, g.total),
                  ]),
              ],
            ),
            _Table(
              id: 'returns-list',
              title: l10n.reportsReturnsList,
              cardWidth: 900,
              empty: l10n.reportsReturnsEmpty,
              columns: [
                _Col(l10n.reportsColTime, flex: 3, right: false),
                _Col(l10n.reportsColReturnNo, flex: 5, right: false),
                _Col(l10n.reportsColReceiptNo, flex: 5, right: false),
                _Col(l10n.reportsColHandledBy, flex: 3, right: false),
                _Col(l10n.reportsColReason, flex: 3, right: false),
                _Col(l10n.reportsColRestock),
                _Col(l10n.reportsColRefund, flex: 3, right: false),
                _Col(l10n.reportsColAmount, flex: 3),
              ],
              lines: [
                for (final x in r.lines)
                  _Line(x.number, [
                    receiptDate(x.returnedAt),
                    x.number,
                    x.saleNumber,
                    x.staffName,
                    returnReasonLabel(l10n, x.reason),
                    x.restock ? l10n.reportsYes : l10n.reportsNo,
                    returnRefundLabel(l10n, x),
                    formatMoney(context, x.amount),
                  ]),
              ],
            ),
          ],
        );
      });
}
