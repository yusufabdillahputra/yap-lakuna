import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/hosting_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../products/product_widgets.dart' show ChoicePill;
import 'hosting_texts.dart';
import 'join_view_model.dart';

/// Dialog *Gabung ke toko yang sudah memakai hosting* (onboarding dan
/// kartu *Versi hosting*). [restart] memuat ulang aplikasi setelah data
/// toko siap.
Future<void> showJoinHosting(
  BuildContext context, {
  required HostingRepository repository,
  Future<void> Function()? restart,
}) => showFDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
    builder: (context, style) =>
        JoinHostingView(repository: repository, restart: restart),
  ),
);

class JoinHostingView extends StatefulWidget {
  const JoinHostingView({super.key, required this.repository, this.restart});

  final HostingRepository repository;
  final Future<void> Function()? restart;

  @override
  State<JoinHostingView> createState() => _JoinHostingViewState();
}

class _JoinHostingViewState extends State<JoinHostingView> {
  late final _vm = JoinViewModel(
    repository: widget.repository,
    restart: widget.restart,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = _vm;
      final muted = theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      );
      final outlets = vm.outlets;
      final error = switch ((vm.check.result, vm.join.result)) {
        (_, Error(:final error)) || (Error(:final error), _) => error,
        _ => null,
      };
      return PopScope(
        canPop: !vm.join.running && !vm.staged,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('join-hosting'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.joinTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.joinIntro, style: muted),
                FTextField(
                  key: ValueKey('join-server-${vm.serverRevision}'),
                  label: Text(l10n.hostingServerUrlLabel),
                  hint: l10n.hostingServerUrlHint,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enabled: !vm.busy,
                  control: .managed(
                    initial: TextEditingValue(text: vm.serverUrl),
                    onChange: (v) => vm.setServer(v.text),
                  ),
                ),
                FTextField(
                  key: ValueKey('join-code-${vm.codeRevision}'),
                  label: Text(l10n.joinCodeLabel),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !vm.busy,
                  control: .managed(
                    initial: TextEditingValue(text: vm.code),
                    onChange: (v) => vm.setCode(v.text),
                  ),
                ),
                if (outlets == null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FButton(
                      key: const ValueKey('join-check'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: vm.canCheck ? vm.check.execute : null,
                      prefix: vm.check.running
                          ? const FCircularProgress()
                          : const Icon(TablerIcons.plugConnected),
                      child: Flexible(child: Text(l10n.joinCheck)),
                    ),
                  )
                else ...[
                  Text(
                    l10n.joinOutletLabel,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final o in outlets)
                        ChoicePill(
                          key: ValueKey('join-outlet-${o.code}'),
                          label: '${o.name} (${o.code})',
                          selected: vm.outlet?.id == o.id,
                          onTap: vm.busy ? null : () => vm.selectOutlet(o),
                        ),
                    ],
                  ),
                  FTextField(
                    key: const ValueKey('join-device-code'),
                    label: Text(l10n.joinDeviceCode),
                    hint: 'K02',
                    autocorrect: false,
                    textCapitalization: TextCapitalization.characters,
                    enabled: !vm.busy,
                    control: .managed(
                      onChange: (v) => vm.setDeviceCode(v.text),
                    ),
                  ),
                  if (vm.deviceCode.isNotEmpty && !vm.deviceCodeValid)
                    Text(
                      l10n.joinDeviceCodeInvalid,
                      key: const ValueKey('join-device-code-invalid'),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.destructive,
                      ),
                    ),
                  FTextField(
                    key: const ValueKey('join-device-name'),
                    label: Text(l10n.joinDeviceName),
                    hint: l10n.joinDeviceNameHint,
                    enabled: !vm.busy,
                    control: .managed(
                      onChange: (v) => vm.setDeviceName(v.text),
                    ),
                  ),
                  if (vm.localSales > 0)
                    FAlert(
                      key: const ValueKey('join-sales-warning'),
                      variant: .destructive,
                      title: Text(l10n.joinSalesWarning(vm.localSales)),
                    )
                  else
                    Text(l10n.joinReplaceNote, style: muted),
                ],
                if (vm.join.running)
                  Row(
                    key: const ValueKey('join-pulling'),
                    spacing: 8,
                    children: [
                      const FCircularProgress(),
                      Expanded(child: Text(l10n.joinPulling)),
                    ],
                  ),
                if (vm.staged)
                  FAlert(
                    key: const ValueKey('join-staged'),
                    title: Text(l10n.joinReopen),
                  ),
                if (error != null)
                  FAlert(
                    key: const ValueKey('join-error'),
                    variant: .destructive,
                    title: Text(hostingErrorText(l10n, error)),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FButton(
                      key: const ValueKey('join-cancel'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: vm.join.running || vm.staged
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Flexible(child: Text(l10n.hostingCancel)),
                    ),
                    if (outlets != null)
                      FButton(
                        key: const ValueKey('join-submit'),
                        mainAxisSize: .min,
                        onPress: vm.canJoin ? vm.join.execute : null,
                        prefix: const Icon(TablerIcons.devicesPlus),
                        child: Flexible(child: Text(l10n.joinSubmit)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
