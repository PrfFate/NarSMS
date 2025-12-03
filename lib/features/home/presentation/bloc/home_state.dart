import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final int selectedNavIndex;
  final String selectedPageRoute;
  final String userName;
  final String userRole;

  // Sidebar menu states
  final Map<String, bool> expandedMenus;

  const HomeLoaded({
    required this.selectedNavIndex,
    this.selectedPageRoute = '/home',
    required this.userName,
    required this.userRole,
    this.expandedMenus = const {},
  });

  @override
  List<Object?> get props => [
        selectedNavIndex,
        selectedPageRoute,
        userName,
        userRole,
        expandedMenus,
      ];

  HomeLoaded copyWith({
    int? selectedNavIndex,
    String? selectedPageRoute,
    String? userName,
    String? userRole,
    Map<String, bool>? expandedMenus,
  }) {
    return HomeLoaded(
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      selectedPageRoute: selectedPageRoute ?? this.selectedPageRoute,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      expandedMenus: expandedMenus ?? this.expandedMenus,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class LogoutSuccess extends HomeState {
  const LogoutSuccess();
}
