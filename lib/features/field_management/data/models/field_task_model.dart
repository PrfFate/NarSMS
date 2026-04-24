import '../../domain/entities/field_task_entity.dart';

class FieldTaskModel extends FieldTaskEntity {
  const FieldTaskModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.customerAddress,
    required super.saleId,
    required super.assignedToUserId,
    required super.assignedToUserName,
    required super.assignedByUserId,
    required super.assignedByUserName,
    required super.title,
    required super.description,
    required super.status,
    required super.scheduledDate,
    required super.acceptedDate,
    required super.startedDate,
    required super.completedDate,
    required super.assignmentNotes,
    required super.completionNotes,
    required super.taskTypes,
    required super.createdAt,
  });

  factory FieldTaskModel.fromJson(Map<String, dynamic> json) {
    return FieldTaskModel(
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
              FieldTaskTypeModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class FieldTaskTypeModel extends FieldTaskTypeEntity {
  const FieldTaskTypeModel({
    required super.id,
    required super.name,
    required super.isCompleted,
    super.notes,
  });

  factory FieldTaskTypeModel.fromJson(Map<String, dynamic> json) {
    return FieldTaskTypeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '-',
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}
