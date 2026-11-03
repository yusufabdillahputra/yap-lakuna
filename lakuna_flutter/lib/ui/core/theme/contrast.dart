part of 'theme.dart';

// Aturan kontras kanvas "Desain UI Lakuna" (lihat spec F0, bagian "Aturan
// kontras"). Semua teks minimal 4.5:1. Token warna dasar tetap dari CLI
// Forui; di sini hanya gaya widget yang memakai warna itu sebagai teks/ikon
// atau tombol destructive.

/// Sky muda: primary sebagai teks/ikon di tema gelap (11.9:1 di latar).
const _darkPrimaryText = Color(0xFF74D4FF);

/// Teks sekunder di permukaan berwarna tema terang (tab tidak aktif):
/// 7:1 di `muted`, menggantikan `#71717B` (4.4:1).
const _lightMutedOnSurface = Color(0xFF52525C);

/// Isi tombol destructive. Gelap: `#C10007` (6.2:1 dengan teks `#FAFAFA`),
/// bukan `#FF6467` yang hanya 2.8:1.
const _lightDestructiveFill = Color(0xFFE7000B);
const _darkDestructiveFill = Color(0xFFC10007);
const _destructiveFillText = Color(0xFFFAFAFA);

/// Warna untuk widget yang memakai `primary` sebagai teks/ikon.
FColors _textAccentColors(FColors colors) => colors.brightness == .dark
    ? colors.copyWith(primary: _darkPrimaryText)
    : colors;

/// Tombol: semua varian dari Forui, kecuali destructive dibuat isi penuh
/// (`#E7000B` terang / `#C10007` gelap) dengan teks `#FAFAFA`.
FButtonStyles _buttonStyles({
  required FColors colors,
  required FTypography typography,
  required FStyle style,
  required bool touch,
}) {
  final base = FButtonStyles.inherit(
    colors: colors,
    typography: typography,
    style: style,
    touch: touch,
  );
  final destructive = FButtonStyles.inherit(
    colors: colors.copyWith(
      primary: colors.brightness == .dark
          ? _darkDestructiveFill
          : _lightDestructiveFill,
      primaryForeground: _destructiveFillText,
    ),
    typography: typography,
    style: style,
    touch: touch,
  ).primary;
  return FButtonStyles(
    FVariants(
      base.primary,
      variants: {
        [FButtonVariant.primary]: base.primary,
        [FButtonVariant.secondary]: base.secondary,
        [FButtonVariant.destructive]: destructive,
        [FButtonVariant.outline]: base.outline,
        [FButtonVariant.ghost]: base.ghost,
      },
    ),
  );
}

/// [FThemeData] dengan aturan kontras Lakuna.
FThemeData _lakunaTheme({
  required FColors colors,
  required FTypography typography,
  required FIcons icons,
  required FStyle style,
  required bool touch,
}) {
  final accent = _textAccentColors(colors);
  final tabsColors = colors.brightness == .light
      ? colors.copyWith(mutedForeground: _lightMutedOnSurface)
      : colors;
  return FThemeData(
    colors: colors,
    typography: typography,
    icons: icons,
    style: style,
    touch: touch,
    buttonStyles: _buttonStyles(
      colors: colors,
      typography: typography,
      style: style,
      touch: touch,
    ),
    bottomNavigationBarStyle: FBottomNavigationBarStyle.inherit(
      colors: accent,
      typography: typography,
      style: style,
    ),
    itemStyles: FItemStyles.inherit(
      colors: accent,
      typography: typography,
      style: style,
      touch: touch,
    ),
    tileStyles: FTileStyles.inherit(
      colors: accent,
      typography: typography,
      style: style,
    ),
    // Grup membawa gaya tile/item sendiri, jadi ikut memakai warna aksen.
    tileGroupStyle: FTileGroupStyle.inherit(
      colors: accent,
      typography: typography,
      style: style,
      hapticFeedback: const FHapticFeedback(),
    ),
    itemGroupStyle: FItemGroupStyle.inherit(
      colors: accent,
      typography: typography,
      style: style,
      hapticFeedback: const FHapticFeedback(),
      touch: touch,
    ),
    tabsStyle: FTabsStyle.inherit(
      colors: tabsColors,
      typography: typography,
      style: style,
    ),
  );
}

/// Tema Material untuk `MaterialApp`. `toApproximateMaterialTheme()` memberi
/// ikon bawaan warna `primary` (`#00598A`, 2.6:1 di latar gelap) sehingga
/// ikon di dialog, sheet, dan rute Material lain sulit dibaca. Ikon bawaan
/// memakai `style.iconStyle` Forui (warna `foreground`).
ThemeData lakunaMaterialTheme(FThemeData theme) => theme
    .toApproximateMaterialTheme()
    .copyWith(iconTheme: theme.style.iconStyle);
