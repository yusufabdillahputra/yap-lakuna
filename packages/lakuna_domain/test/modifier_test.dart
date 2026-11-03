import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

ModifierOptionDraft opt(
  String name, {
  int delta = 0,
  bool isDefault = false,
  bool available = true,
}) => ModifierOptionDraft(
  name: name,
  priceDelta: Money(delta),
  isDefault: isDefault,
  isAvailable: available,
);

ModifierGroupDraft grp(
  String name, {
  int min = 0,
  int max = 1,
  List<ModifierOptionDraft>? options,
}) => ModifierGroupDraft(
  name: name,
  minSelect: min,
  maxSelect: max,
  options: options ?? [opt('A'), opt('B')],
);

void main() {
  group('validateModifierGroup', () {
    test('grup sah', () {
      expect(
        validateModifierGroup(
          grp(
            'Ukuran',
            min: 1,
            options: [
              opt('Reguler', isDefault: true),
              opt('Besar', delta: 4000),
            ],
          ),
          existingNames: const ['Suhu'],
        ),
        isEmpty,
      );
    });

    test('nama wajib, maks 40, unik tanpa beda huruf', () {
      expect(
        validateModifierGroup(grp('  '), existingNames: const []),
        contains(ModifierGroupError.nameEmpty),
      );
      expect(
        validateModifierGroup(grp('x' * 41), existingNames: const []),
        contains(ModifierGroupError.nameTooLong),
      );
      expect(
        validateModifierGroup(grp('😀' * 40), existingNames: const []),
        isEmpty,
      );
      expect(
        validateModifierGroup(grp(' suhu '), existingNames: const ['Suhu']),
        contains(ModifierGroupError.nameDuplicate),
      );
    });

    test('min/maks: maks ≥ 1, min ≤ maks, batas 20', () {
      expect(
        validateModifierGroup(grp('G', max: 0), existingNames: const []),
        contains(ModifierGroupError.selectRange),
      );
      expect(
        validateModifierGroup(
          grp('G', min: 2, max: 1),
          existingNames: const [],
        ),
        contains(ModifierGroupError.selectRange),
      );
      expect(
        validateModifierGroup(grp('G', max: 21), existingNames: const []),
        contains(ModifierGroupError.selectRange),
      );
      // Minimal tidak boleh melebihi jumlah opsi.
      expect(
        validateModifierGroup(
          grp('G', min: 3, max: 3),
          existingNames: const [],
        ),
        contains(ModifierGroupError.minAboveOptions),
      );
    });

    test('opsi: 1–30, nama wajib & unik, harga ±1 juta, bawaan ≤ maks', () {
      expect(
        validateModifierGroup(grp('G', options: []), existingNames: const []),
        contains(ModifierGroupError.optionCount),
      );
      expect(
        validateModifierGroup(
          grp('G', options: [for (var i = 0; i < 31; i++) opt('O$i')]),
          existingNames: const [],
        ),
        contains(ModifierGroupError.optionCount),
      );
      expect(
        validateModifierGroup(
          grp('G', options: [opt('Es'), opt(' es ')]),
          existingNames: const [],
        ),
        contains(ModifierGroupError.optionNameDuplicate),
      );
      expect(
        validateModifierGroup(
          grp('G', options: [opt(''), opt('B')]),
          existingNames: const [],
        ),
        contains(ModifierGroupError.optionNameEmpty),
      );
      expect(
        validateModifierGroup(
          grp('G', options: [opt('x' * 41)]),
          existingNames: const [],
        ),
        contains(ModifierGroupError.optionNameTooLong),
      );
      expect(
        validateModifierGroup(
          grp('G', options: [opt('Tanpa nasi', delta: -3000)]),
          existingNames: const [],
        ),
        isEmpty,
      );
      expect(
        validateModifierGroup(
          grp('G', options: [opt('Mahal', delta: 1000001)]),
          existingNames: const [],
        ),
        contains(ModifierGroupError.optionPrice),
      );
      expect(
        validateModifierGroup(
          grp(
            'G',
            options: [opt('A', isDefault: true), opt('B', isDefault: true)],
          ),
          existingNames: const [],
        ),
        contains(ModifierGroupError.defaultsAboveMax),
      );
    });

    test('indeks opsi yang salah dilaporkan', () {
      final d = grp('G', options: [opt('A'), opt(''), opt('a')]);
      expect(modifierOptionErrors(d), {
        1: ModifierGroupError.optionNameEmpty,
        2: ModifierGroupError.optionNameDuplicate,
      });
    });
  });

  group('validateModifierSelection', () {
    const size = ModifierGroupRule(
      id: 'g1',
      name: 'Ukuran',
      minSelect: 1,
      maxSelect: 1,
      options: [
        ModifierOptionRule(id: 'reg', priceDelta: Money.zero),
        ModifierOptionRule(id: 'big', priceDelta: Money(4000)),
      ],
    );
    const topping = ModifierGroupRule(
      id: 'g2',
      name: 'Topping',
      minSelect: 0,
      maxSelect: 2,
      options: [
        ModifierOptionRule(id: 'boba', priceDelta: Money(5000)),
        ModifierOptionRule(
          id: 'cheese',
          priceDelta: Money(6000),
          available: false,
        ),
        ModifierOptionRule(id: 'shot', priceDelta: Money(7000)),
      ],
    );

    test('pilihan sah memberi total tambahan', () {
      expect(
        validateModifierSelection([size, topping], ['big', 'boba']),
        isNull,
      );
      expect(
        modifierDelta([size, topping], ['big', 'boba', 'shot']),
        const Money(16000),
      );
    });

    test('kurang dari minimal, lebih dari maks, habis, asing, dobel', () {
      expect(
        validateModifierSelection([size, topping], ['boba']),
        ModifierSelectionError.belowMin,
      );
      expect(
        validateModifierSelection([size, topping], ['reg', 'big']),
        ModifierSelectionError.aboveMax,
      );
      expect(
        validateModifierSelection([size, topping], ['reg', 'cheese']),
        ModifierSelectionError.unavailable,
      );
      expect(
        validateModifierSelection([size, topping], ['reg', 'xyz']),
        ModifierSelectionError.unknown,
      );
      expect(
        validateModifierSelection([size, topping], ['reg', 'boba', 'boba']),
        ModifierSelectionError.duplicate,
      );
      // Produk tanpa grup: pilihan kosong sah.
      expect(validateModifierSelection(const [], const []), isNull);
    });

    test('modifierKey terurut dan null bila kosong', () {
      expect(modifierKey(['b', 'a']), 'a,b');
      expect(modifierKey(const []), isNull);
    });

    test('harga satuan dengan tambahan minimal 0', () {
      expect(
        modifiedUnitPrice(const Money(10000), const Money(-3000)),
        const Money(7000),
      );
      expect(modifiedUnitPrice(const Money(2000), const Money(-3000)), isNull);
    });
  });
}
