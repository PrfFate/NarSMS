import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan ortak silme onay modalı.
///
/// Kullanım:
/// ```dart
/// final confirmed = await DeleteConfirmationDialog.show(
///   context: context,
///   title: 'Müşteri Sil',
///   itemName: customer.name,
/// );
/// if (confirmed == true) { /* sil */ }
/// ```
class DeleteConfirmationDialog extends StatelessWidget {
  /// Modalın başlık metni (örn. "Müşteri Sil", "Cihaz Sil")
  final String title;

  /// Silinecek öğenin adı — onay metninde gösterilir
  final String itemName;

  /// İptal butonu etiketi
  final String cancelLabel;

  /// Sil butonu etiketi
  final String deleteLabel;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.itemName,
    this.cancelLabel = 'İptal',
    this.deleteLabel = 'Sil',
  });

  /// Modalı göster ve kullanıcının onayladığını/iptal ettiğini döndür.
  /// `true` → onayladı, `false` veya `null` → iptal etti.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String itemName,
    String cancelLabel = 'İptal',
    String deleteLabel = 'Sil',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: title,
        itemName: itemName,
        cancelLabel: cancelLabel,
        deleteLabel: deleteLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        // padding yok — çizginin tam kenara uzanması için her child ayrı Padding alır
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık — üst + yanlarda padding var
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),

            // Boydan boya turuncu çizgi — padding yok, tam genişlik
            Container(
              height: 2,
              color: const Color(0xFFF57C00),
            ),

            // Onay metni
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                '"$itemName" öğesini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            // Butonlar — alt + yanlarda padding var
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      deleteLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
