import 'package:equatable/equatable.dart';

class TaskTypeEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final bool isActive;
  final int displayOrder;

  const TaskTypeEntity({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.displayOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, description, isActive, displayOrder];

  TaskTypeEntity copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    int? displayOrder,
  }) {
    return TaskTypeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
