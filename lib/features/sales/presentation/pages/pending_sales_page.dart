import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/auth/role_access_policy.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/custom_action_menu_widget.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/sale_entity.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';

/// Onay bekleyen satışlar sayfası.
class PendingSalesPage extends StatefulWidget {
  const PendingSalesPage({super.key});

  @override
  State<PendingSalesPage> createState() => _PendingSalesPageState();
}

class _PendingSalesPageState extends State<PendingSalesPage> {
  static const int _pageSize = 20;
  static const String _status = 'Pending';

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _showScrollToTop = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }

    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9) {
      _loadNextPage();
    }
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _load();
  }

  void _load() {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });
    context.read<SaleBloc>().add(LoadSalesByStatus(
        status: _status,
        page: 1,
        pageSize: _pageSize,
        customerName: _searchQuery));
  }

  void _loadNextPage() {
    final state = context.read<SaleBloc>().state;
    if (state is! SalesLoaded) return;
    if (!state.hasMore || _isLoadingMore || state.isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    context.read<SaleBloc>().add(LoadMoreSalesByStatus(
          status: _status,
          nextPage: _currentPage,
          existingSales: state.result.items,
          pageSize: _pageSize,
          customerName: _searchQuery,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentRole =
        authState is AuthAuthenticated ? authState.user.roleName : null;
    final canCreateSale = RoleAccessPolicy.canCreateSale(currentRole);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () => _scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut),
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              tooltip: 'Başa Dön',
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomRefreshButton(onPressed: _load),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchInputWidget(
                    hintText: 'Müşteri ara...',
                    onSearch: _onSearch,
                    controller: _searchController,
                  ),
                ),
                if (canCreateSale) ...[
                  const SizedBox(width: 8),
                  CustomActionMenuWidget(
                    items: [
                      CustomActionMenuItem(
                        title: 'Yeni Satış Ekle',
                        icon: Icons.add_shopping_cart,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                              context, AppRouter.saleAdd);
                          if (result == true && context.mounted) {
                            _load();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocConsumer<SaleBloc, SaleState>(
                listener: (context, state) {
                  if (state is SalesLoaded && !state.isLoadingMore) {
                    setState(() => _isLoadingMore = false);
                  }
                  if (state is SaleError) {
                    setState(() => _isLoadingMore = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SaleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SalesLoaded) {
                    final sales = state.result.items;
                    if (sales.isEmpty) return _buildEmpty();
                    return _buildList(
                        sales, state.hasMore, state.isLoadingMore);
                  }
                  if (state is SaleError) return _buildError(state.message);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<SaleEntity> sales, bool hasMore, bool isLoadingMore) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sales.length + 1,
        separatorBuilder: (_, i) => i < sales.length - 1
            ? const Divider(height: 1)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == sales.length) {
            if (isLoadingMore) {
              return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            if (!hasMore && sales.isNotEmpty) {
              return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                      child: Text('Tüm ${sales.length} satış listelendi',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12))));
            }
            return const SizedBox.shrink();
          }
          return _SalePendingCard(sale: sales[index], onRefresh: _load);
        },
      ),
    );
  }

  Widget _buildEmpty() => Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.hourglass_empty, size: 64, color: AppColors.primary),
          SizedBox(height: 16),
          Text('Bekleyen satış bulunamadı',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ])),
      );

  Widget _buildError(String message) => Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  foregroundColor: Colors.white),
              child: const Text('Tekrar Dene')),
        ])),
      );
}

class _SalePendingCard extends StatelessWidget {
  final SaleEntity sale;
  final VoidCallback onRefresh;
  const _SalePendingCard({required this.sale, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(context, AppRouter.saleDetail,
            arguments: sale);
        if (result == true && context.mounted) onRefresh();
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
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sale.customerName ?? '-',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(children: [
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
                      Text(_fmtDate(sale.saleDate),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                  ]),
            ),
            Text('${sale.totalAmount.toStringAsFixed(2)} \$',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
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
