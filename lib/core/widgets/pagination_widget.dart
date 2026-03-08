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
    if (totalItems == 0) return const SizedBox.shrink();

    // 1 tabanlı sayfalama için (eğer backend'den 0 geliyorsa diye Math.max ile koruma)
    final safeCurrentPage = currentPage < 1 ? 1 : currentPage;
    
    int startItem = (safeCurrentPage - 1) * itemsPerPage + 1;
    int endItem = safeCurrentPage * itemsPerPage;

    if (endItem > totalItems) {
      endItem = totalItems;
    }
    if (startItem > totalItems) {
      startItem = totalItems == 0 ? 0 : totalItems;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Info text: 16-30 / 3238 kayıt
          Text(
            '$startItem-$endItem / $totalItems kayıt',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable row prevents buttons from stacking vertically on small screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _buildPageButtons().length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  _buildPageButtons()[i],
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];

    // First
    buttons.add(_buildButton('«', currentPage > 1 ? 1 : null));
    // Prev
    buttons.add(_buildButton('<', currentPage > 1 ? currentPage - 1 : null));

    // Page Numbers
    List<String> pages = _generatePageNumbers();
    for (String pageStr in pages) {
      if (pageStr == '...') {
        buttons.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: const Text(
              '...',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        int page = int.parse(pageStr);
        buttons.add(_buildButton(pageStr, page, isActive: page == currentPage));
      }
    }

    // Next
    buttons.add(
      _buildButton('>', currentPage < totalPages ? currentPage + 1 : null),
    );
    // Last
    buttons.add(
      _buildButton('»', currentPage < totalPages ? totalPages : null),
    );

    return buttons;
  }

  List<String> _generatePageNumbers() {
    // Toplam sayfa sayısı azsa (örneğin 5 ve altı) hepsini göster
    if (totalPages <= 5) {
      return List.generate(totalPages, (index) => (index + 1).toString());
    }

    // Başlardaysak (Örn: 1. veya 2. sayfa)
    if (currentPage <= 2) {
      return ['1', '2', '3', '...', totalPages.toString()];
    }

    // Sonlardaysak (Örn: Son veya sondan bir önceki sayfa)
    if (currentPage >= totalPages - 1) {
      return [
        '1',
        '...',
        (totalPages - 2).toString(),
        (totalPages - 1).toString(),
        totalPages.toString()
      ];
    }

    // Ortadaysak (Sadece Kendisi ve Çevresi + Son Sayfa)
    // İstenilen çıktı:  [Önceki] [Aktif] [Sonraki] ... [Son]
    return [
      (currentPage - 1).toString(),
      currentPage.toString(),
      (currentPage + 1).toString(),
      '...',
      totalPages.toString()
    ];
  }

  Widget _buildButton(String text, int? targetPage, {bool isActive = false}) {
    final bool isDisabled = targetPage == null;
    final primaryColor = const Color(0xFFF57C00);

    return InkWell(
      onTap: isDisabled || isActive ? null : () => onPageChanged(targetPage),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDisabled
                ? Colors.grey[300]!
                : (isActive ? primaryColor : primaryColor),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withAlpha(76),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDisabled
                ? Colors.grey[400]
                : (isActive ? Colors.white : primaryColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
