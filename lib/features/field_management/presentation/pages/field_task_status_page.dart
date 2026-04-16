import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/custom_action_menu_widget.dart';
import '../../../../core/widgets/custom_list_card.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../models/field_task_list_item.dart';
import 'field_task_detail_page.dart';

class FieldTaskStatusPage extends StatefulWidget {
  final String status;
  final IconData emptyIcon;
  final String emptyMessage;
  final bool showPendingActions;

  const FieldTaskStatusPage({
    super.key,
    required this.status,
    required this.emptyIcon,
    required this.emptyMessage,
    this.showPendingActions = false,
  });

  @override
  State<FieldTaskStatusPage> createState() => _FieldTaskStatusPageState();
}

class _FieldTaskStatusPageState extends State<FieldTaskStatusPage> {
  static const int _pageSize = 15;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<FieldTaskListItem> _tasks = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';

  Dio get _dio => getIt<DioClient>().dio;
  SharedPreferences get _prefs => getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadTasks(loadMore: true);
    }
  }

  Options _authOptions() {
    final token = _prefs.getString(StorageConstants.accessToken);
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<void> _loadTasks({bool loadMore = false}) async {
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
      final response = await _dio.get(
        ApiConstants.fieldTasks,
        queryParameters: {
          'Status': widget.status,
          'PageNumber': _currentPage,
          'PageSize': _pageSize,
          if (_searchQuery.trim().isNotEmpty)
            'CustomerName': _searchQuery.trim(),
        },
        options: _authOptions(),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final items = (data['items'] as List? ?? const [])
          .map((e) =>
              FieldTaskListItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (!mounted) return;
      setState(() {
        _totalCount = (data['totalCount'] as num?)?.toInt() ?? items.length;
        if (loadMore) {
          _tasks.addAll(items);
        } else {
          _tasks
            ..clear()
            ..addAll(items);
        }
        _hasMore = _tasks.length < _totalCount;
      });
    } catch (e) {
      if (!mounted) return;
      if (loadMore) _currentPage = (_currentPage - 1).clamp(1, _currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${translateTaskStatus(widget.status)} görevleri alınamadı: $e'),
          backgroundColor: Colors.red,
        ),
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

  void _onRefresh() {
    _loadTasks();
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomRefreshButton(onPressed: _onRefresh),
              const SizedBox(width: 8),
              Expanded(
                child: SearchInputWidget(
                  hintText: 'Müşteri ara...',
                  onSearch: _onSearch,
                  controller: _searchController,
                ),
              ),
              if (widget.showPendingActions) ...[
                const SizedBox(width: 8),
                CustomActionMenuWidget(
                  items: [
                    CustomActionMenuItem(
                      title: 'Yeni Görev Ekle',
                      icon: Icons.add_task,
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                            context, AppRouter.taskAdd);
                        if (result == true && context.mounted) {
                          _loadTasks();
                        }
                      },
                    ),
                    CustomActionMenuItem(
                      title: 'Görev Tipleri',
                      icon: Icons.category_outlined,
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRouter.taskTypeManagement);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? _buildEmptyState()
                    : _buildList(),
          ),
        ],
      ),
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
        itemCount: _tasks.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, index) => index < _tasks.length - 1
            ? const Divider(height: 1, indent: 70)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == _tasks.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final task = _tasks[index];
          return CustomListCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FieldTaskDetailPage(task: task),
                ),
              );
            },
            title: task.title,
            subtitle:
                '${task.customerName} • ${task.assignedToUserName} • ${formatTaskDate(task.scheduledDate)}',
            leadingText:
                task.customerName.isNotEmpty ? task.customerName[0] : '?',
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.emptyIcon, size: 64, color: const Color(0xFFF57C00)),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
