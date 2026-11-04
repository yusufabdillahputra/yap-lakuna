import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/cashier/cart_draft.dart';

import '../../testing/fake_session_repository.dart';

void main() {
  CartDraftLine line() => (
    variantId: UuidValue.fromString(newId()),
    unitId: null,
    quantity: Qty.one,
    discount: null,
  );

  test('kosong saat staf berganti atau logout, tetap untuk staf sama', () {
    final yusuf = sampleStaff();
    final dimas = sampleStaff(name: 'Dimas', role: 'cashier');
    final session = FakeSessionRepository(
      current: yusuf,
      staff: [yusuf, dimas],
    );
    final draft = CartDraft(session)..save(lines: [line()]);
    expect(draft.isEmpty, isFalse);

    // Profil yang sama dimuat ulang: draf tetap.
    session
      ..current = yusuf
      ..notifyListeners();
    expect(draft.lines, hasLength(1));

    session
      ..current = dimas
      ..notifyListeners();
    expect(draft.isEmpty, isTrue);

    draft.save(lines: [line()]);
    session.logout();
    expect(draft.isEmpty, isTrue);
    // Layar kasir staf lama ditutup setelah logout: tidak tersimpan.
    draft.save(lines: [line()]);
    expect(draft.isEmpty, isTrue);
    draft.dispose();
  });

  test('take mengembalikan isi dan mengosongkan draf', () {
    final draft = CartDraft(FakeSessionRepository(current: sampleStaff()))
      ..save(
        lines: [line()],
        billDiscount: const ManualDiscount.amount(Money(500)),
      );
    final taken = draft.take();
    expect(taken.lines, hasLength(1));
    expect(taken.billDiscount, const ManualDiscount.amount(Money(500)));
    expect(draft.isEmpty, isTrue);
    expect(draft.take().lines, isEmpty);
  });
}
