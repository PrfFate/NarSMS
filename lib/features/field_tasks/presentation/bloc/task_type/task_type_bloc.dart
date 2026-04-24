import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/task_type_repository.dart';
import 'task_type_event.dart';
import 'task_type_state.dart';

class TaskTypeBloc extends Bloc<TaskTypeEvent, TaskTypeState> {
  final TaskTypeRepository repository;

  TaskTypeBloc({required this.repository}) : super(TaskTypeInitial()) {
    on<GetAllTaskTypes>(_onGetAllTaskTypes);
    on<GetActiveTaskTypes>(_onGetActiveTaskTypes);
    on<CreateTaskType>(_onCreateTaskType);
    on<UpdateTaskType>(_onUpdateTaskType);
    on<DeleteTaskType>(_onDeleteTaskType);
  }

  Future<void> _onGetAllTaskTypes(
      GetAllTaskTypes event, Emitter<TaskTypeState> emit) async {
    emit(TaskTypeLoading());
    final result = await repository.getAllTaskTypes();
    result.fold(
      (failure) => emit(TaskTypeError(failure.message)),
      (taskTypes) => emit(TaskTypesLoaded(taskTypes)),
    );
  }

  Future<void> _onGetActiveTaskTypes(
      GetActiveTaskTypes event, Emitter<TaskTypeState> emit) async {
    emit(TaskTypeLoading());
    final result = await repository.getActiveTaskTypes();
    result.fold(
      (failure) => emit(TaskTypeError(failure.message)),
      (taskTypes) => emit(TaskTypesLoaded(taskTypes)),
    );
  }

  Future<void> _onCreateTaskType(
      CreateTaskType event, Emitter<TaskTypeState> emit) async {
    emit(TaskTypeLoading());
    final result = await repository.createTaskType(event.taskType);
    result.fold(
      (failure) => emit(TaskTypeError(failure.message)),
      (_) => emit(const TaskTypeActionSuccess('Görev tipi başarıyla eklendi')),
    );
  }

  Future<void> _onUpdateTaskType(
      UpdateTaskType event, Emitter<TaskTypeState> emit) async {
    emit(TaskTypeLoading());
    final result = await repository.updateTaskType(event.id, event.data);
    result.fold(
      (failure) => emit(TaskTypeError(failure.message)),
      (_) => emit(const TaskTypeActionSuccess('Görev tipi başarıyla güncellendi')),
    );
  }

  Future<void> _onDeleteTaskType(
      DeleteTaskType event, Emitter<TaskTypeState> emit) async {
    emit(TaskTypeLoading());
    final result = await repository.deleteTaskType(event.id);
    result.fold(
      (failure) => emit(TaskTypeError(failure.message)),
      (_) => emit(const TaskTypeActionSuccess('Görev tipi başarıyla silindi')),
    );
  }
}
