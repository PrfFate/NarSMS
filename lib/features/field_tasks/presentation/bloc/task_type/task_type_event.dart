import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_type_entity.dart';

abstract class TaskTypeEvent extends Equatable {
  const TaskTypeEvent();

  @override
  List<Object?> get props => [];
}

class GetAllTaskTypes extends TaskTypeEvent {}

class GetActiveTaskTypes extends TaskTypeEvent {}

class CreateTaskType extends TaskTypeEvent {
  final TaskTypeEntity taskType;
  const CreateTaskType(this.taskType);

  @override
  List<Object?> get props => [taskType];
}

class UpdateTaskType extends TaskTypeEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateTaskType(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteTaskType extends TaskTypeEvent {
  final int id;
  const DeleteTaskType(this.id);

  @override
  List<Object?> get props => [id];
}
