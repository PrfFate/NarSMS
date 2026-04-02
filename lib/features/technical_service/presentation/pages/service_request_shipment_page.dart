import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/technical_service_bloc.dart';
import '../bloc/technical_service_event.dart';
import '../bloc/technical_service_state.dart';

class ServiceRequestShipmentPage extends StatefulWidget {
  final int requestId;
  final int shipmentType;

  const ServiceRequestShipmentPage({
    super.key,
    required this.requestId,
    required this.shipmentType,
  });

  @override
  State<ServiceRequestShipmentPage> createState() =>
      _ServiceRequestShipmentPageState();
}

class _ServiceRequestShipmentPageState
    extends State<ServiceRequestShipmentPage> {
  // Mode: true = normal carrier, false = saha ekibi
  bool _isCarrierMode = true;

  Map<String, dynamic>? _selectedCarrier;
  Map<String, dynamic>? _selectedFielder;

  final TextEditingController _trackingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Fielder search
  Timer? _fielderDebounce;
  List<Map<String, dynamic>> _fielderSearchResults = [];
  bool _isSearchingFielder = false;

  @override
  void initState() {
    super.initState();
    context.read<TechnicalServiceBloc>().add(LoadShipmentOptions());
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _fielderDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TechnicalServiceBloc, TechnicalServiceState>(
      listener: (context, state) {
        if (state is TechnicalServiceShipmentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Kargo kaydı başarıyla oluşturuldu'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is TechnicalServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            widget.shipmentType == 1
                ? 'Servise Kargo Gönderimi'
                : 'Müşteriye Kargo Gönderimi',
            style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: const Color(0xFFF57C00), height: 2.0),
          ),
        ),
        body: BlocBuilder<TechnicalServiceBloc, TechnicalServiceState>(
          builder: (context, state) {
            List<Map<String, dynamic>> allCarriers = [];
            List<Map<String, dynamic>> allFielders = [];

            if (state is ShipmentOptionsLoaded) {
              allCarriers = state.carriers;
              allFielders = state.fielders;
            }

            if (state is TechnicalServiceLoading && allCarriers.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFF57C00)));
            }

            // Split carriers: "Saha Ekibi" types vs normal
            final normalCarriers = allCarriers
                .where((c) =>
                    !(c['name'] as String? ?? '').toLowerCase().contains('saha'))
                .toList();
            final sahaCarrier = allCarriers
                .where((c) =>
                    (c['name'] as String? ?? '').toLowerCase().contains('saha'))
                .firstOrNull;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Toggle
                    _buildSectionHeader('Gönderim Yöntemi'),
                    const SizedBox(height: 12),
                    _buildModeToggles(sahaCarrier),
                    const SizedBox(height: 28),

                    // --- CARRIER MODE ---
                    if (_isCarrierMode) ...[
                      _buildSectionHeader('Kargo Firması'),
                      const SizedBox(height: 12),
                      _buildCarrierDropdown(normalCarriers),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Takip Numarası'),
                      const SizedBox(height: 12),
                      _buildTrackingField(),
                    ]
                    // --- SAHA EKİBİ MODE ---
                    else ...[
                      _buildSectionHeader('Saha Personeli'),
                      const SizedBox(height: 12),
                      _buildFielderSearch(allFielders),
                    ],

                    const SizedBox(height: 40),
                    BlocBuilder<TechnicalServiceBloc, TechnicalServiceState>(
                      builder: (context, state) {
                        final isLoading = state is TechnicalServiceLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF57C00),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('İŞLEMİ TAMAMLA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5),
    );
  }

  Widget _buildModeToggles(Map<String, dynamic>? sahaCarrier) {
    return Row(
      children: [
        Expanded(
          child: _ModeSwitch(
            label: 'Kargo Firması',
            icon: Icons.local_shipping_outlined,
            isSelected: _isCarrierMode,
            isLeft: true,
            onTap: () => setState(() {
              _isCarrierMode = true;
              _selectedCarrier = null;
              _selectedFielder = null;
            }),
          ),
        ),
        Expanded(
          child: _ModeSwitch(
            label: 'Saha Ekibi',
            icon: Icons.groups_outlined,
            isSelected: !_isCarrierMode,
            isLeft: false,
            onTap: () => setState(() {
              _isCarrierMode = false;
              _selectedCarrier = sahaCarrier;
              _selectedFielder = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCarrierDropdown(List<Map<String, dynamic>> carriers) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedCarrier,
      items: carriers
          .map((c) =>
              DropdownMenuItem(value: c, child: Text(c['name'] ?? '-')))
          .toList(),
      onChanged: (val) => setState(() => _selectedCarrier = val),
      decoration: InputDecoration(
        hintText: 'Kargo firması seçin',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFF57C00), width: 2)),
        prefixIcon:
            const Icon(Icons.business_outlined, color: Color(0xFFF57C00)),
      ),
      validator: (v) => v == null ? 'Lütfen kargo firması seçin' : null,
    );
  }

  Widget _buildTrackingField() {
    return TextFormField(
      controller: _trackingController,
      decoration: InputDecoration(
        hintText: 'Takip numarasını girin',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFF57C00), width: 2)),
        prefixIcon: const Icon(Icons.tag, color: Color(0xFFF57C00)),
      ),
      // Kargo modunda takip no zorunlu
      validator: _isCarrierMode
          ? (v) => (v == null || v.trim().isEmpty)
              ? 'Takip numarası zorunludur'
              : null
          : null,
    );
  }

  Widget _buildFielderSearch(List<Map<String, dynamic>> allFielders) {
    // If a fielder is selected, show selected card
    if (_selectedFielder != null) {
      return _buildSelectedFielderCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Personel adı veya kullanıcı adı ile ara...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFF57C00), width: 2)),
            prefixIcon:
                const Icon(Icons.person_search, color: Color(0xFFF57C00)),
            suffixIcon: _isSearchingFielder
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFFF57C00))))
                : null,
          ),
          onChanged: (query) {
            _fielderDebounce?.cancel();
            _fielderDebounce =
                Timer(const Duration(milliseconds: 300), () {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) {
                setState(() => _fielderSearchResults = []);
                return;
              }
              setState(() {
                _fielderSearchResults = allFielders.where((u) {
                  final username =
                      (u['username'] as String? ?? '').toLowerCase();
                  final email =
                      (u['email'] as String? ?? '').toLowerCase();
                  return username.contains(q) || email.contains(q);
                }).toList();
              });
            });
          },
        ),
        if (_fielderSearchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fielderSearchResults.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final u = _fielderSearchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFFF57C00).withAlpha(30),
                    child: const Icon(Icons.person,
                        color: Color(0xFFF57C00), size: 20),
                  ),
                  title: Text(u['username'] ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  subtitle: Text(u['email'] ?? '',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12)),
                  onTap: () => setState(() {
                    _selectedFielder = u;
                    _fielderSearchResults = [];
                  }),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 8),
        FormField<Map<String, dynamic>>(
          initialValue: _selectedFielder,
          validator: (_) => _selectedFielder == null
              ? 'Lütfen bir saha personeli seçin'
              : null,
          builder: (field) => field.hasError
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(field.errorText!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12)))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSelectedFielderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF57C00).withAlpha(80)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF57C00).withAlpha(30),
            child:
                const Icon(Icons.person, color: Color(0xFFF57C00), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFielder!['username'] ?? '-',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                if (_selectedFielder!['email'] != null)
                  Text(_selectedFielder!['email'],
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => setState(() => _selectedFielder = null),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    // If carrier mode but no carrier selected — validator handles it.
    // If fielder mode but no fielder — validator handles it.

    final int? carrierId = _selectedCarrier?['id'] as int?;
    final int? fieldTeamUserId =
        (!_isCarrierMode) ? (_selectedFielder?['id'] as int?) : null;
    final String? trackingNumber =
        _isCarrierMode ? _trackingController.text.trim() : null;

    context.read<TechnicalServiceBloc>().add(
          SendToShipment(
            id: widget.requestId,
            shipmentType: widget.shipmentType,
            carrierId: carrierId,
            fieldTeamUserId: fieldTeamUserId,
            trackingNumber:
                (trackingNumber != null && trackingNumber.isNotEmpty)
                    ? trackingNumber
                    : null,
          ),
        );
  }
}

class _ModeSwitch extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLeft;

  const _ModeSwitch({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF57C00) : Colors.white,
          borderRadius: isLeft
              ? const BorderRadius.horizontal(left: Radius.circular(16))
              : const BorderRadius.horizontal(right: Radius.circular(16)),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFFF57C00)
                  : Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                    isSelected ? Colors.white : const Color(0xFF64748B),
                size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
