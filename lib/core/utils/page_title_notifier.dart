import 'package:flutter/material.dart';

/// Aktif sayfanın başlığını AppBar'a bildiren global notifier.
/// HomePage'in AppBar'ı bunu dinleyerek dinamik başlık gösterir.
class PageTitleNotifier extends ValueNotifier<String> {
  PageTitleNotifier() : super('Ana Sayfa');

  static final PageTitleNotifier instance = PageTitleNotifier();
}
