import 'package:flutter/material.dart';

/// Aktif sayfanın başlığını AppBar'a bildiren global notifier.
/// HomePage'in AppBar'ı bunu dinleyerek dinamik başlık gösterir.
class PageTitleNotifier extends ValueNotifier<String> {
  PageTitleNotifier() : super('Admin Paneli');

  static final PageTitleNotifier instance = PageTitleNotifier();
}
