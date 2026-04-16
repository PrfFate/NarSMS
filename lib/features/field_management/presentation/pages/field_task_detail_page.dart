import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/detail_section_card.dart';
import '../../domain/entities/field_task_entity.dart';
import '../../domain/usecases/accept_field_task_usecase.dart';

class FieldTaskDetailPage extends StatefulWidget {
  final FieldTaskEntity task;
  final bool canAcceptTask;

  const FieldTaskDetailPage({
    super.key,
    required this.task,
    this.canAcceptTask = false,
  });

  @override
  State<FieldTaskDetailPage> createState() => _FieldTaskDetailPageState();
}

class _FieldTaskDetailPageState extends State<FieldTaskDetailPage> {
  bool _isAccepting = false;

  AcceptFieldTaskUseCase get _acceptFieldTaskUseCase =>
      getIt<AcceptFieldTaskUseCase>();

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
      bottomNavigationBar: widget.canAcceptTask
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isAccepting ? null : _confirmAcceptTask,
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
                    _isAccepting ? 'Kabul Ediliyor...' : 'Görevi Kabul Et',
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
