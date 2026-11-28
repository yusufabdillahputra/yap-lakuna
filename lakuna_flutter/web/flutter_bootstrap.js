{{flutter_js}}
{{flutter_build_config}}

// Semua aset dari server toko sendiri (F2-02 aturan 25): CanvasKit lokal
// (build --no-web-resources-cdn) dan font cadangan tidak diunduh dari
// Google. Glyph di luar font bundel tampil sebagai kotak.
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: "assets/font-fallback/",
  },
});
