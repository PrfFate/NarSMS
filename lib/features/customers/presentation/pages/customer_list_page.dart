import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/custom_action_menu_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../../core/widgets/custom_list_card.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

/// Müşteri listesi sayfası – sonsuz kaydırma ile.
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  static const int _pageSize = 15;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _showScrollToTop = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCustomers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToTop) setState(() => _showScrollToTop = shouldShow);
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _loadNextPage();
    }
  }

  void _loadCustomers() {
    setState(() { _currentPage = 1; _isLoadingMore = false; });
    context.read<CustomerBloc>().add(LoadCustomers(page: 1, pageSize: _pageSize));
  }

  void _onSearch(String query) {
    setState(() { _searchQuery = query; _currentPage = 1; _isLoadingMore = false; });
    if (query.trim().isEmpty) {
      _loadCustomers();
    } else {
      context.read<CustomerBloc>().add(SearchCustomers(name: query.trim(), page: 1, pageSize: _pageSize));
    }
  }

  void _loadNextPage() {
    final state = context.read<CustomerBloc>().state;
    if (state is! CustomerLoaded) return;
    if (!state.hasMore || _isLoadingMore || state.isLoadingMore) return;
    setState(() { _isLoadingMore = true; _currentPage++; });
    if (_searchQuery.isEmpty) {
      context.read<CustomerBloc>().add(LoadMoreCustomers(
        nextPage: _currentPage, existingCustomers: state.result.items, pageSize: _pageSize,
      ));
    } else {
      context.read<CustomerBloc>().add(LoadMoreSearchCustomers(
        name: _searchQuery, nextPage: _currentPage,
        existingCustomers: state.result.items, pageSize: _pageSize,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          _loadCustomers();
        } else if (state is CustomerLoaded && !state.isLoadingMore) {
          setState(() => _isLoadingMore = false);
        } else if (state is CustomerError) {
          setState(() => _isLoadingMore = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton.small(
                onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
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
              // Toolbar: Yenile + Arama + Yeni Müşteri
              Row(
                children: [
                  CustomRefreshButton(onPressed: _loadCustomers),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SearchInputWidget(
                      hintText: 'Müşteri ara...',
                      onSearch: _onSearch,
                      controller: _searchController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomActionMenuWidget(
                    items: [
                      CustomActionMenuItem(
                        title: 'Yeni Müşteri Ekle',
                        icon: Icons.person_add,
                        onTap: () async {
                          final result = await Navigator.pushNamed(context, AppRouter.customerAdd);
                          if (result == true && context.mounted) _loadCustomers();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerLoading) return const Center(child: CircularProgressIndicator());
                    if (state is CustomerLoaded) {
                      final customers = state.result.items;
                      if (customers.isEmpty) return _buildEmptyState();
                      return _buildCustomerList(customers, state.hasMore, state.isLoadingMore);
                    }
                    if (state is CustomerError) return _buildErrorState(state.message);
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList(List<CustomerEntity> customers, bool hasMore, bool isLoadingMore) {
    return Card(
      color: Colors.white, elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: customers.length + 1,
        separatorBuilder: (_, i) => i < customers.length - 1 ? const Divider(height: 1) : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == customers.length) {
            if (isLoadingMore) return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            if (!hasMore && customers.isNotEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Center(child: Text('Tüm ${customers.length} müşteri listelendi', style: TextStyle(color: Colors.grey[400], fontSize: 12))));
            return const SizedBox.shrink();
          }
          final customer = customers[index];
          return CustomListCard(
            title: customer.name,
            subtitle: customer.phone != null && customer.phone!.isNotEmpty ? customer.phone! : 'Telefon Yok',
            onTap: () {
              if (customer.id != null) {
                Navigator.pushNamed(context, AppRouter.customerDetail, arguments: customer.id);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() => Card(
    color: Colors.white, elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.people, size: 64, color: Color(0xFFF57C00)),
      const SizedBox(height: 16),
      Text(
        _searchQuery.isNotEmpty ? '"$_searchQuery" için sonuç bulunamadı' : 'Müşteri bulunamadı',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    ])),
  );

  Widget _buildErrorState(String message) => Card(
    color: Colors.white, elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      Text(message, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _loadCustomers, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), foregroundColor: Colors.white), child: const Text('Tekrar Dene')),
    ])),
  );
}
