import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int itemsPerPage;
  final int totalItems;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.itemsPerPage = 10,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage > totalItems)
        ? totalItems
        : currentPage * itemsPerPage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info text
          Text(
            'Gösterilen: $startItem - $endItem / $totalItems',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          // Pagination buttons
          Row(
            children: [
              // First page button
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                tooltip: 'İlk Sayfa',
              ),

              // Previous page button
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                tooltip: 'Önceki Sayfa',
              ),

              // Current page indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$currentPage / $totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Next page button
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Sonraki Sayfa',
              ),

              // Last page button
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(totalPages)
                    : null,
                tooltip: 'Son Sayfa',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
