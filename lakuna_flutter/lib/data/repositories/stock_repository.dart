import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Satu baris draf penyesuaian yang disimpan di perangkat (F1-08o):
/// `physical` kosong = belum dihitung.
@immutable
class StockAdjustmentDraftLine {
  const StockAdjustmentDraftLine({
    required this.variantId,
    required this.physical,
    required this.note,
    this.countedSystem,
  });

  final UuidValue variantId;
  final Qty? physical;
  final String note;

  /// Stok sistem saat jumlah fisik diisi (F1-08q); `null` = tidak diketahui
  /// (draf lama) atau belum dihitung.
  final Qty? countedSystem;

  @override
  bool operator ==(Object other) =>
      other is StockAdjustmentDraftLine &&
      other.variantId == variantId &&
      other.physical == physical &&
      other.note == note &&
      other.countedSystem == countedSystem;

  @override
  int get hashCode => Object.hash(variantId, physical, note, countedSystem);

  @override
  String toString() =>
      'StockAdjustmentDraftLine($variantId, $physical, $note, '
      '$countedSystem)';
}

/// Draf penyesuaian satu lokasi yang disimpan di perangkat (F1-08o).
@immutable
class StockAdjustmentDraft {
  const StockAdjustmentDraft({
    required this.reason,
    this.note = '',
    this.lines = const [],
  });

  final StockAdjustmentReason reason;
  final String note;
  final List<StockAdjustmentDraftLine> lines;

  String toJson() => jsonEncode({
    'reason': reason.name,
    'note': note,
    'lines': [
      for (final l in lines)
        {
          'variantId': l.variantId.uuid,
          'physical': l.physical?.milli,
          'note': l.note,
          'countedSystem': l.countedSystem?.milli,
        },
    ],
  });

  /// `null` bila [source] bukan draf yang sah, termasuk bila satu barisnya
  /// rusak (jumlah negatif, tipe salah). Varian kembar dipakai sekali.
  static StockAdjustmentDraft? fromJson(String source) {
    try {
      final map = jsonDecode(source);
      if (map is! Map<String, Object?>) return null;
      final reason = StockAdjustmentReason.values
          .where((r) => r.name == map['reason'])
          .firstOrNull;
      final note = map['note'];
      final lines = map['lines'];
      if (reason == null || note is! String || lines is! List) return null;
      final parsed = <StockAdjustmentDraftLine>[];
      for (final l in lines) {
        if (l
            case {
              'variantId': final String id,
              'physical': final int? physical,
              'note': final String lineNote,
            }
            when physical == null || physical >= 0) {
          final variantId = UuidValue.withValidation(id);
          if (parsed.any((p) => p.variantId == variantId)) continue;
          // Draf lama tanpa stok saat dihitung, atau nilainya rusak: tidak
          // diketahui (F1-08q).
          final counted = switch (l['countedSystem']) {
            final int milli when milli >= 0 => Qty(milli),
            _ => null,
          };
          parsed.add(
            StockAdjustmentDraftLine(
              variantId: variantId,
              physical: physical == null ? null : Qty(physical),
              note: lineNote,
              countedSystem: counted,
            ),
          );
        } else {
          return null;
        }
      }
      return StockAdjustmentDraft(reason: reason, note: note, lines: parsed);
    } on Object {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is StockAdjustmentDraft &&
      other.reason == reason &&
      other.note == note &&
      listEquals(other.lines, lines);

  @override
  int get hashCode => Object.hash(reason, note, Object.hashAll(lines));

  @override
  String toString() => 'StockAdjustmentDraft($reason, $note, $lines)';
}

/// Layar Stok (F1-08, 1.18). Melihat butuh `stock:adjust` atau
/// `products:manage`; menyimpan penyesuaian dan mengubah lokasi butuh
/// `stock:adjust`. Izin dicek di sini juga.
abstract class StockRepository {
  /// Lokasi stok cabang, bawaan dulu.
  Future<Result<List<StockLocation>>> locations();

  /// Daftar stok varian barang di [locationId] (bawaan bila `null`).
  Future<Result<List<StockRow>>> stock({UuidValue? locationId});

  /// Varian dengan stok ≤ minimum, paling kritis dulu.
  Future<Result<List<StockRow>>> belowMinimum({UuidValue? locationId});

  Future<Result<StockCard>> card({
    required UuidValue variantId,
    UuidValue? locationId,
  });

  /// Pratinjau nomor penyesuaian berikutnya.
  Future<Result<String>> nextAdjustmentNumber();

  Future<Result<List<StockAdjustmentSummary>>> recentAdjustments();

  /// Gagal dengan `NotPermitted` atau `StockAdjustmentInvalid`.
  Future<Result<StockAdjustmentResult>> saveAdjustment({
    required UuidValue locationId,
    required StockAdjustmentReason reason,
    required List<AdjustmentLine> lines,
    String? note,
  });

  /// Draf penyesuaian [locationId] yang disimpan di perangkat ini
  /// (F1-08o); `null` bila tidak ada. Butuh `stock:adjust`.
  Future<Result<StockAdjustmentDraft?>> adjustmentDraft(UuidValue locationId);

  /// Menyimpan draf [locationId] di perangkat ini; `null` menghapusnya
  /// (F1-08o). Butuh `stock:adjust`.
  Future<Result<void>> saveAdjustmentDraft(
    UuidValue locationId,
    StockAdjustmentDraft? draft,
  );

  /// Gagal dengan `NotPermitted` atau `StockLocationInvalid`.
  Future<Result<StockLocation>> createLocation(String name);

  /// Gagal dengan `NotPermitted`, `StockLocationInvalid`, atau
  /// `StockLocationNotFound`.
  Future<Result<StockLocation>> renameLocation(UuidValue id, String name);
}
