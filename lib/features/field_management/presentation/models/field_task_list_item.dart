class FieldTaskListItem {
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
  final List<FieldTaskTypeItem> taskTypes;
  final DateTime? createdAt;

  const FieldTaskListItem({
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
    required this.taskTypes,
    required this.createdAt,
  });

  factory FieldTaskListItem.fromJson(Map<String, dynamic> json) {
    return FieldTaskListItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerId: (json['customerId'] as num?)?.toInt(),
      customerName: json['customerName'] as String? ?? '-',
      customerAddress: json['customerAddress'] as String? ?? '-',
      saleId: (json['saleId'] as num?)?.toInt(),
      assignedToUserId: (json['assignedToUserId'] as num?)?.toInt(),
      assignedToUserName: json['assignedToUserName'] as String? ?? '-',
      assignedByUserId: (json['assignedByUserId'] as num?)?.toInt(),
      assignedByUserName: json['assignedByUserName'] as String? ?? '-',
      title: json['title'] as String? ?? '-',
      description: json['description'] as String? ?? '-',
      status: json['status'] as String? ?? '-',
      scheduledDate: DateTime.tryParse(json['scheduledDate'] as String? ?? ''),
      acceptedDate: DateTime.tryParse(json['acceptedDate'] as String? ?? ''),
      startedDate: DateTime.tryParse(json['startedDate'] as String? ?? ''),
      completedDate: DateTime.tryParse(json['completedDate'] as String? ?? ''),
      assignmentNotes: json['assignmentNotes'] as String? ?? '-',
      completionNotes: json['completionNotes'] as String? ?? '-',
      taskTypes: (json['taskTypes'] as List? ?? const [])
          .map((e) =>
              FieldTaskTypeItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class FieldTaskTypeItem {
  final int id;
  final String name;
  final bool isCompleted;
  final String? notes;

  const FieldTaskTypeItem({
    required this.id,
    required this.name,
    required this.isCompleted,
    this.notes,
  });

  factory FieldTaskTypeItem.fromJson(Map<String, dynamic> json) {
    return FieldTaskTypeItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '-',
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
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
    case 'rejected':
      return 'İptal Edildi';
    default:
      return status;
  }
}
