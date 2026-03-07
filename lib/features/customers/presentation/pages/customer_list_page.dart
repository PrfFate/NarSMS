import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/pagination_widget.dart';
import '../../../../config/routes/app_router.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../../core/widgets/custom_list_card.dart';
import '../../../../core/widgets/delete_confirmation_dialog.dart';

/// Page displaying the paginated customer list.
/// Design matches the existing device_list_page pattern.
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  int _currentPage = 1;
  static const int _pageSize = 15;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    context.read<CustomerBloc>().add(
          LoadCustomers(page: _currentPage, pageSize: _pageSize),
        );
  }

  void _onSearch(String query) {
    _currentPage = 1;
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _loadCustomers();
    } else {
      context.read<CustomerBloc>().add(
            SearchCustomers(
              name: query.trim(),
              page: _currentPage,
              pageSize: _pageSize,
            ),
          );
    }
  }

  void _onPageChanged(int page) {
    _currentPage = page;
    if (_searchQuery.isEmpty) {
      _loadCustomers();
    } else {
      context.read<CustomerBloc>().add(
            SearchCustomers(
              name: _searchQuery,
              page: _currentPage,
              pageSize: _pageSize,
            ),
          );
    }
  }

  Future<void> _onDeleteCustomer(int id, String name) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Müşteri Sil',
      itemName: name,
    );
    if (confirmed == true && mounted) {
      context.read<CustomerBloc>().add(DeleteCustomer(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadCustomers();
        } else if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Müşteriler',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRouter.customerAdd,
                    );
                    if (result == true) _loadCustomers();
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Yeni Müşteri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SearchInputWidget(
                    hintText: 'Müşteri ara...',
                    onSearch: _onSearch,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Müşteri Listesi
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomerLoaded) {
                    final customers = state.result.items;

                    if (customers.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        Expanded(child: _buildCustomerList(customers)),
                        const SizedBox(height: 8),
                        PaginationWidget(
                          currentPage: state.result.page,
                          totalPages: state.result.totalPages,
                          totalItems: state.result.totalCount,
                          itemsPerPage: _pageSize,
                          onPageChanged: _onPageChanged,
                        ),
                      ],
                    );
                  }

                  if (state is CustomerError) {
                    return _buildErrorState(state.message);
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(List<CustomerEntity> customers) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: customers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final customer = customers[index];
          return CustomListCard(
            title: customer.name,
            subtitle: customer.phone != null && customer.phone!.isNotEmpty 
                ? customer.phone! 
                : 'Telefon Yok',
            onTap: () {
              if (customer.id != null) {
                Navigator.pushNamed(
                  context,
                  AppRouter.customerDetail,
                  arguments: customer.id,
                );
              }
            },
            onEdit: () async {
              if (customer.id != null) {
                final result = await Navigator.pushNamed(
                  context,
                  AppRouter.customerEdit,
                  arguments: customer,
                );
                if (result == true) _loadCustomers();
              }
            },
            onDelete: () {
              if (customer.id != null) {
                _onDeleteCustomer(customer.id!, customer.name);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: Color(0xFFF57C00),
            ),
            SizedBox(height: 16),
            Text(
              'Müşteri bulunamadı',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
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
