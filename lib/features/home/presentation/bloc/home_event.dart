import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserInfo extends HomeEvent {
  const LoadUserInfo();
}

class ChangeNavigation extends HomeEvent {
  final int index;

  const ChangeNavigation(this.index);

  @override
  List<Object?> get props => [index];
}

class ToggleMenuExpansion extends HomeEvent {
  final String menuKey;

  const ToggleMenuExpansion(this.menuKey);

  @override
  List<Object?> get props => [menuKey];
}

class SelectPage extends HomeEvent {
  final String route;

  const SelectPage(this.route);

  @override
  List<Object?> get props => [route];
}

class LogoutRequested extends HomeEvent {
  const LogoutRequested();
}
