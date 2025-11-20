import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserInfo extends HomeEvent {
  const LoadUserInfo();
}

class ToggleSidebar extends HomeEvent {
  const ToggleSidebar();
}

class ChangeNavigation extends HomeEvent {
  final int index;

  const ChangeNavigation(this.index);

  @override
  List<Object?> get props => [index];
}

class ExpandMenuItem extends HomeEvent {
  final String? menuRoute;

  const ExpandMenuItem(this.menuRoute);

  @override
  List<Object?> get props => [menuRoute];
}

class LogoutRequested extends HomeEvent {
  const LogoutRequested();
}
