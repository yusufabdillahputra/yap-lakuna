/// Breakpoint tata letak (sama untuk semua platform; ditentukan dari lebar
/// layar, bukan jenis sistem operasi).
enum LayoutSize {
  /// < 600 px: satu kolom, navigasi bawah.
  mobile,

  /// 600–1279 px: sidebar ringkas.
  tablet,

  /// >= 1280 px: sidebar penuh.
  desktop;

  static LayoutSize of(double width) {
    if (width < 600) return mobile;
    if (width < 1280) return tablet;
    return desktop;
  }
}
