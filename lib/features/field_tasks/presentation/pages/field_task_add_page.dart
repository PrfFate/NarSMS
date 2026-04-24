import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/task_type/task_type_bloc.dart';
import '../bloc/task_type/task_type_event.dart';
import '../bloc/task_type/task_type_state.dart';
import '../../domain/entities/task_type_entity.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../auth/data/models/user_model.dart';

class FieldTaskAddPage extends StatefulWidget {
  const FieldTaskAddPage({super.key});

  @override
  State<FieldTaskAddPage> createState() => _FieldTaskAddPageState();
}

class _FieldTaskAddPageState extends State<FieldTaskAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _customerController = TextEditingController();
  final _userController = TextEditingController();
  final _saleIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _plannedDate;
  TaskTypeEntity? _selectedTaskType;

  // Selection Data
  CustomerModel? _selectedCustomer;
  UserModel? _selectedUser;
  List<UserModel> _fielderUsers = [];
  bool _isLoadingFields = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingFields = true);
    // Load active task types
    context.read<TaskTypeBloc>().add(GetActiveTaskTypes());
    // Load fielder users
    await _loadFielderUsers();
    setState(() => _isLoadingFields = false);
  }

  Future<void> _loadFielderUsers() async {
    try {
      final dio = getIt<DioClient>();
      final prefs = getIt<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);
      final response = await dio.get(
        ApiConstants.userByRoleFielder,
        options: Options(
            headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _fielderUsers = data.map((e) => UserModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Kullanıcı yükleme hatası: $e');
    }
  }

  Future<Iterable<CustomerModel>> _searchCustomers(String query) async {
    if (query.isEmpty) return const Iterable<CustomerModel>.empty();
    try {
      final dio = getIt<DioClient>();
      final prefs = getIt<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);
      final response = await dio.get(
        ApiConstants.customerSearch,
        queryParameters: {'page': 1, 'pageSize': 50, 'name': query},
        options: Options(
            headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((e) => CustomerModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Müşteri arama hatası: $e');
    }
    return const Iterable<CustomerModel>.empty();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _userController.dispose();
    _saleIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plannedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFF57C00)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _plannedDate = picked);
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lütfen bir müşteri seçiniz'),
              backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lütfen atanan kullanıcıyı seçiniz'),
              backgroundColor: Colors.red),
        );
        return;
      }
      if (_plannedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lütfen planlanan tarihi seçiniz'),
              backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedTaskType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lütfen görev tipi seçiniz'),
              backgroundColor: Colors.red),
        );
        return;
      }

      final customerId = _selectedCustomer!.id;
      final assignedUserId = _selectedUser!.id;
      final taskTypeId = _selectedTaskType!.id;
      if (customerId == null || assignedUserId == null || taskTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Seçilen kayıt bilgileri eksik'),
              backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isSaving = true);
      try {
        final dio = getIt<DioClient>();
        final prefs = getIt<SharedPreferences>();
        final token = prefs.getString(StorageConstants.accessToken);
        final saleIdText = _saleIdController.text.trim();
        final body = {
          'customerId': customerId,
          'assignedToUserId': assignedUserId,
          'saleId': saleIdText.isEmpty ? null : int.tryParse(saleIdText),
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'scheduledDate': _plannedDate!.toUtc().toIso8601String(),
          'assignmentNotes': _noteController.text.trim(),
          'status': 'Pending',
          'taskTypeIds': [taskTypeId],
        };

        await dio.post(
          ApiConstants.fieldTasks,
          data: body,
          options: Options(
              headers: {if (token != null) 'Authorization': 'Bearer $token'}),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Görev başarıyla oluşturuldu'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } on DioException catch (e) {
        if (!mounted) return;
        final message =
            e.response?.data?.toString() ?? e.message ?? 'Bilinmeyen hata';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Görev oluşturulamadı: $message'),
              backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Görev oluşturulamadı: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormScaffold(
      title: 'Yeni Görev Ekle',
      bottomButtonText: 'Kaydet',
      onBottomButtonPressed: _onSave,
      isLoading: _isLoadingFields || _isSaving,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Müşteri Autocomplete
              _buildAutocompleteField<CustomerModel>(
                label: 'Müşteri',
                hint: 'Müşteri adı ile ara...',
                optionsBuilder: (val) => _searchCustomers(val.text),
                displayStringForOption: (c) => c.name,
                onSelected: (c) => setState(() => _selectedCustomer = c),
                controller: _customerController,
              ),
              const SizedBox(height: 16),

              // Atanan Kullanıcı Autocomplete (Local Filter from Fielder list)
              _buildAutocompleteField<UserModel>(
                label: 'Atanan Kullanıcı',
                hint: 'Kullanıcı adı ile ara...',
                optionsBuilder: (val) {
                  if (val.text.isEmpty) return _fielderUsers;
                  return _fielderUsers.where((u) => (u.username ?? '')
                      .toLowerCase()
                      .contains(val.text.toLowerCase()));
                },
                displayStringForOption: (u) => u.username ?? u.email,
                onSelected: (u) => setState(() => _selectedUser = u),
                controller: _userController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Satış Fiş ID',
                hint: 'Satış Fiş ID giriniz (opsiyonel)',
                controller: _saleIdController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Açıklama Başlığı',
                hint: 'Görev başlığı giriniz',
                controller: _titleController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Lütfen başlık giriniz' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Açıklama',
                hint: 'Detaylı açıklama giriniz...',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Atama Notu',
                hint: 'Atama notu giriniz...',
                controller: _noteController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Planned Date Picker
              _buildDatePicker(),

              const SizedBox(height: 16),

              // Task Types Dropdown
              _buildTaskTypeDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Planlanan Tarih',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B)),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _plannedDate == null
                      ? 'gg.aa.yyyy'
                      : DateFormat('dd.MM.yyyy').format(_plannedDate!),
                  style: TextStyle(
                    color: _plannedDate == null ? Colors.grey : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const Icon(Icons.calendar_month,
                    color: Color(0xFF1E293B), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTypeDropdown() {
    return BlocBuilder<TaskTypeBloc, TaskTypeState>(
      builder: (context, state) {
        List<TaskTypeEntity> activeTypes = [];
        if (state is TaskTypesLoaded) {
          activeTypes = state.taskTypes.where((e) => e.isActive).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                text: 'Görev Tipleri',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B)),
                children: [
                  TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TaskTypeEntity>(
                  value: _selectedTaskType,
                  isExpanded: true,
                  hint: const Text('Seçiniz',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                  items: activeTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child:
                          Text(type.name, style: const TextStyle(fontSize: 15)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTaskType = val),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAutocompleteField<T extends Object>({
    required String label,
    required String hint,
    required AutocompleteOptionsBuilder<T> optionsBuilder,
    required String Function(T) displayStringForOption,
    required void Function(T) onSelected,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B)),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<T>(
          optionsBuilder: optionsBuilder,
          displayStringForOption: displayStringForOption,
          onSelected: onSelected,
          fieldViewBuilder:
              (context, fieldController, focusNode, onEditingComplete) {
            // Unify with original controller if needed, but Autocomplete manages its own state usually.
            // We use the passed controller to show the initial/selected value if needed.
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              style: const TextStyle(fontSize: 15),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Lütfen seçim yapınız' : null,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF57C00)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
