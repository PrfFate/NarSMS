import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/auth/role_access_policy.dart';
import '../../../../core/realtime/role_change_hub_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserInfoUseCase getUserInfoUseCase;
  final LogoutUseCase logoutUseCase;
  final RoleChangeHubService roleChangeHubService;

  HomeBloc({
    required this.getUserInfoUseCase,
    required this.logoutUseCase,
    required this.roleChangeHubService,
  }) : super(const HomeInitial()) {
    on<LoadUserInfo>(_onLoadUserInfo);
    on<ChangeNavigation>(_onChangeNavigation);
    on<ToggleMenuExpansion>(_onToggleMenuExpansion);
    on<SelectPage>(_onSelectPage);
    on<LogoutRequested>(_onLogoutRequested);
    on<RoleChangedReceived>(_onRoleChangedReceived);
  }

  Future<void> _onLoadUserInfo(
    LoadUserInfo event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getUserInfoUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (user) {
        emit(HomeLoaded(
          selectedNavIndex: 0,
          userName: user.username ?? '',
          userRole: user.roleName ?? '',
          expandedMenus: const {},
        ));
        roleChangeHubService.start(
          onCurrentUserRoleChanged: (roleName) {
            add(RoleChangedReceived(roleName));
          },
        );
      },
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
      final newExpandedMenus =
          Map<String, bool>.from(currentState.expandedMenus);

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
      final newExpandedMenus =
          Map<String, bool>.from(currentState.expandedMenus);

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

      final nextRoute = _isRouteAllowedForRole(
        route: event.route,
        role: currentState.userRole,
      )
          ? event.route
          : _defaultRouteForRole(currentState.userRole);

      emit(currentState.copyWith(
        selectedPageRoute: nextRoute,
        expandedMenus: newExpandedMenus,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<HomeState> emit,
  ) async {
    await roleChangeHubService.stop();
    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (_) => emit(const LogoutSuccess()),
    );
  }

  void _onRoleChangedReceived(
    RoleChangedReceived event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    final nextRoute = _isRouteAllowedForRole(
      route: currentState.selectedPageRoute,
      role: event.roleName,
    )
        ? currentState.selectedPageRoute
        : _defaultRouteForRole(event.roleName);

    emit(currentState.copyWith(
      userRole: event.roleName,
      selectedPageRoute: nextRoute,
      selectedNavIndex: nextRoute == currentState.selectedPageRoute
          ? currentState.selectedNavIndex
          : 0,
    ));
  }

  String _defaultRouteForRole(String role) {
    return AppRouter.home;
  }

  bool _isRouteAllowedForRole({
    required String route,
    required String role,
  }) {
    return RoleAccessPolicy.isRouteAllowedInHome(route: route, role: role);
  }

  @override
  Future<void> close() async {
    await roleChangeHubService.stop();
    return super.close();
  }
}
