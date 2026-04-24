import 'package:flutter/material.dart';

class CustomActionMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  CustomActionMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class CustomActionMenuWidget extends StatelessWidget {
  final List<CustomActionMenuItem> items;
  
  const CustomActionMenuWidget({super.key, required this.items});

  Widget _menuItem(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF57C00).withAlpha(15),
        border: Border.all(color: const Color(0xFFF57C00).withAlpha(60)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF57C00)),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFFF57C00),
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: PopupMenuButton<int>(
        tooltip: 'İşlemler',
        icon: const Icon(Icons.more_vert, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, 48),
        onSelected: (index) {
          items[index].onTap();
        },
        itemBuilder: (BuildContext context) {
          return List.generate(items.length, (index) {
            final item = items[index];
            return PopupMenuItem<int>(
              value: index,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _menuItem(item.icon, item.title),
            );
          });
        },
      ),
    );
  }
}
