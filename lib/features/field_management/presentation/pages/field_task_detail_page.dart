import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/detail_section_card.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/field_task_entity.dart';
import '../../domain/usecases/accept_field_task_usecase.dart';
import '../../domain/usecases/reassign_field_task_usecase.dart';
import '../../domain/usecases/reject_field_task_usecase.dart';

class FieldTaskDetailPage extends StatefulWidget {
  final FieldTaskEntity task;
  final bool canAcceptTask;
  final bool canRejectTask;
  final bool canReassignTask;

  const FieldTaskDetailPage({
    super.key,
    required this.task,
    this.canAcceptTask = false,
    this.canRejectTask = false,
    this.canReassignTask = false,
  });

  @override
  State<FieldTaskDetailPage> createState() => _FieldTaskDetailPageState();
}

class _FieldTaskDetailPageState extends State<FieldTaskDetailPage> {
  bool _isAccepting = false;
  bool _isRejecting = false;
  bool _isReassigning = false;
  bool _isLoadingFielderUsers = false;
  List<UserModel> _fielderUsers = [];

  AcceptFieldTaskUseCase get _acceptFieldTaskUseCase =>
      getIt<AcceptFieldTaskUseCase>();
  RejectFieldTaskUseCase get _rejectFieldTaskUseCase =>
      getIt<RejectFieldTaskUseCase>();
  ReassignFieldTaskUseCase get _reassignFieldTaskUseCase =>
      getIt<ReassignFieldTaskUseCase>();

  bool get _isBusy => _isAccepting || _isRejecting || _isReassigning;

  Future<void> _acceptTask() async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    try {
      final result = await _acceptFieldTaskUseCase(widget.task.id);
      String? errorMessage;
      result.fold(
        (failure) => errorMessage = failure.message,
        (_) {},
      );

      if (errorMessage != null) {
        throw Exception(errorMessage);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görev başarıyla kabul edildi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev kabul edilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  void _confirmAcceptTask() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Kabul Et'),
        content: const Text('Bu görevi kabul etmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _acceptTask();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectTask(String reason) async {
    if (_isRejecting) return;
    setState(() => _isRejecting = true);

    try {
      final result = await _rejectFieldTaskUseCase(widget.task.id, reason);
      String? errorMessage;
      result.fold(
        (failure) => errorMessage = failure.message,
        (_) {},
      );

      if (errorMessage != null) {
        throw Exception(errorMessage);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görev başarıyla reddedildi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev reddedilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  void _showRejectDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Reddet'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Reddetme Sebebi',
            hintText: 'Örn: Müşteri adreste bulunamadı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reddetme sebebi zorunludur'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              _rejectTask(reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFielderUsers() async {
    if (_fielderUsers.isNotEmpty || _isLoadingFielderUsers) return;
    setState(() => _isLoadingFielderUsers = true);
    try {
      final dio = getIt<DioClient>();
      final prefs = getIt<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);
      final response = await dio.get(
        ApiConstants.userByRoleFielder,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        setState(() {
          _fielderUsers = data
              .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sahacı listesi alınamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingFielderUsers = false);
    }
  }

  Future<void> _reassignTask(int userId) async {
    if (_isReassigning) return;
    setState(() => _isReassigning = true);

    try {
      final result = await _reassignFieldTaskUseCase(widget.task.id, userId);
      String? errorMessage;
      result.fold(
        (failure) => errorMessage = failure.message,
        (_) {},
      );

      if (errorMessage != null) {
        throw Exception(errorMessage);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görev başarıyla yeniden atandı'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev yeniden atanamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isReassigning = false);
    }
  }

  Future<void> _showReassignDialog() async {
    await _loadFielderUsers();
    if (!mounted || _fielderUsers.isEmpty) return;

    UserModel? selectedUser;
    final availableUsers = _fielderUsers
        .where((u) => u.id != null && u.id != widget.task.assignedToUserId)
        .toList();

    if (availableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atanabilecek başka sahacı bulunamadı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    'Görevi Yeniden Ata',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  width: double.infinity,
                  color: AppColors.accentDark,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: DropdownButtonFormField<UserModel>(
                    initialValue: selectedUser,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Sahacı',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.accentDark),
                      ),
                    ),
                    items: availableUsers
                        .map(
                          (user) => DropdownMenuItem(
                            value: user,
                            child: Text(
                              user.username ?? user.email,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedUser = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Vazgeç',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: selectedUser == null
                            ? null
                            : () {
                                Navigator.pop(ctx);
                                _reassignTask(selectedUser!.id!);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Yeniden Ata',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
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
          'Görev Detayı',
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
      bottomNavigationBar: (widget.canAcceptTask ||
              widget.canRejectTask ||
              widget.canReassignTask)
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: widget.canReassignTask
                  ? SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isBusy || _isLoadingFielderUsers
                            ? null
                            : _showReassignDialog,
                        icon: _isReassigning || _isLoadingFielderUsers
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.person_add_alt_1),
                        label: Text(
                          _isReassigning || _isLoadingFielderUsers
                              ? 'İşleniyor...'
                              : 'Yeniden Ata',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        if (widget.canRejectTask) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isBusy ? null : _showRejectDialog,
                              icon: _isRejecting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.close),
                              label: Text(
                                _isRejecting ? 'Reddediliyor...' : 'Reddet',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (widget.canAcceptTask)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isBusy ? null : _confirmAcceptTask,
                              icon: _isAccepting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.task_alt),
                              label: Text(
                                _isAccepting ? 'Kabul Ediliyor...' : 'Kabul Et',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetailSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Görev Bilgisi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.title_outlined,
                    title: 'Başlık',
                    value: task.title,
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.notes_outlined,
                    title: 'Açıklama',
                    value: task.description,
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.flag_outlined,
                    title: 'Durum',
                    value: translateTaskStatus(task.status),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.calendar_month_outlined,
                    title: 'Planlanan Tarih',
                    value: formatTaskDate(task.scheduledDate),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.event_available_outlined,
                    title: 'Kabul Tarihi',
                    value: formatTaskDate(task.acceptedDate),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.play_circle_outline,
                    title: 'Başlama Tarihi',
                    value: formatTaskDate(task.startedDate),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.task_alt_outlined,
                    title: 'Tamamlanma Tarihi',
                    value: formatTaskDate(task.completedDate),
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
                    'Müşteri Bilgisi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.business_outlined,
                    title: 'Müşteri',
                    value: task.customerName,
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Adres',
                    value: task.customerAddress,
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
                    'Atama Bilgisi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.person_outline,
                    title: 'Atanan Kullanıcı',
                    value: task.assignedToUserName,
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Atayan Kullanıcı',
                    value: task.assignedByUserName,
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.assignment_outlined,
                    title: 'Atama Notu',
                    value: task.assignmentNotes,
                  ),
                  const SizedBox(height: 16),
                  DetailInfoRow(
                    icon: Icons.fact_check_outlined,
                    title: 'Tamamlanma Notu',
                    value: task.completionNotes,
                  ),
                  if (task.rejectionReason != null &&
                      task.rejectionReason!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DetailInfoRow(
                      icon: Icons.report_problem_outlined,
                      title: 'Reddetme Sebebi',
                      value: task.rejectionReason!,
                    ),
                  ],
                  if (task.isReassigned) ...[
                    const SizedBox(height: 16),
                    DetailInfoRow(
                      icon: Icons.person_add_alt_1_outlined,
                      title: 'Yeniden Atama',
                      value: 'Yeniden atandı',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            DetailSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Görev Tipleri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (task.taskTypes.isEmpty)
                    const Text(
                      'Görev tipi bulunamadı',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ...task.taskTypes.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    type.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: type.isCompleted
                                        ? Colors.green.withValues(alpha: 0.12)
                                        : Colors.orange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    type.isCompleted
                                        ? 'Tamamlandı'
                                        : 'Bekleniyor',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: type.isCompleted
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (type.notes != null &&
                                type.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                type.notes!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
