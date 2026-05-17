import 'package:flutter/material.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_action_menu_widget.dart';
import '../../../../core/widgets/custom_list_card.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../domain/entities/field_task_entity.dart';
import '../../domain/usecases/get_field_tasks_usecase.dart';
import 'field_task_detail_page.dart';

class FieldTaskStatusPage extends StatefulWidget {
  final String status;
  final IconData emptyIcon;
  final String emptyMessage;
  final bool showPendingActions;
  final String endpoint;
  final bool enableAcceptActionInDetail;
  final bool enableRejectActionInDetail;
  final bool enableReassignActionInDetail;

  const FieldTaskStatusPage({
    super.key,
    required this.status,
    required this.emptyIcon,
    required this.emptyMessage,
    this.showPendingActions = false,
    this.endpoint = ApiConstants.fieldTasks,
    this.enableAcceptActionInDetail = false,
    this.enableRejectActionInDetail = false,
    this.enableReassignActionInDetail = false,
  });

  @override
  State<FieldTaskStatusPage> createState() => _FieldTaskStatusPageState();
}

class _FieldTaskStatusPageState extends State<FieldTaskStatusPage> {
  static const int _pageSize = 15;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<FieldTaskEntity> _tasks = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';

  GetFieldTasksUseCase get _getFieldTasksUseCase =>
      getIt<GetFieldTasksUseCase>();

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
      final result = await _getFieldTasksUseCase(
        endpoint: widget.endpoint,
        status: widget.status,
        pageNumber: _currentPage,
        pageSize: _pageSize,
        customerName: _searchQuery,
      );
      final items = <FieldTaskEntity>[];
      int totalCount = 0;
      String? errorMessage;
      result.fold(
        (failure) => errorMessage = failure.message,
        (data) {
          items.addAll(data.items);
          totalCount = data.totalCount;
        },
      );

      if (errorMessage != null) {
        throw Exception(errorMessage);
      }

      if (!mounted) return;
      setState(() {
        _totalCount = totalCount;
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
            onTap: () async {
              final shouldRefresh = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => FieldTaskDetailPage(
                    task: task,
                    canAcceptTask: widget.enableAcceptActionInDetail &&
                        task.status.toLowerCase() == 'pending',
                    canRejectTask: widget.enableRejectActionInDetail &&
                        task.status.toLowerCase() == 'pending',
                    canReassignTask: widget.enableReassignActionInDetail &&
                        task.status.toLowerCase() == 'rejected' &&
                        !task.isReassigned,
                  ),
                ),
              );
              if (shouldRefresh == true && mounted) {
                _loadTasks();
              }
            },
            title: task.title,
            subtitle:
                '${task.customerName} • ${task.assignedToUserName} • ${formatTaskDate(task.scheduledDate)}'
                '${task.isReassigned ? ' • Yeniden atandı' : ''}',
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
