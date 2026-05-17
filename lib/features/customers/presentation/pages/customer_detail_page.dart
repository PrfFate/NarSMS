import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/delete_confirmation_dialog.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/detail_section_card.dart';

/// Page displaying detailed information about a single customer.
/// Receives the customer ID via route arguments and fetches the detail.
class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    context.read<CustomerBloc>().add(LoadCustomerDetail(widget.customerId));
  }

  Future<void> _onDeleteCustomer(int id, String name) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Müşteri Sil',
      itemName: name,
    );
    if (confirmed == true && mounted) {
      context.read<CustomerBloc>().add(DeleteCustomer(id));
      Navigator.pop(context, true); // Go back after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: const Text(
          'Müşteri Detay',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerDetailLoaded) {
                final customer = state.customer;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.navy),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRouter.customerEdit,
                          arguments: customer,
                        );
                        if (result == true) _loadDetail();
                      },
                      tooltip: 'Düzenle',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _onDeleteCustomer(
                          customer.id ?? widget.customerId, customer.name),
                      tooltip: 'Sil',
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppColors.accentDark, height: 2.0),
        ),
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerDetailLoaded) {
            return _buildDetailContent(state.customer);
          }

          if (state is CustomerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CustomerBloc>()
                        .add(LoadCustomerDetail(widget.customerId)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailContent(CustomerEntity customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profil Kartı
          DetailSectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C00).withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCityDistrictPreview(customer.address),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        'Müşteri ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.uniqueId ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // İletişim Bilgileri Kartı
          DetailSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İletişim Bilgileri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 16),
                DetailInfoRow(
                  icon: Icons.phone_outlined,
                  title: 'Telefon',
                  value: customer.phone ?? '-',
                ),
                const SizedBox(height: 16),
                DetailInfoRow(
                  icon: Icons.mail_outline,
                  title: 'E-posta',
                  value: customer.email ?? '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Adres Bilgisi Kartı
          DetailSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adres Bilgisi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 16),
                DetailInfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Adres',
                  value: customer.address ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCityDistrictPreview(String? fullAddress) {
    if (fullAddress == null || fullAddress.trim().isEmpty) return '-';

    // Edit sayfasında adresi "İlçe, İl\nAdres Detayı" formatında kaydediyoruz.
    // İlk satırı alıp il/ilçe bilgisini göstermeye çalışalım.
    final lines = fullAddress.trim().split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines.first.trim();
      // Eğer ilk satırda virgül varsa (İlçe, İl formatındaysa) doğrudan göster
      if (firstLine.contains(',')) {
        return firstLine;
      }

      // Virgül yoksa ama adres çok uzun değilse ilk 30 karakterini göster
      if (firstLine.length < 30) {
        return firstLine;
      }
    }

    return 'Adres Kayıtlı';
  }
}
