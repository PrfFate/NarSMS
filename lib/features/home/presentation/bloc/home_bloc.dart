import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../config/routes/app_router.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserInfoUseCase getUserInfoUseCase;
  final LogoutUseCase logoutUseCase;

  HomeBloc({
    required this.getUserInfoUseCase,
    required this.logoutUseCase,
  }) : super(const HomeInitial()) {
    on<LoadUserInfo>(_onLoadUserInfo);
    on<ChangeNavigation>(_onChangeNavigation);
    on<ToggleMenuExpansion>(_onToggleMenuExpansion);
    on<SelectPage>(_onSelectPage);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadUserInfo(
    LoadUserInfo event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getUserInfoUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (user) => emit(HomeLoaded(
        selectedNavIndex: 0,
        userName: user.username ?? '',
        userRole: user.roleName ?? '',
        expandedMenus: {},
      )),
    );
  }

  void _onChangeNavigation(
    ChangeNavigation event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(selectedNavIndex: event.index));
    }
  }

  void _onToggleMenuExpansion(
    ToggleMenuExpansion event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newExpandedMenus = Map<String, bool>.from(currentState.expandedMenus);

      // Toggle the menu - if it's currently open, close it; if closed, open it
      final isCurrentlyExpanded = newExpandedMenus[event.menuKey] ?? false;

      if (!isCurrentlyExpanded) {
        // If opening a new menu, close all other menus first
        newExpandedMenus.updateAll((key, value) => false);
      }

      newExpandedMenus[event.menuKey] = !isCurrentlyExpanded;

      emit(currentState.copyWith(expandedMenus: newExpandedMenus));
    }
  }

  void _onSelectPage(
    SelectPage event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newExpandedMenus = Map<String, bool>.from(currentState.expandedMenus);

      // Route to MenuKey mapping
      final routeToMenuKey = {
        'devices': [
          AppRouter.deviceList,
          AppRouter.depotDevices,
          AppRouter.depotBackupDevices,
        ],
        'sales': [
          AppRouter.pendingSales,
          AppRouter.shippedSales,
          AppRouter.deliveredSales,
          AppRouter.completedSales,
          AppRouter.rejectedSales,
          AppRouter.approvalWorkflows,
        ],
        'shipments': [
          AppRouter.approvedSales,
          AppRouter.partiallyShippedSales,
        ],
        'technicalservice': [
          AppRouter.servicePreRegistrations,
          AppRouter.serviceOngoing,
          AppRouter.serviceFinalChecks,
          AppRouter.serviceCompleted,
        ],
        'fieldmanagement': [
          AppRouter.pendingTasks,
          AppRouter.acceptedTasks,
          AppRouter.ongoingTasks,
          AppRouter.completedTasks,
          AppRouter.cancelledTasks,
        ],
        'fieldtasks': [
          AppRouter.myAssignedTasks,
          AppRouter.myAcceptedTasks,
          AppRouter.myOngoingTasks,
          AppRouter.myCompletedTasks,
        ],
      };

      // Find the menu key for the current route
      String? activeMenuKey;
      routeToMenuKey.forEach((menuKey, routes) {
        if (routes.contains(event.route)) {
          activeMenuKey = menuKey;
        }
      });

      // Expand the menu containing the active route
      if (activeMenuKey != null) {
        newExpandedMenus[activeMenuKey!] = true;
      }

      emit(currentState.copyWith(
        selectedPageRoute: event.route,
        expandedMenus: newExpandedMenus,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<HomeState> emit,
  ) async {
    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (_) => emit(const LogoutSuccess()),
    );
  }
}
