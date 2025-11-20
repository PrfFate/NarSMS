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
  final String userName;
  final String userRole;

  const HomeLoaded({
    required this.isSidebarCollapsed,
    required this.selectedNavIndex,
    this.expandedMenuItem,
    required this.userName,
    required this.userRole,
  });

  @override
  List<Object?> get props => [
        isSidebarCollapsed,
        selectedNavIndex,
        expandedMenuItem,
        userName,
        userRole,
      ];

  HomeLoaded copyWith({
    bool? isSidebarCollapsed,
    int? selectedNavIndex,
    String? expandedMenuItem,
    String? userName,
    String? userRole,
  }) {
    return HomeLoaded(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      expandedMenuItem: expandedMenuItem ?? this.expandedMenuItem,
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
