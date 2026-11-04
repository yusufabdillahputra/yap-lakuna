import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/session_repository.dart';
import 'cashier_view_model.dart' show DiscountApprover;

/// Satu baris keranjang yang disimpan: varian, satuan konversi, jumlah, dan
/// diskon baris. Harga dan nama diambil ulang dari katalog saat dipulihkan.
typedef CartDraftLine = ({
  UuidValue variantId,
  UuidValue? unitId,
  Qty quantity,
  ManualDiscount? discount,
});

/// Isi draf yang diambil [CartDraft.take].
typedef CartDraftContent = ({
  List<CartDraftLine> lines,
  ManualDiscount? billDiscount,
  DiscountApprover? approver,
});

/// Keranjang kasir retail yang bertahan saat layar Kasir ditutup (F1-04c).
///
/// Hanya di memori dan milik staf yang bertugas: dikosongkan saat staf
/// berganti atau logout, sama seperti persetujuan diskon.
class CartDraft {
  CartDraft(this._session) : _staffId = _session.current?.id {
    _session.addListener(_onSession);
  }

  final SessionRepository _session;
  UuidValue? _staffId;

  List<CartDraftLine> _lines = const [];
  ManualDiscount? _billDiscount;
  DiscountApprover? _approver;

  List<CartDraftLine> get lines => _lines;
  bool get isEmpty => _lines.isEmpty;

  void _onSession() {
    final id = _session.current?.id;
    if (id == _staffId) return;
    _staffId = id;
    clear();
  }

  /// Menyimpan keranjang; keranjang kosong mengosongkan draf.
  void save({
    required List<CartDraftLine> lines,
    ManualDiscount? billDiscount,
    DiscountApprover? approver,
  }) {
    // Layar kasir staf lama ditutup setelah logout: jangan simpan.
    if (lines.isEmpty || _staffId == null || _session.current?.id != _staffId) {
      return clear();
    }
    _lines = List.unmodifiable(lines);
    _billDiscount = billDiscount;
    _approver = approver;
  }

  /// Mengambil isi draf lalu mengosongkannya.
  CartDraftContent take() {
    final content = (
      lines: _lines,
      billDiscount: _billDiscount,
      approver: _approver,
    );
    clear();
    return content;
  }

  void clear() {
    _lines = const [];
    _billDiscount = null;
    _approver = null;
  }

  void dispose() => _session.removeListener(_onSession);
}
