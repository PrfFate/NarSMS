import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/widgets/search_input_widget.dart';
import 'user_role_assign_page.dart';

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

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  static const int _pageSize = 15;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<UserListItem> _users = [];
  List<RoleOption> _roles = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _showScrollToTop = false;
  String _searchQuery = '';
  RoleOption? _selectedRole;

  Dio get _dio => getIt<DioClient>().dio;
  SharedPreferences get _prefs => getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
    if (!_scrollController.hasClients ||
        !_hasMore ||
        _isLoadingMore ||
        _isLoading) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadUsers(loadMore: true);
    }
  }

  Future<void> _loadInitial() async {
    await Future.wait([
      _loadRoles(),
      _loadUsers(),
    ]);
  }

  Options _authOptions() {
    final token = _prefs.getString(StorageConstants.accessToken);
    return Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'});
  }

  Future<void> _loadRoles() async {
    try {
      final response =
          await _dio.get(ApiConstants.role, options: _authOptions());
      final rawList = _extractList(response.data);

      final roles = rawList
          .map((e) => RoleOption.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (!mounted) return;
      setState(() => _roles = roles);
    } catch (e) {
      // Rol listesi alınamazsa filtre ve detayda fallback mesajı gösterilir.
      debugPrint('Role fetch error: $e');
    }
  }

  Future<void> _loadUsers({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      setState(() {
        _isLoadingMore = true;
        _currentPage += 1;
      });
    } else {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final path = _selectedRole != null
          ? ApiConstants.usersByRole(_selectedRole!.name)
          : _searchQuery.trim().isNotEmpty
              ? ApiConstants.userSearch
              : ApiConstants.userPaged;
      final query = _selectedRole != null
          ? <String, dynamic>{}
          : <String, dynamic>{
              'page': _currentPage,
              'pageSize': _pageSize,
              if (_searchQuery.trim().isNotEmpty)
                'username': _searchQuery.trim(),
            };

      final response = await _dio.get(
        path,
        queryParameters: query,
        options: _authOptions(),
      );
      final json = _extractMap(response.data);
      var items = (json['items'] as List? ?? const [])
          .map(
              (e) => UserListItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (_selectedRole != null && _searchQuery.trim().isNotEmpty) {
        final searchLower = _searchQuery.trim().toLowerCase();
        items = items
            .where((user) => user.username.toLowerCase().contains(searchLower))
            .toList();
      }

      final totalCount = _selectedRole != null
          ? items.length
          : (json['totalCount'] as num?)?.toInt() ?? items.length;

      if (!mounted) return;
      setState(() {
        _totalCount = totalCount;
        _users = loadMore ? [..._users, ...items] : items;
        _hasMore = _selectedRole == null && _users.length < _totalCount;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      if (loadMore) _currentPage = (_currentPage - 1).clamp(1, _currentPage);
      final status = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Bilinmeyen hata';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Kullanıcılar alınamadı ($status): $message'),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      if (loadMore) _currentPage = (_currentPage - 1).clamp(1, _currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Kullanıcılar alınamadı: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is List) return {'items': raw, 'totalCount': raw.length};
    if (raw is Map<String, dynamic>) {
      if (raw['items'] is List) return raw;
      final nested = raw['data'] ?? raw['result'] ?? raw['value'];
      if (nested is Map<String, dynamic>) return nested;
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return raw;
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final direct = raw['items'];
      if (direct is List) return direct;
      final nested = raw['data'] ?? raw['result'] ?? raw['value'];
      if (nested is List) return nested;
      if (nested is Map<String, dynamic> && nested['items'] is List) {
        return nested['items'] as List;
      }
      return const [];
    }
    return const [];
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _loadUsers();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_UserRoleFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        RoleOption? tempRole = _selectedRole;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedCount = tempRole == null ? 0 : 1;

            return FilterBottomSheetScaffold(
              title: 'Kullanıcı Filtreleri',
              selectedCount: selectedCount,
              maxHeightFraction: 0.75,
              onClear: () => setSheetState(() => tempRole = null),
              onApply: () => Navigator.pop(
                context,
                _UserRoleFilterResult(role: tempRole),
              ),
              applyLabel:
                  selectedCount > 0 ? 'Uygula ($selectedCount)' : 'Uygula',
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Icon(
                      tempRole == null
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: tempRole == null ? AppColors.primary : Colors.grey,
                    ),
                    title: const Text('Tüm Roller'),
                    onTap: () => setSheetState(() => tempRole = null),
                  ),
                  ..._roles.map((role) {
                    final isSelected = tempRole?.id == role.id;
                    return ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      leading: Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isSelected ? AppColors.primary : Colors.grey,
                      ),
                      title: Text(
                        _translateRole(role.name),
                        style: TextStyle(
                          color:
                              isSelected ? AppColors.primary : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      onTap: () => setSheetState(() => tempRole = role),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() => _selectedRole = result.role);
    _loadUsers();
  }

  Widget _buildFilterButton() {
    final count = _selectedRole == null ? 0 : 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: count > 0 ? AppColors.primary : Colors.white,
            border: Border.all(
                color: count > 0 ? AppColors.primary : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openFilterSheet,
              child: Center(
                child: Icon(
                  Icons.filter_list,
                  color: count > 0 ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildList() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _users.length + 1,
        separatorBuilder: (_, i) => i < _users.length - 1
            ? const Divider(height: 1)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            if (_isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (!_hasMore && _users.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Tüm ${_users.length} kullanıcı listelendi',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final user = _users[index];
          return InkWell(
            onTap: () async {
              final changed = await Navigator.pushNamed(
                context,
                AppRouter.userRoleAssign,
                arguments: UserRoleAssignArgs(user: user, roles: _roles),
              );
              if (changed == true && mounted) _loadUsers();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _translateRole(user.roleName),
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () => _scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CustomRefreshButton(onPressed: _loadUsers),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchInputWidget(
                    hintText: 'Kullanıcı ara...',
                    onSearch: _onSearch,
                    controller: _searchController,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_alt_outlined,
                                    size: 64, color: AppColors.primary),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _selectedRole != null
                                      ? 'Filtreye uygun kullanıcı bulunamadı'
                                      : 'Kullanıcı bulunamadı',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }
}

class UserListItem {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final int roleId;
  final String roleName;

  const UserListItem({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.roleId,
    required this.roleName,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?)?.trim().isNotEmpty == true
          ? json['username'] as String
          : '-',
      email: (json['email'] as String?) ?? '-',
      phone: json['phone'] as String?,
      roleId: (json['roleId'] as num?)?.toInt() ?? 0,
      roleName: (json['roleName'] as String?) ?? '-',
    );
  }
}

class RoleOption {
  final int id;
  final String name;

  const RoleOption({required this.id, required this.name});

  factory RoleOption.fromJson(Map<String, dynamic> json) {
    return RoleOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? (json['roleName'] as String?) ?? '-',
    );
  }
}

class _UserRoleFilterResult {
  final RoleOption? role;

  const _UserRoleFilterResult({required this.role});
}
