import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
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
      (userInfo) => emit(HomeLoaded(
        selectedNavIndex: 0,
        userName: userInfo['userName'] ?? '',
        userRole: userInfo['userRole'] ?? '',
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
      // Close all expanded menus when selecting a page
      final closedMenus = Map<String, bool>.from(currentState.expandedMenus);
      closedMenus.updateAll((key, value) => false);

      emit(currentState.copyWith(
        selectedPageRoute: event.route,
        expandedMenus: closedMenus,
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
