import 'package:flutter/material.dart';

class CustomListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadingText;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CustomListCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingText,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Leading Icon/Text Box
            leading ?? Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF57C00).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  leadingText ?? (title.isNotEmpty ? title[0].toUpperCase() : '?'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Trailing
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}
