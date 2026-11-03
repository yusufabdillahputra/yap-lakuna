/// Aturan denah meja F&B (F1-10 v0.14.0): koordinat dunia, palet meja,
/// nama otomatis, snap, dan pembacaan ukuran gambar denah (termasuk SVG).
library;

import 'dart:convert';

import 'image_header.dart';

/// Batas denah. Koordinat dunia: lebar selalu [worldWidth] satuan, tinggi
/// mengikuti rasio gambar, sehingga mengganti gambar tidak menggeser meja.
abstract final class FloorLimits {
  static const worldWidth = 800;
  static const defaultHeight = 560;
  static const minHeight = 200;
  static const maxHeight = 2000;
  static const minSize = 20;
  static const maxSize = 600;
  static const maxPosition = 5000;
  static const grid = 20;

  /// Ukuran gambar denah maks 5 MB.
  static const imageBytes = 5 * 1024 * 1024;
}

/// Ukuran dunia denah untuk gambar [imageWidth] × [imageHeight] piksel.
({int width, int height}) floorWorldSize(int? imageWidth, int? imageHeight) {
  const w = FloorLimits.worldWidth;
  if (imageWidth == null ||
      imageHeight == null ||
      imageWidth <= 0 ||
      imageHeight <= 0) {
    return (width: w, height: FloorLimits.defaultHeight);
  }
  final h = (w * imageHeight / imageWidth).round();
  return (
    width: w,
    height: h.clamp(FloorLimits.minHeight, FloorLimits.maxHeight),
  );
}

/// Bentuk meja di denah (sama urutan dengan enum `TableShape` server).
enum FloorShape { round, square, long, bar }

/// Pilihan palet *Tambah meja* (1.7d).
class TablePreset {
  const TablePreset(this.shape, this.seats, this.width, this.height);

  final FloorShape shape;
  final int seats;
  final int width;
  final int height;

  static const all = [
    TablePreset(FloorShape.round, 2, 60, 60),
    TablePreset(FloorShape.square, 4, 80, 80),
    TablePreset(FloorShape.long, 6, 140, 80),
    TablePreset(FloorShape.long, 8, 180, 80),
    TablePreset(FloorShape.bar, 1, 40, 40),
  ];
}

/// `M<n>` terkecil yang belum dipakai di [existing] (tanpa beda huruf).
String nextTableName(Iterable<String> existing) {
  final used = {for (final e in existing) e.trim().toLowerCase()};
  var n = 1;
  while (used.contains('m$n')) {
    n++;
  }
  return 'M$n';
}

/// [value] ke kelipatan [grid] terdekat (tidak negatif); [grid] ≤ 0 =
/// tanpa snap.
int snapTo(num value, int grid) {
  final v = value < 0 ? 0 : value;
  if (grid <= 0) return v.round();
  return (v / grid).round() * grid;
}

enum FloorTableError { seats, size, position }

/// Kursi 1–99, ukuran 20–600, posisi 0–5000 (x dan y sama-sama ada atau
/// sama-sama kosong = belum ditempatkan).
FloorTableError? validateFloorTable({
  required int seats,
  required int width,
  required int height,
  int? x,
  int? y,
}) {
  if (seats < 1 || seats > 99) return FloorTableError.seats;
  bool size(int v) => v >= FloorLimits.minSize && v <= FloorLimits.maxSize;
  if (!size(width) || !size(height)) return FloorTableError.size;
  if ((x == null) != (y == null)) return FloorTableError.position;
  bool pos(int v) => v >= 0 && v <= FloorLimits.maxPosition;
  if (x != null && (!pos(x) || !pos(y!))) return FloorTableError.position;
  return null;
}

/// Seperti [readImageHeader] ditambah SVG. Ukuran SVG dari `viewBox` lalu
/// `width`/`height`; bila tak terbaca dipakai 800 × 560.
ImageHeader? readFloorImageHeader(List<int> bytes) {
  final raster = readImageHeader(bytes);
  if (raster != null) return raster;
  return _svg(bytes);
}

ImageHeader? _svg(List<int> bytes) {
  final head = utf8.decode(
    bytes.length > 4096 ? bytes.sublist(0, 4096) : bytes,
    allowMalformed: true,
  );
  // Lewati BOM, deklarasi XML, komentar, dan DOCTYPE sebelum elemen akar.
  var rest = head.replaceFirst('﻿', '').trimLeft();
  final prolog = RegExp(r'^(<\?[\s\S]*?\?>|<!--[\s\S]*?-->|<!DOCTYPE[^>]*>)');
  while (true) {
    final m = prolog.firstMatch(rest);
    if (m == null) break;
    rest = rest.substring(m.end).trimLeft();
  }
  final root = RegExp(r'^<svg\b([^>]*)>?').firstMatch(rest);
  if (root == null) return null;
  final attrs = root.group(1) ?? '';
  String? attr(String name) =>
      RegExp('\\b$name\\s*=\\s*["\\\']([^"\\\']*)["\\\']')
          .firstMatch(attrs)
          ?.group(1);

  final viewBox = attr('viewBox')
      ?.trim()
      .split(RegExp(r'[\s,]+'))
      .map(double.tryParse)
      .toList();
  if (viewBox != null && viewBox.length == 4 && !viewBox.contains(null)) {
    final w = viewBox[2]!.round();
    final h = viewBox[3]!.round();
    if (w > 0 && h > 0) return ImageHeader(ImageFormat.svg, w, h);
  }
  int? length(String? v) {
    final m = RegExp(r'^\s*([0-9.]+)\s*(px)?\s*$').firstMatch(v ?? '');
    final d = m == null ? null : double.tryParse(m.group(1)!);
    return d == null || d <= 0 ? null : d.round();
  }

  final w = length(attr('width'));
  final h = length(attr('height'));
  if (w != null && h != null) return ImageHeader(ImageFormat.svg, w, h);
  return const ImageHeader(
    ImageFormat.svg,
    FloorLimits.worldWidth,
    FloorLimits.defaultHeight,
  );
}
