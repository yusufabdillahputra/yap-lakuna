import 'package:characters/characters.dart';

/// Batas panjang (karakter terlihat) data master (F1-09).
abstract final class MasterLimits {
  /// Sama dengan field kategori di form produk.
  static const categoryName = 60;

  /// Sama dengan nama satuan di form produk.
  static const unitName = 30;
}

/// Delapan warna kategori (palet Lakuna). Disimpan sebagai hex `#RRGGBB`.
const List<String> categoryColors = [
  '#0069A8', // sky
  '#059669', // emerald
  '#D97706', // amber
  '#E11D48', // rose
  '#7C3AED', // violet
  '#0D9488', // teal
  '#EA580C', // orange
  '#52525B', // zinc
];

/// Kategori yang sudah ada (belum dihapus) untuk validasi.
class CategoryRef {
  const CategoryRef({required this.id, required this.name, this.parentId});

  final String id;
  final String name;
  final String? parentId;
}

/// Isian form kategori (1.17).
class CategoryDraft {
  const CategoryDraft({
    required this.name,
    this.parentId,
    this.color,
    this.showInCashier = true,
    this.isActive = true,
  });

  final String name;
  final String? parentId;
  final String? color;
  final bool showInCashier;
  final bool isActive;
}

enum CategoryError {
  nameEmpty,
  nameTooLong,
  nameDuplicate,

  /// Induk tidak ada (terhapus atau tenant lain).
  parentMissing,

  /// Induk = kategori itu sendiri.
  parentSelf,

  /// Induk sudah subkategori (hanya satu tingkat).
  parentNested,

  /// Kategori yang punya subkategori tidak boleh diberi induk.
  hasChildren,
  colorInvalid,
}

/// Validasi kategori [d] terhadap kategori tenant yang belum dihapus
/// ([existing], termasuk kategori [id] yang sedang diubah).
List<CategoryError> validateCategory(
  CategoryDraft d, {
  String? id,
  required List<CategoryRef> existing,
}) {
  final errors = <CategoryError>[];
  final name = d.name.trim();
  if (name.isEmpty) {
    errors.add(CategoryError.nameEmpty);
  } else if (name.characters.length > MasterLimits.categoryName) {
    errors.add(CategoryError.nameTooLong);
  } else {
    final key = name.toLowerCase();
    if (existing.any((c) => c.id != id && c.name.trim().toLowerCase() == key)) {
      errors.add(CategoryError.nameDuplicate);
    }
  }
  final parentId = d.parentId;
  if (parentId != null) {
    final parent = existing.where((c) => c.id == parentId).firstOrNull;
    if (id != null && parentId == id) {
      errors.add(CategoryError.parentSelf);
    } else if (parent == null) {
      errors.add(CategoryError.parentMissing);
    } else if (parent.parentId != null) {
      errors.add(CategoryError.parentNested);
    } else if (id != null && existing.any((c) => c.parentId == id)) {
      errors.add(CategoryError.hasChildren);
    }
  }
  final color = d.color;
  if (color != null && !categoryColors.contains(color)) {
    errors.add(CategoryError.colorInvalid);
  }
  return errors;
}

enum UnitNameError { empty, tooLong, duplicate }

/// Validasi nama satuan terhadap nama satuan lain di tenant ([existing],
/// tanpa satuan yang sedang diganti namanya).
UnitNameError? validateUnitName(
  String name, {
  required Iterable<String> existing,
}) {
  final t = name.trim();
  if (t.isEmpty) return UnitNameError.empty;
  if (t.characters.length > MasterLimits.unitName) {
    return UnitNameError.tooLong;
  }
  final key = t.toLowerCase();
  if (existing.any((e) => e.trim().toLowerCase() == key)) {
    return UnitNameError.duplicate;
  }
  return null;
}

/// Salinan [items] dengan elemen ke-[index] dipindah [delta] posisi (−1 naik,
/// +1 turun). Di luar batas: salinan tanpa perubahan.
List<T> moveInOrder<T>(List<T> items, int index, int delta) {
  final out = [...items];
  final target = index + delta;
  if (index < 0 || index >= out.length || target < 0 || target >= out.length) {
    return out;
  }
  final item = out.removeAt(index);
  out.insert(target, item);
  return out;
}
