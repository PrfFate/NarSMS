import 'package:flutter/material.dart';
import '../models/device_filter_model.dart';
import 'filter_bottom_sheet_scaffold.dart';

/// Yeniden kullanılabilir cihaz filtre bottom sheet'i.
///
/// Kullanım:
/// ```dart
/// final result = await DeviceFilterBottomSheet.show(
///   context: context,
///   currentFilter: _activeFilter,
///   availableDeviceTypes: ['Barkod Okuyucu', 'Bilgisayar', ...],
/// );
/// if (result != null) setState(() => _activeFilter = result);
/// ```
class DeviceFilterBottomSheet extends StatefulWidget {
  final DeviceFilterModel currentFilter;
  final List<String> availableDeviceTypes;

  const DeviceFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.availableDeviceTypes,
  });

  static Future<DeviceFilterModel?> show({
    required BuildContext context,
    required DeviceFilterModel currentFilter,
    required List<String> availableDeviceTypes,
  }) {
    return showModalBottomSheet<DeviceFilterModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceFilterBottomSheet(
        currentFilter: currentFilter,
        availableDeviceTypes: availableDeviceTypes,
      ),
    );
  }

  @override
  State<DeviceFilterBottomSheet> createState() =>
      _DeviceFilterBottomSheetState();
}

class _DeviceFilterBottomSheetState extends State<DeviceFilterBottomSheet> {
  late DeviceFilterModel _filter;

  // Sabit filtre seçenekleri
  static const List<String> _ramOptions = ['8GB', '16GB'];
  static const List<String> _islemciOptions = [
    'i-5 (5.Nesil)',
    'i-5 (6.Nesil)',
    'i-5 (7.Nesil)',
    'i-5 (10.Nesil)',
    'i-7 (4.Nesil)',
  ];

  static const List<String> _hafizaOptions = ['128GB', '256GB', '512GB'];
  static const List<String> _ekranBoyutuOptions = ['15.6', '18.5'];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  void _clear() {
    setState(() => _filter = DeviceFilterModel.empty);
  }

  void _apply() => Navigator.pop(context, _filter);

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: 'Filtreler',
      selectedCount: _filter.totalSelectedCount,
      maxHeightFraction: 0.85,
      onClear: _clear,
      onApply: _apply,
      applyLabel: _filter.totalSelectedCount > 0
          ? 'Uygula (${_filter.totalSelectedCount} seçim)'
          : 'Uygula',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _buildMultiSelectGroup(
            title: 'RAM',
            options: _ramOptions,
            selected: _filter.ram,
            onChanged: (val) =>
                setState(() => _filter = _filter.copyWith(ram: val)),
          ),
          _buildMultiSelectGroup(
            title: 'İşlemci',
            options: _islemciOptions,
            selected: _filter.islemci,
            onChanged: (val) =>
                setState(() => _filter = _filter.copyWith(islemci: val)),
          ),
          _buildMultiSelectGroup(
            title: 'Hafıza',
            options: _hafizaOptions,
            selected: _filter.hafiza,
            onChanged: (val) =>
                setState(() => _filter = _filter.copyWith(hafiza: val)),
          ),
          _buildMultiSelectGroup(
            title: 'Ekran Boyutu',
            options: _ekranBoyutuOptions,
            selected: _filter.ekranBoyutu,
            onChanged: (val) =>
                setState(() => _filter = _filter.copyWith(ekranBoyutu: val)),
          ),
          _buildMultiSelectGroup(
            title: 'Cihaz Tipi',
            options: widget.availableDeviceTypes,
            selected: _filter.cihazTipleri,
            onChanged: (val) =>
                setState(() => _filter = _filter.copyWith(cihazTipleri: val)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMultiSelectGroup({
    required String title,
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return ExpansionTile(
      title: Row(
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          if (selected.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF57C00).withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF57C00), width: 0.5),
              ),
              child: Text('${selected.length} seçili',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFF57C00))),
            ),
          ],
        ],
      ),
      initiallyExpanded: selected.isNotEmpty,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? const Color(0xFFF57C00) : Colors.grey,
            size: 20,
          ),
          title: Text(option,
              style: TextStyle(
                  fontSize: 14,
                  color:
                      isSelected ? const Color(0xFFF57C00) : Colors.black87)),
          onTap: () {
            final newList = List<String>.from(selected);
            isSelected ? newList.remove(option) : newList.add(option);
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }
}
