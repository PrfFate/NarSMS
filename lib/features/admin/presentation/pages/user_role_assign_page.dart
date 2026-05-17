import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/detail_section_card.dart';
import 'users_management_page.dart';

String _translateRole(String roleName) {
  switch (roleName) {
    case 'Admin': return 'Admin';
    case 'StockManager': return 'Stok Yöneticisi';
    case 'SaleManager': return 'Satış Yöneticisi';
    case 'AccountingManager': return 'Muhasebe Yöneticisi';
    case 'SalesConsultant': return 'Satış Danışmanı';
    case 'Fielder': return 'Saha Görevlisi';
    case 'PendingUser': return 'Onay Bekleyen';
    default: return roleName;
  }
}

class UserRoleAssignArgs {
  final UserListItem user;
  final List<RoleOption> roles;

  const UserRoleAssignArgs({
    required this.user,
    required this.roles,
  });
}

class UserRoleAssignPage extends StatefulWidget {
  final UserRoleAssignArgs args;

  const UserRoleAssignPage({super.key, required this.args});

  @override
  State<UserRoleAssignPage> createState() => _UserRoleAssignPageState();
}

class _UserRoleAssignPageState extends State<UserRoleAssignPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late int _selectedRoleId;
  late List<RoleOption> _roles;
  bool _isSaving = false;

  Dio get _dio => getIt<DioClient>().dio;
  SharedPreferences get _prefs => getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.args.user.username);
    _emailController = TextEditingController(text: widget.args.user.email);
    _phoneController =
        TextEditingController(text: widget.args.user.phone ?? '');
    _selectedRoleId = widget.args.user.roleId;
    _roles = widget.args.roles;
    _loadRolesIfEmpty();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Options _authOptions() {
    final token = _prefs.getString(StorageConstants.accessToken);
    return Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'});
  }

  Future<void> _loadRolesIfEmpty() async {
    if (_roles.isNotEmpty) return;
    try {
      final response =
          await _dio.get(ApiConstants.role, options: _authOptions());
      final data = response.data;
      final rawList = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['items'] ??
                  (data['data'] is Map<String, dynamic>
                      ? (data['data']['items'] ?? const [])
                      : data['data']) ??
                  data['result'] ??
                  const [])
              : const [];
      final roles = (rawList as List)
          .map((e) => RoleOption.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (!mounted) return;
      setState(() => _roles = roles);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roller alınamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final endpoints =
        <({String method, String path, Map<String, dynamic> body})>[
      (
        method: 'patch',
        path: ApiConstants.userById(widget.args.user.id),
        body: {'roleId': _selectedRoleId}
      ),
      (
        method: 'patch',
        path: '${ApiConstants.apiVersion}/User/${widget.args.user.id}/role',
        body: {'roleId': _selectedRoleId}
      ),
      (
        method: 'patch',
        path:
            '${ApiConstants.apiVersion}/User/${widget.args.user.id}/assign-role',
        body: {'roleId': _selectedRoleId}
      ),
      (
        method: 'post',
        path: '${ApiConstants.apiVersion}/User/assign-role',
        body: {'userId': widget.args.user.id, 'roleId': _selectedRoleId}
      ),
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        if (endpoint.method == 'put') {
          await _dio.put(endpoint.path,
              data: endpoint.body, options: _authOptions());
        } else if (endpoint.method == 'patch') {
          await _dio.patch(endpoint.path,
              data: endpoint.body, options: _authOptions());
        } else {
          await _dio.post(endpoint.path,
              data: endpoint.body, options: _authOptions());
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Rol başarıyla güncellendi'),
              backgroundColor: Colors.green),
        );
        final redirected = await _handleCurrentUserRoleChange();
        if (redirected) return;
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      } catch (e) {
        lastError = e;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rol atama başarısız: $lastError'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _isSaving = false);
  }

  Future<bool> _handleCurrentUserRoleChange() async {
    final currentEmail = _prefs.getString(StorageConstants.userEmail);
    if (currentEmail == null || currentEmail != widget.args.user.email) {
      return false;
    }

    String? selectedRole;
    for (final role in _roles) {
      if (role.id == _selectedRoleId) {
        selectedRole = role.name;
        break;
      }
    }
    if (selectedRole == null) return false;

    await _prefs.setString(StorageConstants.userRole, selectedRole);
    if (!mounted || selectedRole.toLowerCase().trim() == 'admin') return false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Rolünüz değiştiği için kullanıcı yönetimi sayfasından çıkarıldınız.'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
        context, AppRouter.home, (route) => false);
    return true;
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
          'Kullanıcı Rol Ata',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: AppColors.accentDark,
            height: 2.0,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DetailSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kullanıcı Bilgileri',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DetailInfoRow(
                            icon: Icons.person_outline,
                            title: 'Kullanıcı Adı',
                            value: _usernameController.text,
                          ),
                          const SizedBox(height: 16),
                          DetailInfoRow(
                            icon: Icons.mail_outline,
                            title: 'E-posta',
                            value: _emailController.text,
                          ),
                          const SizedBox(height: 16),
                          DetailInfoRow(
                            icon: Icons.phone_outlined,
                            title: 'Telefon',
                            value: _phoneController.text.trim().isEmpty
                                ? '-'
                                : _phoneController.text,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DetailSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rol Atama',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Rol',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedRoleId,
                            items: _roles
                                .map(
                                  (role) => DropdownMenuItem<int>(
                                    value: role.id,
                                    child: Text(_translateRole(role.name)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedRoleId = value);
                            },
                            validator: (value) =>
                                value == null ? 'Rol seçimi zorunlu' : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Kaydet',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
