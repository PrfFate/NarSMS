import '../../domain/entities/task_type_entity.dart';

class TaskTypeModel {
  final int? id;
  final String name;
  final String? description;
  final bool isActive;
  final int displayOrder;

  const TaskTypeModel({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory TaskTypeModel.fromJson(Map<String, dynamic> json) {
    return TaskTypeModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  TaskTypeEntity toEntity() {
    return TaskTypeEntity(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }

  factory TaskTypeModel.fromEntity(TaskTypeEntity entity) {
    return TaskTypeModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
      displayOrder: entity.displayOrder,
    );
  }
}
