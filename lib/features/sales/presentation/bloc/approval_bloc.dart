import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasarim_app/features/sales/domain/usecases/approval_usecases.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_event.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final GetWorkflowsUseCase getWorkflows;
  final CreateWorkflowUseCase createWorkflow;
  final DeleteWorkflowUseCase deleteWorkflow;
  final ActivateWorkflowUseCase activateWorkflow;
  final DeactivateWorkflowUseCase deactivateWorkflow;
  final UpdateWorkflowVersionUseCase updateWorkflowVersion;
  final GetRolesUseCase getRoles;

  ApprovalBloc({
    required this.getWorkflows,
    required this.createWorkflow,
    required this.deleteWorkflow,
    required this.activateWorkflow,
    required this.deactivateWorkflow,
    required this.updateWorkflowVersion,
    required this.getRoles,
  }) : super(ApprovalInitial()) {
    on<LoadWorkflows>(_onLoadWorkflows);
    on<CreateWorkflow>(_onCreateWorkflow);
    on<UpdateWorkflowVersion>(_onUpdateWorkflowVersion);
    on<DeleteWorkflow>(_onDeleteWorkflow);
    on<ToggleWorkflowStatus>(_onToggleWorkflowStatus);
    on<LoadRoles>(_onLoadRoles);
  }

  Future<void> _onLoadWorkflows(
      LoadWorkflows event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    final result = await getWorkflows();
    result.fold(
      (failure) => emit(ApprovalError(failure.message)),
      (workflows) => emit(WorkflowsLoaded(workflows)),
    );
  }

  Future<void> _onLoadRoles(
      LoadRoles event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    final result = await getRoles();
    result.fold(
      (failure) => emit(ApprovalError(failure.message)),
      (roles) => emit(RolesLoaded(roles)),
    );
  }

  Future<void> _onCreateWorkflow(
      CreateWorkflow event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    final result = await createWorkflow(event.data);
    result.fold(
      (failure) => emit(ApprovalError(failure.message)),
      (_) {
        emit(const ApprovalSuccess('İş akışı başarıyla oluşturuldu'));
        add(LoadWorkflows());
      },
    );
  }

  Future<void> _onUpdateWorkflowVersion(
      UpdateWorkflowVersion event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    final result = await updateWorkflowVersion(event.id, event.data);
    result.fold(
      (failure) => emit(ApprovalError(failure.message)),
      (_) {
        emit(const ApprovalSuccess('İş akışı versiyonu güncellendi'));
        add(LoadWorkflows());
      },
    );
  }

  Future<void> _onDeleteWorkflow(
      DeleteWorkflow event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    final result = await deleteWorkflow(event.id);
    result.fold(
      (failure) => emit(ApprovalError(failure.message)),
      (_) {
        emit(const ApprovalSuccess('İş akışı silindi'));
        add(LoadWorkflows());
      },
    );
  }

  Future<void> _onToggleWorkflowStatus(
      ToggleWorkflowStatus event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    final result = event.isActive
        ? await activateWorkflow(event.id)
        : await deactivateWorkflow(event.id);

    result.fold(
      (failure) => emit(ApprovalError(failure.message)),
      (_) {
        emit(ApprovalSuccess(event.isActive
            ? 'İş akışı aktif edildi'
            : 'İş akışı deaktif edildi'));
        add(LoadWorkflows());
      },
    );
  }
}
