import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  const sembako = CategoryRef(id: 'a', name: 'Sembako');
  const minuman = CategoryRef(id: 'b', name: 'Minuman');
  const kopi = CategoryRef(id: 'c', name: 'Kopi', parentId: 'b');
  const all = [sembako, minuman, kopi];

  group('validateCategory', () {
    test('nama wajib, maks 60 karakter terlihat, unik tanpa beda huruf', () {
      expect(validateCategory(const CategoryDraft(name: '  '), existing: all), [
        CategoryError.nameEmpty,
      ]);
      expect(validateCategory(CategoryDraft(name: 'a' * 61), existing: all), [
        CategoryError.nameTooLong,
      ]);
      // 60 emoji = 60 karakter terlihat.
      expect(
        validateCategory(CategoryDraft(name: '🍜' * 60), existing: all),
        isEmpty,
      );
      expect(
        validateCategory(const CategoryDraft(name: ' sembako '), existing: all),
        [CategoryError.nameDuplicate],
      );
      // Mengubah kategori sendiri dengan nama yang sama boleh.
      expect(
        validateCategory(
          const CategoryDraft(name: 'SEMBAKO'),
          id: 'a',
          existing: all,
        ),
        isEmpty,
      );
    });

    test('induk satu tingkat dan harus ada', () {
      expect(
        validateCategory(
          const CategoryDraft(name: 'Teh', parentId: 'b'),
          existing: all,
        ),
        isEmpty,
      );
      expect(
        validateCategory(
          const CategoryDraft(name: 'Teh', parentId: 'zzz'),
          existing: all,
        ),
        [CategoryError.parentMissing],
      );
      expect(
        validateCategory(
          const CategoryDraft(name: 'Sembako', parentId: 'a'),
          id: 'a',
          existing: all,
        ),
        [CategoryError.parentSelf],
      );
      // Kopi sudah subkategori, tidak boleh jadi induk.
      expect(
        validateCategory(
          const CategoryDraft(name: 'Espresso', parentId: 'c'),
          existing: all,
        ),
        [CategoryError.parentNested],
      );
      // Minuman punya subkategori, tidak boleh diberi induk.
      expect(
        validateCategory(
          const CategoryDraft(name: 'Minuman', parentId: 'a'),
          id: 'b',
          existing: all,
        ),
        [CategoryError.hasChildren],
      );
    });

    test('warna kosong atau dari palet', () {
      expect(
        validateCategory(
          CategoryDraft(name: 'Teh', color: categoryColors.first),
          existing: all,
        ),
        isEmpty,
      );
      expect(
        validateCategory(
          const CategoryDraft(name: 'Teh', color: '#123456'),
          existing: all,
        ),
        [CategoryError.colorInvalid],
      );
      expect(categoryColors, hasLength(8));
    });

    test('beberapa galat sekaligus', () {
      expect(
        validateCategory(
          const CategoryDraft(name: '', parentId: 'zzz', color: 'x'),
          existing: all,
        ),
        [
          CategoryError.nameEmpty,
          CategoryError.parentMissing,
          CategoryError.colorInvalid,
        ],
      );
    });
  });

  test('validateUnitName: wajib, maks 30, unik tanpa beda huruf', () {
    expect(validateUnitName(' ', existing: const []), UnitNameError.empty);
    expect(
      validateUnitName('x' * 31, existing: const []),
      UnitNameError.tooLong,
    );
    expect(
      validateUnitName('PCS', existing: const ['pcs', 'dus']),
      UnitNameError.duplicate,
    );
    expect(validateUnitName('botol', existing: const ['pcs']), isNull);
  });

  test('moveInOrder: naik, turun, dan di ujung tidak berubah', () {
    const items = ['a', 'b', 'c'];
    expect(moveInOrder(items, 1, -1), ['b', 'a', 'c']);
    expect(moveInOrder(items, 1, 1), ['a', 'c', 'b']);
    expect(moveInOrder(items, 0, -1), items);
    expect(moveInOrder(items, 2, 1), items);
    expect(moveInOrder(items, 5, 1), items);
  });
}
