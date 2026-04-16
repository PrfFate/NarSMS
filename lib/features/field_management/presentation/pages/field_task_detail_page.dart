import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/detail_section_card.dart';
import '../models/field_task_list_item.dart';

class FieldTaskDetailPage extends StatelessWidget {
  final FieldTaskListItem task;

  const FieldTaskDetailPage({
    super.key,
    required this.task,
  });

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
                                      horizontal: 8, vertical: 4),
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
