import 'package:equatable/equatable.dart';

/// Cihaz filtresi değer nesnesi.
/// Tüm alanlar çoklu seçimi destekler.
/// API formatı: `&islemci=X&islemci=Y` (Dio `List<String>` ile bunu otomatik yapar)
class DeviceFilterModel extends Equatable {
  final List<String> ram;
  final List<String> islemci;
  final List<String> hafiza;
  final List<String> ekranBoyutu;
  final List<String> cihazTipleri;
  final String? status;

  const DeviceFilterModel({
    this.ram = const [],
    this.islemci = const [],
    this.hafiza = const [],
    this.ekranBoyutu = const [],
    this.cihazTipleri = const [],
    this.status,
  });

  bool get isEmpty =>
      ram.isEmpty &&
      islemci.isEmpty &&
      hafiza.isEmpty &&
      ekranBoyutu.isEmpty &&
      cihazTipleri.isEmpty &&
      status == null;

  bool get isNotEmpty => !isEmpty;

  /// RAM, İşlemci gibi teknik/donanım filtrelerinin seçili olup olmadığını kontrol eder.
  bool get hasTechnicalFilters =>
      ram.isNotEmpty ||
      islemci.isNotEmpty ||
      hafiza.isNotEmpty ||
      ekranBoyutu.isNotEmpty ||
      cihazTipleri.isNotEmpty;

  /// Her seçili kategoride kaç seçenek olduğunu değil, kaç kategorinin aktif olduğunu sayar.
  int get activeFilterCount {
    int count = 0;
    if (ram.isNotEmpty) count++;
    if (islemci.isNotEmpty) count++;
    if (hafiza.isNotEmpty) count++;
    if (ekranBoyutu.isNotEmpty) count++;
    if (cihazTipleri.isNotEmpty) count++;
    if (status != null) count++;
    return count;
  }

  /// Toplam seçili seçenek sayısı (badge için daha ayrıntılı)
  int get totalSelectedCount =>
      ram.length +
      islemci.length +
      hafiza.length +
      ekranBoyutu.length +
      cihazTipleri.length +
      (status != null ? 1 : 0);

  DeviceFilterModel copyWith({
    List<String>? ram,
    List<String>? islemci,
    List<String>? hafiza,
    List<String>? ekranBoyutu,
    List<String>? cihazTipleri,
    String? status,
  }) {
    return DeviceFilterModel(
      ram: ram ?? this.ram,
      islemci: islemci ?? this.islemci,
      hafiza: hafiza ?? this.hafiza,
      ekranBoyutu: ekranBoyutu ?? this.ekranBoyutu,
      cihazTipleri: cihazTipleri ?? this.cihazTipleri,
      status: status ?? this.status,
    );
  }

  /// Dio'ya `List<String>` verildiğinde aynı parametreyi tekrarlı gönderir:
  /// &islemci=X&islemci=Y
  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    if (ram.isNotEmpty) params['ram'] = ram;
    if (islemci.isNotEmpty) params['islemci'] = islemci;
    if (hafiza.isNotEmpty) params['hafiza'] = hafiza;
    if (ekranBoyutu.isNotEmpty) params['ekranBoyutu'] = ekranBoyutu;
    if (cihazTipleri.isNotEmpty) params['cihazTipleri'] = cihazTipleri;
    if (status != null) params['status'] = status;
    return params;
  }

  static const DeviceFilterModel empty = DeviceFilterModel();

  @override
  List<Object?> get props => [
        ram,
        islemci,
        hafiza,
        ekranBoyutu,
        cihazTipleri,
        status,
      ];
}
