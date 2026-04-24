import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_type_entity.dart';

abstract class TaskTypeState extends Equatable {
  const TaskTypeState();

  @override
  List<Object?> get props => [];
}

class TaskTypeInitial extends TaskTypeState {}

class TaskTypeLoading extends TaskTypeState {}

class TaskTypesLoaded extends TaskTypeState {
  final List<TaskTypeEntity> taskTypes;
  const TaskTypesLoaded(this.taskTypes);

  @override
  List<Object?> get props => [taskTypes];
}

class TaskTypeActionSuccess extends TaskTypeState {
  final String message;
  const TaskTypeActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskTypeError extends TaskTypeState {
  final String message;
  const TaskTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
