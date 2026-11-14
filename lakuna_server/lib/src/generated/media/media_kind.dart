/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

/// Jenis berkas media yang diunggah (F1-18; denah meja F1-10; bukti bayar
/// hutang F1-14; foto nota pengeluaran F1-15; foto produk F1-07f; logo
/// struk F1-06b; foto faktur pembelian F1-12b).
enum MediaKind implements _is.SerializableModel {
  qrisSticker,
  floorPlan,
  paymentProof,
  expenseReceipt,
  productPhoto,
  receiptLogo,
  purchaseInvoice;

  static MediaKind fromJson(String name) {
    switch (name) {
      case 'qrisSticker':
        return MediaKind.qrisSticker;
      case 'floorPlan':
        return MediaKind.floorPlan;
      case 'paymentProof':
        return MediaKind.paymentProof;
      case 'expenseReceipt':
        return MediaKind.expenseReceipt;
      case 'productPhoto':
        return MediaKind.productPhoto;
      case 'receiptLogo':
        return MediaKind.receiptLogo;
      case 'purchaseInvoice':
        return MediaKind.purchaseInvoice;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "MediaKind"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
