/// Hybrid logical clock untuk urutan last-writer-wins antar perangkat.
///
/// Disimpan sebagai teks yang bisa diurutkan secara leksikografis:
/// `<millis 13 digit>-<counter 4 digit>-<node>`.
class Hlc implements Comparable<Hlc> {
  const Hlc(this.millis, this.counter, this.node);

  final int millis;
  final int counter;
  final String node;

  static Hlc parse(String text) =>
      tryParse(text) ?? (throw FormatException('format HLC tidak valid', text));

  static Hlc? tryParse(String text) {
    final first = text.indexOf('-');
    if (first < 0) return null;
    final second = text.indexOf('-', first + 1);
    if (second < 0) return null;
    final millis = int.tryParse(text.substring(0, first));
    final counter = int.tryParse(text.substring(first + 1, second));
    final node = text.substring(second + 1);
    if (millis == null || counter == null || node.isEmpty) return null;
    return Hlc(millis, counter, node);
  }

  /// Stempel untuk peristiwa lokal baru.
  Hlc tick(int nowMillis) => nowMillis > millis
      ? Hlc(nowMillis, 0, node)
      : Hlc(millis, counter + 1, node);

  /// Menggabungkan stempel dari perangkat lain saat pull.
  Hlc receive(Hlc remote, int nowMillis) {
    final max = [
      nowMillis,
      millis,
      remote.millis,
    ].reduce((a, b) => a > b ? a : b);
    final int next;
    if (max == millis && max == remote.millis) {
      next = (counter > remote.counter ? counter : remote.counter) + 1;
    } else if (max == millis) {
      next = counter + 1;
    } else if (max == remote.millis) {
      next = remote.counter + 1;
    } else {
      next = 0;
    }
    return Hlc(max, next, node);
  }

  @override
  int compareTo(Hlc other) {
    if (millis != other.millis) return millis.compareTo(other.millis);
    if (counter != other.counter) return counter.compareTo(other.counter);
    return node.compareTo(other.node);
  }

  bool operator <(Hlc other) => compareTo(other) < 0;
  bool operator >(Hlc other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.millis == millis &&
      other.counter == counter &&
      other.node == node;

  @override
  int get hashCode => Object.hash(millis, counter, node);

  @override
  String toString() =>
      '${millis.toString().padLeft(13, '0')}-'
      '${counter.toString().padLeft(4, '0')}-$node';
}
