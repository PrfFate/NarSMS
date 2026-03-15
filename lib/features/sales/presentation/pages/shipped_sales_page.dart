import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pagination_widget.dart';
import '../../../../features/customers/domain/entities/paginated_result.dart';
import '../../domain/entities/sale_entity.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';

/// Kargolanan satışlar sayfası.
class ShippedSalesPage extends StatefulWidget {
  const ShippedSalesPage({super.key});

  @override
  State<ShippedSalesPage> createState() => _ShippedSalesPageState();
}

class _ShippedSalesPageState extends State<ShippedSalesPage> {
  static const int _pageSize = 20;
  static const String _status = 'Shipped';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load({int page = 1}) {
    context.read<SaleBloc>().add(LoadSalesByStatus(
          status: _status,
          page: page,
          pageSize: _pageSize,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kargolanan Satışlar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SaleBloc, SaleState>(
              builder: (context, state) {
                if (state is SaleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SalesLoaded) {
                  return _buildContent(state.result);
                }
                if (state is SaleError) {
                  return _buildError(state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PaginatedResult<SaleEntity> result) {
    if (result.items.isEmpty) return _buildEmpty();

    return Column(
      children: [
        Expanded(child: _buildList(result.items)),
        const SizedBox(height: 8),
        PaginationWidget(
          currentPage: result.page,
          totalPages: result.totalPages,
          totalItems: result.totalCount,
          itemsPerPage: _pageSize,
          onPageChanged: (p) => _load(page: p),
        ),
      ],
    );
  }

  Widget _buildList(List<SaleEntity> sales) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sales.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => _SaleShippedCard(
          sale: sales[index],
          onRefresh: _load,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Kargolanan satış bulunamadı',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleShippedCard extends StatelessWidget {
  final SaleEntity sale;
  final VoidCallback onRefresh;
  const _SaleShippedCard({required this.sale, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Shipped sale detail page
        final result = await Navigator.pushNamed(
            context, AppRouter.shippedSaleDetail,
            arguments: sale);

        if (result == true) {
          onRefresh();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.customerName ?? '-',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Fiş #${sale.id}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _fmtDate(sale.saleDate),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${sale.totalAmount.toStringAsFixed(2)} \$',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String? raw) {
    if (raw == null) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
