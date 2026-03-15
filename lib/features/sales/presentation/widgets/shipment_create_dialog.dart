import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/shipment_create_request.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_item_entity.dart';
import '../../domain/entities/carrier_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';

class ShipmentCreateDialog extends StatefulWidget {
  final SaleEntity sale;

  const ShipmentCreateDialog({super.key, required this.sale});

  @override
  State<ShipmentCreateDialog> createState() => _ShipmentCreateDialogState();
}

class _ShipmentCreateDialogState extends State<ShipmentCreateDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isCarrierMode = true;
  CarrierEntity? _selectedCarrier;
  UserEntity? _selectedFielder;
  final TextEditingController _trackingController = TextEditingController();
  final List<int> _selectedItemIds = [];

  @override
  void initState() {
    super.initState();
    // Başlangıçta kargo seçeneklerini yükle
    context.read<SaleBloc>().add(LoadShipmentOptions(saleId: widget.sale.id));
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen kargolanacak en az bir ürün seçin')),
      );
      return;
    }

    final request = ShipmentCreateRequest(
      saleId: widget.sale.id,
      carrierId: _selectedCarrier?.id,
      fieldTeamUserId: !_isCarrierMode ? _selectedFielder?.id : null,
      trackingNumber: _isCarrierMode ? _trackingController.text : (_selectedCarrier?.name ?? 'Saha ekibi'),
      shipmentDate: DateTime.now().toIso8601String(),
      saleItemIds: _selectedItemIds,
    );

    context.read<SaleBloc>().add(CreateShipment(request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is ShipmentCreated) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Kargo başarıyla oluşturuldu'),
                backgroundColor: Colors.green),
          );
        } else if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Kargo Oluştur',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentDark),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: BlocBuilder<SaleBloc, SaleState>(
                      builder: (context, state) {
                        if (state is SaleLoading) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ));
                        }

                        if (state is ShipmentOptionsLoaded) {
                          // İlk yüklemede kargolanmamışları seç
                          if (_selectedItemIds.isEmpty &&
                              state.shippedSaleItemIds.length <
                                  (widget.sale.items?.length ?? 0)) {
                            final allIds = widget.sale.items
                                    ?.map((e) => e.id)
                                    .whereType<int>()
                                    .toList() ??
                                [];
                            for (var id in allIds) {
                              if (!state.shippedSaleItemIds.contains(id)) {
                                _selectedItemIds.add(id);
                              }
                            }
                          }
                          return _buildForm(state.carriers, state.fielders,
                              state.shippedSaleItemIds);
                        }

                        return const Center(child: Text('Veriler yüklenemedi'));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentDark,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kargola'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<CarrierEntity> carriers, List<UserEntity> fielders,
      List<int> shippedItemIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kargo Tipi Seçimi
        const Text('Gönderim Tipi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isCarrierMode = true;
                  _selectedCarrier = null;
                  _selectedFielder = null;
                }),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: _isCarrierMode ? AppColors.accentDark : Colors.white,
                    border: Border.all(color: AppColors.accentDark),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Kargo Firması',
                    style: TextStyle(
                      color:
                          _isCarrierMode ? Colors.white : AppColors.accentDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isCarrierMode = false;
                  // Saha Ekibi kargo firmasını otomatik bul ve seç
                  if (carriers.isNotEmpty) {
                    _selectedCarrier = carriers.firstWhere(
                      (c) => c.name.toLowerCase().trim() == 'saha ekibi' || 
                             c.name.toLowerCase().contains('saha ekibi'),
                      orElse: () => carriers.firstWhere(
                        (c) => c.name.toLowerCase().contains('saha'),
                        orElse: () => carriers.first,
                      ),
                    );
                  }
                  _selectedFielder = null;
                }),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color:
                        !_isCarrierMode ? AppColors.accentDark : Colors.white,
                    border: Border.all(color: AppColors.accentDark),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Saha Ekibi',
                    style: TextStyle(
                      color:
                          !_isCarrierMode ? Colors.white : AppColors.accentDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Seçici (Carrier veya Fielder)
        if (_isCarrierMode)
          Autocomplete<CarrierEntity>(
            displayStringForOption: (c) => c.name,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return carriers;
              return carriers.where((c) => c.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (val) => setState(() => _selectedCarrier = val),
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Kargo Firması',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.accentDark, width: 2)),
                  floatingLabelStyle:
                      const TextStyle(color: AppColors.accentDark),
                  labelStyle: TextStyle(
                      color: focusNode.hasFocus || controller.text.isNotEmpty
                          ? AppColors.accentDark
                          : null),
                ),
                validator: (v) =>
                    _selectedCarrier == null ? 'Lütfen firma seçin' : null,
              );
            },
          )
        else ...[
          // Saha Ekibi seçildiğinde Kargo Firması adına otomatik "Saha ekibi" yazılır
          TextFormField(
            key: ValueKey(_selectedCarrier?.id),
            initialValue: _selectedCarrier?.name ?? 'Saha ekibi',
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Kargo Firması',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),
          Autocomplete<UserEntity>(
            displayStringForOption: (u) => u.username ?? u.email,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return fielders;
              return fielders.where((u) => (u.username ?? u.email)
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (val) => setState(() => _selectedFielder = val),
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Saha Personeli',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.accentDark, width: 2)),
                  floatingLabelStyle:
                      const TextStyle(color: AppColors.accentDark),
                  labelStyle: TextStyle(
                      color: focusNode.hasFocus || controller.text.isNotEmpty
                          ? AppColors.accentDark
                          : null),
                ),
                validator: (v) =>
                    _selectedFielder == null ? 'Lütfen personel seçin' : null,
              );
            },
          ),
        ],

        const SizedBox(height: 16),

        // Takip No (Sadece Carrier ise)
        if (_isCarrierMode) ...[
          TextFormField(
            controller: _trackingController,
            decoration: const InputDecoration(
              labelText: 'Takip Numarası',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.accentDark, width: 2)),
              floatingLabelStyle: TextStyle(color: AppColors.accentDark),
              hintText: 'Kargo takip numarasını girin',
            ),
            validator: (v) => (_isCarrierMode && (v == null || v.isEmpty))
                ? 'Takip no gereklidir'
                : null,
          ),
          const SizedBox(height: 16),
        ],

        // Ürün Seçimi
        const Text('Kargolanacak Ürünler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        _buildItemsList(shippedItemIds),
      ],
    );
  }

  Widget _buildItemsList(List<int> shippedItemIds) {
    final items = widget.sale.items ?? [];
    if (items.isEmpty) return const Text('Seçilebilir ürün yok');

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final itemId = item.id ?? -1;
          final isShipped = shippedItemIds.contains(itemId);
          final isSelected = _selectedItemIds.contains(itemId);

          return CheckboxListTile(
            title: Text(
              item.modelName ?? 'Bilinmeyen Ürün',
              style: TextStyle(
                fontSize: 14,
                color: isShipped ? Colors.grey : null,
                decoration: isShipped ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              'Seri: ${item.serialNumber ?? '-'} ${isShipped ? '(Kargolandı)' : ''}',
              style: TextStyle(
                  fontSize: 12, color: isShipped ? Colors.grey : null),
            ),
            value: isShipped || isSelected,
            onChanged: isShipped
                ? null
                : (val) {
                    setState(() {
                      if (val == true) {
                        _selectedItemIds.add(itemId);
                      } else {
                        _selectedItemIds.remove(itemId);
                      }
                    });
                  },
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: isShipped ? Colors.grey : AppColors.accentDark,
            dense: true,
          );
        },
      ),
    );
  }
}
