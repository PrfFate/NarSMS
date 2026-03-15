import 'package:flutter/material.dart';

class GenericConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? itemName;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final Color accentColor;

  const GenericConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.itemName,
    this.confirmLabel = 'Onayla',
    this.cancelLabel = 'İptal',
    required this.onConfirm,
    this.accentColor = const Color(0xFFF57C00),
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? itemName,
    String confirmLabel = 'Onayla',
    String cancelLabel = 'İptal',
    required VoidCallback onConfirm,
    Color accentColor = const Color(0xFFF57C00),
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => GenericConfirmationDialog(
        title: title,
        message: message,
        itemName: itemName,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        accentColor: accentColor,
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
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),

            // Orange Line
            Container(
              height: 2,
              width: double.infinity,
              color: accentColor,
            ),

            // Message Body
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    if (itemName != null) ...[
                      TextSpan(
                        text: '"$itemName"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const TextSpan(text: ' '),
                    ],
                    TextSpan(text: message),
                    const TextSpan(text: ' onaylıyor musunuz?'),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
