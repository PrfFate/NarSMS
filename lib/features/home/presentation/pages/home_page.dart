import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_sidebar_widget.dart';
import '../widgets/home_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        } else if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeInitial) {
          context.read<HomeBloc>().add(const LoadUserInfo());
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is HomeLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is HomeLoaded) {
          return _buildMobileLayout(context, state);
        }

        return const Scaffold(
          body: Center(
            child: Text('An error occurred'),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, HomeLoaded state) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            const Text(
              'Admin Paneli',
              style: TextStyle(
                color: Color(0xFFF57C00),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      drawerScrimColor: Colors.transparent,
      drawer: Container(
        margin: EdgeInsets.only(
          top: kToolbarHeight + MediaQuery.of(context).padding.top,
        ),
        child: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: HomeSidebarWidget(
            isCollapsed: false,
            currentRoute: '/dashboard',
            onLogout: () {
              context.read<HomeBloc>().add(const LogoutRequested());
            },
            userRole: state.userRole,
            userName: state.userName,
            expandedMenuItem: state.expandedMenuItem,
            onExpandMenuItem: (route) {
              context.read<HomeBloc>().add(ExpandMenuItem(route));
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Bu sayfa için içerik buraya gelecek.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selectedIndex: state.selectedNavIndex,
        onIndexChanged: (index) {
          context.read<HomeBloc>().add(ChangeNavigation(index));
        },
        userName: state.userName,
        userRole: state.userRole,
      ),
    );
  }

}
