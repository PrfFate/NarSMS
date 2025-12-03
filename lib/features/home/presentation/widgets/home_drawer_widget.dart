import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'home_sidebar_widget.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: BlocBuilder<HomeBloc, HomeState>(
        // Her state değişikliğinde rebuild et
        builder: (context, drawerState) {
          if (drawerState is! HomeLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return HomeSidebarWidget(
            currentRoute: drawerState.selectedPageRoute,
            onLogout: () {
              context.read<HomeBloc>().add(const LogoutRequested());
            },
            userRole: drawerState.userRole,
            userName: drawerState.userName,
            expandedMenus: drawerState.expandedMenus,
            onMenuToggle: (menuKey) {
              // Toggle menu expansion
              context.read<HomeBloc>().add(ToggleMenuExpansion(menuKey));
            },
            onPageSelect: (route) {
              // Select page
              context.read<HomeBloc>().add(SelectPage(route));
            },
          );
        },
      ),
    );
  }
}
