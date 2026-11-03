import 'dart:convert';
import 'dart:typed_data';

import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';

/// PNG asli 2 × 3 px (vertikal) untuk tes gambar QRIS.
final Uint8List tinyPortraitPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAADCAIAAAA2iEnWAAAADklEQVR4nGP4DwYMKBQAvFgR71PJ'
  '/rgAAAAASUVORK5CYII=',
);

CashierQris sampleQris() => CashierQris(
  image: tinyPortraitPng,
  merchantName: 'WARUNG CONTOH',
  nmid: 'ID10234567890',
  terminalCode: 'A01',
  settlementNote: 'Rekening BCA 123-456-7890',
);
