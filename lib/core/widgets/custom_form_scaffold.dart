import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Projedeki tüm "Ekleme", "Düzenleme" ve "Detay" sayfalarında kullanılacak
/// ortak form iskeleti (Scaffold).
class CustomFormScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  /// İsteğe bağlı: En altta boydan boya görünecek buton metni
  final String? bottomButtonText;

  /// Butona basıldığında çalışacak fonksiyon. `bottomButtonText` verildiğinde zorunludur.
  final VoidCallback? onBottomButtonPressed;

  /// İsteğe bağlı: Birden fazla buton veya özel widget için
  final Widget? bottomWidget;

  /// İşlem asenkron ise dönmesini engellemek ve loading göstermek için
  final bool isLoading;

  /// Arka plan rengini ezmek için
  final Color backgroundColor;

  const CustomFormScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomButtonText,
    this.onBottomButtonPressed,
    this.bottomWidget,
    this.isLoading = false,
    this.backgroundColor = const Color(0xFFF8F9FA),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: AppColors.accentDark, // Uygulama rengi (Turuncu alt çizgi)
            height: 2.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Ana İçerik
          Expanded(
            child:
                body, // SingleChildScrollView veya ListView dışarıdan verilmeli
          ),

          // En alt sabit buton (Eğer sağlanmışsa)
          if (bottomWidget != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: bottomWidget!,
            ),
          ] else if (bottomButtonText != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onBottomButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.accentDark, // Uygulamanın turuncu ana rengi
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          bottomButtonText!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
