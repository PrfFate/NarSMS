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
  final bool isSidebarCollapsed;
  final int selectedNavIndex;
  final String? expandedMenuItem;
  final String selectedPageRoute; // Seçili sayfa route'u
  final String userName;
  final String userRole;

  const HomeLoaded({
    required this.isSidebarCollapsed,
    required this.selectedNavIndex,
    this.expandedMenuItem,
    this.selectedPageRoute = '/home',
    required this.userName,
    required this.userRole,
  });

  @override
  List<Object?> get props => [
        isSidebarCollapsed,
        selectedNavIndex,
        expandedMenuItem,
        selectedPageRoute,
        userName,
        userRole,
      ];

  HomeLoaded copyWith({
    bool? isSidebarCollapsed,
    int? selectedNavIndex,
    String? expandedMenuItem,
    String? selectedPageRoute,
    String? userName,
    String? userRole,
  }) {
    return HomeLoaded(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      expandedMenuItem: expandedMenuItem,
      selectedPageRoute: selectedPageRoute ?? this.selectedPageRoute,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
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
