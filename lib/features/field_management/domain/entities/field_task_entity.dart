class FieldTaskEntity {
  final int id;
  final int? customerId;
  final String customerName;
  final String customerAddress;
  final int? saleId;
  final int? assignedToUserId;
  final String assignedToUserName;
  final int? assignedByUserId;
  final String assignedByUserName;
  final String title;
  final String description;
  final String status;
  final DateTime? scheduledDate;
  final DateTime? acceptedDate;
  final DateTime? startedDate;
  final DateTime? completedDate;
  final String assignmentNotes;
  final String completionNotes;
  final String? rejectionReason;
  final bool isReassigned;
  final List<FieldTaskTypeEntity> taskTypes;
  final DateTime? createdAt;

  const FieldTaskEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.saleId,
    required this.assignedToUserId,
    required this.assignedToUserName,
    required this.assignedByUserId,
    required this.assignedByUserName,
    required this.title,
    required this.description,
    required this.status,
    required this.scheduledDate,
    required this.acceptedDate,
    required this.startedDate,
    required this.completedDate,
    required this.assignmentNotes,
    required this.completionNotes,
    this.rejectionReason,
    this.isReassigned = false,
    required this.taskTypes,
    required this.createdAt,
  });
}

class FieldTaskTypeEntity {
  final int id;
  final String name;
  final bool isCompleted;
  final String? notes;

  const FieldTaskTypeEntity({
    required this.id,
    required this.name,
    required this.isCompleted,
    this.notes,
  });
}

class FieldTaskPagedResultEntity {
  final List<FieldTaskEntity> items;
  final int totalCount;

  const FieldTaskPagedResultEntity({
    required this.items,
    required this.totalCount,
  });
}

String formatTaskDate(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.${local.year} $hour:$minute';
}

String translateTaskStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Beklemede';
    case 'accepted':
      return 'Kabul Edildi';
    case 'inprogress':
      return 'Devam Ediyor';
    case 'completed':
      return 'Tamamlandı';
    case 'canceled':
    case 'cancelled':
      return 'İptal Edildi';
    case 'rejected':
      return 'Reddedildi';
    default:
      return status;
  }
}
