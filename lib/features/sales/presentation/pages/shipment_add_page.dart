import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../data/models/shipment_create_request.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/carrier_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../../../core/widgets/device_image_widget.dart';

class ShipmentAddPage extends StatefulWidget {
  final SaleEntity sale;

  const ShipmentAddPage({super.key, required this.sale});

  @override
  State<ShipmentAddPage> createState() => _ShipmentAddPageState();
}

class _ShipmentAddPageState extends State<ShipmentAddPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isCarrierMode = true;
  CarrierEntity? _selectedCarrier;
  UserEntity? _selectedFielder;
  final TextEditingController _trackingController = TextEditingController();
  final List<int> _selectedItemIds = [];
  
  // Verilerin kalıcı olması için yerel state'ler
  List<CarrierEntity> _carriers = [];
  List<UserEntity> _fielders = [];
  List<int> _shippedItemIds = [];
  bool _isInitialLoading = true;

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
      trackingNumber: _isCarrierMode ? _trackingController.text : null,
      shipmentDate: DateTime.now().toUtc().toIso8601String(),
      saleItemIds: _selectedItemIds,
    );

    context.read<SaleBloc>().add(CreateShipment(request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is ShipmentOptionsLoaded) {
          setState(() {
            _carriers = state.carriers;
            _fielders = state.fielders;
            _shippedItemIds = state.shippedSaleItemIds;
            _isInitialLoading = false;

            // İlk yüklemede kargolanmamışları seç
            if (_selectedItemIds.isEmpty &&
                _shippedItemIds.length < (widget.sale.items?.length ?? 0)) {
              final allIds = widget.sale.items
                      ?.map((e) => e.id)
                      .whereType<int>()
                      .toList() ??
                  [];
              for (var id in allIds) {
                if (!_shippedItemIds.contains(id)) {
                  _selectedItemIds.add(id);
                }
              }
            }
          });
        } else if (state is ShipmentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Kargo başarıyla oluşturuldu'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is SaleError) {
          setState(() => _isInitialLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          return CustomFormScaffold(
            title: 'Kargo Oluştur',
            bottomButtonText: 'Kargola',
            isLoading: state is SaleLoading,
            onBottomButtonPressed: _submit,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: _buildBody(state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(SaleState state) {
    if (_isInitialLoading && state is SaleLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_carriers.isNotEmpty || _fielders.isNotEmpty) {
      return _buildForm(_carriers, _fielders, _shippedItemIds);
    }

    if (state is SaleError && _carriers.isEmpty) {
      return Center(child: Text(state.message));
    }

    return const Center(child: Text('Veriler yüklenemedi'));
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
                    color: _isCarrierMode ? const Color(0xFFF57C00) : Colors.white,
                    border: Border.all(color: const Color(0xFFF57C00)),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Kargo Firması',
                    style: TextStyle(
                      color:
                          _isCarrierMode ? Colors.white : const Color(0xFFF57C00),
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
                        !_isCarrierMode ? const Color(0xFFF57C00) : Colors.white,
                    border: Border.all(color: const Color(0xFFF57C00)),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Saha Ekibi',
                    style: TextStyle(
                      color:
                          !_isCarrierMode ? Colors.white : const Color(0xFFF57C00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

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
                          BorderSide(color: Color(0xFFF57C00), width: 2)),
                  floatingLabelStyle:
                      const TextStyle(color: Color(0xFFF57C00)),
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
                          BorderSide(color: Color(0xFFF57C00), width: 2)),
                  floatingLabelStyle:
                      const TextStyle(color: Color(0xFFF57C00)),
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
                      BorderSide(color: Color(0xFFF57C00), width: 2)),
              floatingLabelStyle: TextStyle(color: Color(0xFFF57C00)),
              hintText: 'Kargo takip numarasını girin',
            ),
            validator: (v) => (_isCarrierMode && (v == null || v.isEmpty))
                ? 'Takip no gereklidir'
                : null,
          ),
          const SizedBox(height: 24),
        ],

        // Ürün Seçimi
        const Text('Kargolanacak Ürünler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navy)),
        const SizedBox(height: 12),
        _buildItemsList(shippedItemIds),
      ],
    );
  }

  Widget _buildItemsList(List<int> shippedItemIds) {
    final items = widget.sale.items ?? [];
    if (items.isEmpty) return const Text('Seçilebilir ürün yok');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
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
                fontWeight: FontWeight.w500,
                color: isShipped ? Colors.grey : AppColors.navy,
                decoration: isShipped ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              'Seri: ${item.serialNumber ?? '-'} ${isShipped ? '(Kargolandı)' : ''}',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey[500]),
            ),
            secondary: DeviceImageWidget(
              deviceTypeName: item.modelName,
              size: 40,
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
            activeColor: const Color(0xFFF57C00),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        },
      ),
    );
  }
}
