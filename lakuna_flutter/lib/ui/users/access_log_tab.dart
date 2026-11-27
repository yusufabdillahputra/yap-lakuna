import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart'
    show StaffAccessKind, UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../customers/customer_labels.dart' show formatLongDate;
import '../products/product_widgets.dart';
import 'users_labels.dart';
import 'users_view_model.dart';

const _tableWidth = 720.0;

/// Label kejadian log masuk/keluar (F1-03h).
String accessKindLabel(AppLocalizations l10n, StaffAccessKind kind) =>
    switch (kind) {
      StaffAccessKind.signInPin => l10n.usersAccessSignInPin,
      StaffAccessKind.signInPassword => l10n.usersAccessSignInPassword,
      StaffAccessKind.signInSetup => l10n.usersAccessSignInSetup,
      StaffAccessKind.signOut => l10n.usersAccessSignOut,
      StaffAccessKind.signOutRemoved => l10n.usersAccessSignOutRemoved,
    };

bool _isSignIn(StaffAccessKind kind) => switch (kind) {
  StaffAccessKind.signInPin ||
  StaffAccessKind.signInPassword ||
  StaffAccessKind.signInSetup => true,
  StaffAccessKind.signOut || StaffAccessKind.signOutRemoved => false,
};

/// Isian filter staf: label unik → id (`''` = semua staf).
Map<String, String> accessStaffItems(String all, List<StaffAccount> staff) {
  final items = <String, String>{all: ''};
  for (final a in staff) {
    var label = a.name;
    for (var n = 2; items.containsKey(label); n++) {
      label = '${a.name} ($n)';
    }
    items[label] = a.id.uuid;
  }
  return items;
}

/// Tab *Log masuk* di Pengguna & role (F1-03h).
class AccessLogTab extends StatelessWidget {
  const AccessLogTab({
    super.key,
    required this.viewModel,
    required this.timezone,
  });

  final UsersViewModel viewModel;

  /// Zona waktu cabang untuk tanggal dan jam.
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final error = vm.accessError;
    return SectionCard(
      key: const ValueKey('users-access'),
      title: l10n.usersAccessTitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final table = constraints.maxWidth >= _tableWidth;
          final filter = FSelect<String>(
            key: const ValueKey('users-access-staff'),
            label: Text(l10n.usersAccessStaff),
            items: accessStaffItems(l10n.usersAccessAllStaff, vm.accounts),
            control: .managed(
              initial: vm.accessStaff?.uuid ?? '',
              onChange: (v) => vm.setAccessStaff(
                v == null || v.isEmpty ? null : UuidValue.fromString(v),
              ),
            ),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(l10n.usersAccessHint, style: muted),
              if (table)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(width: 280, child: filter),
                )
              else
                filter,
              if (vm.accessLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: FCircularProgress()),
                )
              else if (error != null && vm.accessRows.isEmpty)
                LoadFailedAlert(
                  key: const ValueKey('users-access-error'),
                  message: usersErrorMessage(l10n, error),
                  onRetry: vm.loadAccess,
                )
              else if (vm.accessRows.isEmpty)
                Text(
                  l10n.usersAccessEmpty,
                  key: const ValueKey('users-access-empty'),
                  style: muted,
                )
              else ...[
                if (table) _HeaderRow(style: muted),
                ..._grouped(context, table),
                if (error != null)
                  Text(
                    usersErrorMessage(l10n, error),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.destructive,
                    ),
                  ),
                if (vm.accessHasMore)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FButton(
                      key: const ValueKey('users-access-more'),
                      variant: .outline,
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: vm.accessLoadingMore ? null : vm.loadMoreAccess,
                      child: Text(l10n.usersAccessMore),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Baris dikelompokkan per tanggal cabang, terbaru dulu.
  List<Widget> _grouped(BuildContext context, bool table) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final widgets = <Widget>[];
    String? day;
    for (final r in viewModel.accessRows) {
      final local = outletLocalTime(r.log.occurredAt, timezone);
      final label = formatLongDate(l10n, local);
      if (label != day) {
        day = label;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 8),
            child: Text(
              label,
              key: ValueKey('users-access-day-$label'),
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
      widgets.add(
        _AccessRow(
          key: ValueKey('users-access-row-${r.log.id.uuid}'),
          row: r,
          timezone: timezone,
          table: table,
        ),
      );
    }
    return widgets;
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = style.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3);
    return Row(
      spacing: 12,
      children: [
        SizedBox(width: 64, child: Text(l10n.usersAccessColTime, style: s)),
        Expanded(flex: 3, child: Text(l10n.usersAccessColStaff, style: s)),
        Expanded(flex: 4, child: Text(l10n.usersAccessColEvent, style: s)),
        SizedBox(width: 80, child: Text(l10n.usersAccessColDevice, style: s)),
      ],
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    super.key,
    required this.row,
    required this.timezone,
    required this.table,
  });

  final StaffAccessRow row;
  final String? timezone;
  final bool table;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final signIn = _isSignIn(row.log.kind);
    final color = signIn ? theme.colors.primary : theme.colors.mutedForeground;
    final time = Text(
      formatClock(row.log.occurredAt, timezone),
      style: theme.typography.body.sm.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final event = Row(
      spacing: 6,
      children: [
        Icon(
          signIn ? TablerIcons.login : TablerIcons.logout,
          size: 16,
          color: color,
        ),
        Flexible(
          child: Text(
            accessKindLabel(l10n, row.log.kind),
            style: theme.typography.body.sm,
          ),
        ),
      ],
    );
    final name = Text(
      row.staffName,
      style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
      overflow: TextOverflow.ellipsis,
    );
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    if (table) {
      return Row(
        spacing: 12,
        children: [
          SizedBox(width: 64, child: time),
          Expanded(flex: 3, child: name),
          Expanded(flex: 4, child: event),
          SizedBox(
            width: 80,
            child: Text(row.deviceCode, style: theme.typography.body.sm),
          ),
        ],
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: theme.style.borderRadius.md,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            time,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  name,
                  event,
                  Text(l10n.usersAccessDevice(row.deviceCode), style: muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
