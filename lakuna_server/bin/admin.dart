import 'dart:io';

import 'package:lakuna_server/src/sync/admin_cli.dart';

/// Perintah admin server, mis.
/// `dart bin/admin.dart activation-code --note "Toko Ani"`.
Future<void> main(List<String> args) async {
  try {
    stdout.writeln(await runAdminCommand(parseAdminCommand(args)));
  } on AdminUsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  }
}
