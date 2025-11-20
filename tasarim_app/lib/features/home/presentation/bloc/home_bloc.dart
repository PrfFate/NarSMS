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
    on<ToggleSidebar>(_onToggleSidebar);
    on<ChangeNavigation>(_onChangeNavigation);
    on<ExpandMenuItem>(_onExpandMenuItem);
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
        isSidebarCollapsed: false,
        selectedNavIndex: 0,
        expandedMenuItem: null,
        userName: userInfo['userName'] ?? '',
        userRole: userInfo['userRole'] ?? '',
      )),
    );
  }

  void _onToggleSidebar(
    ToggleSidebar event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        isSidebarCollapsed: !currentState.isSidebarCollapsed,
      ));
    }
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

  void _onExpandMenuItem(
    ExpandMenuItem event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(expandedMenuItem: event.menuRoute));
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
