import 'package:flutter/widgets.dart';

import 'app_root.dart';
import 'config/bundled_licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledLicenses();
  runApp(const LakunaRoot());
}
