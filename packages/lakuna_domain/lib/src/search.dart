/// Rentang bagian [text] yang cocok dengan kata kunci [query] (F1-11k),
/// untuk menyorot barang cocok di hasil cari Riwayat.
///
/// Aturannya sama dengan pencarian barang (F1-11e/j): [query] dipecah per
/// spasi, setiap kata dicari tanpa beda huruf, dan spasi biasa (U+0020) di
/// [text] diabaikan, jadi `5kg` menyorot `5 kg` beserta spasinya. Semua
/// kemunculan dikembalikan sebagai `(awal, akhir)` (akhir eksklusif, indeks
/// UTF-16), urut dan digabung bila bertumpuk atau bersentuhan.
List<(int, int)> searchHighlights(String text, String query) {
  final words = [
    for (final w in query.split(RegExp(r'\s+')))
      if (w.isNotEmpty) w.toLowerCase(),
  ];
  if (words.isEmpty || text.isEmpty) return const [];
  // Huruf kecil per karakter (rune) agar indeks asal tetap terpetakan walau
  // huruf kecilnya lebih panjang (mis. `İ` menjadi dua unit) dan pasangan
  // surrogate ikut dilipat. Tiap unit hasil menyimpan awal dan akhir
  // karakter asalnya.
  final folded = StringBuffer();
  final starts = <int>[];
  final ends = <int>[];
  var i = 0;
  for (final rune in text.runes) {
    final width = rune > 0xFFFF ? 2 : 1;
    if (rune != 0x20) {
      final lower = String.fromCharCode(rune).toLowerCase();
      folded.write(lower);
      for (var k = 0; k < lower.length; k++) {
        starts.add(i);
        ends.add(i + width);
      }
    }
    i += width;
  }
  final haystack = folded.toString();
  final found = <(int, int)>[];
  for (final w in words) {
    for (
      var at = haystack.indexOf(w);
      at >= 0;
      at = haystack.indexOf(w, at + 1)
    ) {
      found.add((starts[at], ends[at + w.length - 1]));
    }
  }
  found.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
  final merged = <(int, int)>[];
  for (final r in found) {
    if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
      final last = merged.removeLast();
      merged.add((last.$1, r.$2 > last.$2 ? r.$2 : last.$2));
    } else {
      merged.add(r);
    }
  }
  return merged;
}
