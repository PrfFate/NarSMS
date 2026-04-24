import 'package:flutter/material.dart';

import 'field_task_status_page.dart';

class CancelledTasksPage extends StatelessWidget {
  const CancelledTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Cancelled',
      emptyIcon: Icons.cancel,
      emptyMessage: 'İptal edilen görev bulunamadı',
    );
  }
}
