import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_sidebar_widget.dart';
import '../widgets/home_bottom_nav_bar.dart';

// Sayfa import'ları
import '../../../devices/presentation/pages/device_list_page.dart';
import '../../../devices/presentation/pages/depot_devices_page.dart';
import '../../../devices/presentation/pages/depot_backup_devices_page.dart';
import '../../../sales/presentation/pages/pending_sales_page.dart';
import '../../../sales/presentation/pages/shipped_sales_page.dart';
import '../../../sales/presentation/pages/delivered_sales_page.dart';
import '../../../sales/presentation/pages/completed_sales_page.dart';
import '../../../sales/presentation/pages/rejected_sales_page.dart';
import '../../../sales/presentation/pages/approval_mechanism_page.dart';
import '../../../sales/presentation/pages/approved_sales_page.dart';
import '../../../sales/presentation/pages/partially_shipped_sales_page.dart';
import '../../../technical_service/presentation/pages/service_pre_registrations_page.dart';
import '../../../technical_service/presentation/pages/service_ongoing_page.dart';
import '../../../technical_service/presentation/pages/service_final_checks_page.dart';
import '../../../technical_service/presentation/pages/service_completed_page.dart';
import '../../../field_management/presentation/pages/pending_tasks_page.dart';
import '../../../field_management/presentation/pages/accepted_tasks_page.dart';
import '../../../field_management/presentation/pages/ongoing_tasks_page.dart';
import '../../../field_management/presentation/pages/completed_tasks_page.dart';
import '../../../field_management/presentation/pages/cancelled_tasks_page.dart';
import '../../../field_tasks/presentation/pages/my_assigned_tasks_page.dart';
import '../../../field_tasks/presentation/pages/my_accepted_tasks_page.dart';
import '../../../field_tasks/presentation/pages/my_ongoing_tasks_page.dart';
import '../../../field_tasks/presentation/pages/my_completed_tasks_page.dart';
import '../../../customers/presentation/pages/customer_list_page.dart';
import '../../../reporting/presentation/pages/customer_reports_page.dart';
import '../../../admin/presentation/pages/logging_page.dart';
import '../../../admin/presentation/pages/users_management_page.dart';

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
      buildWhen: (previous, current) {
        // Sadece önemli değişikliklerde rebuild et
        if (previous is HomeLoaded && current is HomeLoaded) {
          // expandedMenuItem değiştiğinde REBUILD ETME
          // Sadece userName, userRole, selectedNavIndex değiştiğinde rebuild et
          return previous.userName != current.userName ||
                 previous.userRole != current.userRole ||
                 previous.selectedNavIndex != current.selectedNavIndex;
        }
        return true; // Diğer durumlarda rebuild et
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
      onDrawerChanged: (isOpened) {
        // Drawer açıldığında veya kapandığında callback
      },
      drawerScrimColor: Colors.black26,
      drawerEnableOpenDragGesture: false,
      drawer: GestureDetector(
        onTap: () {
          // Drawer içine tıklandığında hiçbir şey yapma
        },
        child: Container(
          margin: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
          ),
          child: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: HomeSidebarWidget(
              isCollapsed: false,
              currentRoute: state.selectedPageRoute,
              onLogout: () {
                context.read<HomeBloc>().add(const LogoutRequested());
              },
              userRole: state.userRole,
              userName: state.userName,
              expandedMenuItem: state.expandedMenuItem,
              onExpandMenuItem: (route) {
                context.read<HomeBloc>().add(ExpandMenuItem(route));
              },
              onPageSelected: (route, {bool closeDrawer = false, String? keepMenuExpanded}) {
                // Alt menüden seçim yapıldıysa parent menüyü açık tut
                context.read<HomeBloc>().add(
                  ChangeSelectedPage(route, expandedMenuItem: keepMenuExpanded)
                );
                if (closeDrawer) {
                  Navigator.of(context).pop(); // Drawer'ı kapat
                }
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          // Sadece selectedPageRoute değiştiğinde rebuild et
          if (previous is HomeLoaded && current is HomeLoaded) {
            return previous.selectedPageRoute != current.selectedPageRoute;
          }
          return true;
        },
        builder: (context, bodyState) {
          if (bodyState is HomeLoaded) {
            return _getPageContent(context, bodyState.selectedPageRoute);
          }
          return const Center(child: CircularProgressIndicator());
        },
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

  // Seçili route'a göre içerik döndür
  Widget _getPageContent(BuildContext context, String route) {
    switch (route) {
      // Cihazlar
      case AppRouter.deviceList:
        return const DeviceListPage();
      case AppRouter.depotDevices:
        return const DepotDevicesPage();
      case AppRouter.depotBackupDevices:
        return const DepotBackupDevicesPage();

      // Satışlar
      case AppRouter.pendingSales:
        return const PendingSalesPage();
      case AppRouter.shippedSales:
        return const ShippedSalesPage();
      case AppRouter.deliveredSales:
        return const DeliveredSalesPage();
      case AppRouter.completedSales:
        return const CompletedSalesPage();
      case AppRouter.rejectedSales:
        return const RejectedSalesPage();
      case AppRouter.approvalMechanism:
        return const ApprovalMechanismPage();

      // Satış Kargolama
      case AppRouter.approvedSales:
        return const ApprovedSalesPage();
      case AppRouter.partiallyShippedSales:
        return const PartiallyShippedSalesPage();

      // Teknik Servis
      case AppRouter.servicePreRegistrations:
        return const ServicePreRegistrationsPage();
      case AppRouter.serviceOngoing:
        return const ServiceOngoingPage();
      case AppRouter.serviceFinalChecks:
        return const ServiceFinalChecksPage();
      case AppRouter.serviceCompleted:
        return const ServiceCompletedPage();

      // Saha Yönetimi
      case AppRouter.pendingTasks:
        return const PendingTasksPage();
      case AppRouter.acceptedTasks:
        return const AcceptedTasksPage();
      case AppRouter.ongoingTasks:
        return const OngoingTasksPage();
      case AppRouter.completedTasks:
        return const CompletedTasksPage();
      case AppRouter.cancelledTasks:
        return const CancelledTasksPage();

      // Saha Görevleri
      case AppRouter.myAssignedTasks:
        return const MyAssignedTasksPage();
      case AppRouter.myAcceptedTasks:
        return const MyAcceptedTasksPage();
      case AppRouter.myOngoingTasks:
        return const MyOngoingTasksPage();
      case AppRouter.myCompletedTasks:
        return const MyCompletedTasksPage();

      // Müşteriler
      case AppRouter.customerList:
        return const CustomerListPage();

      // Raporlama
      case AppRouter.customerReports:
        return const CustomerReportsPage();

      // Loglama
      case AppRouter.logging:
        return const LoggingPage();

      // Kullanıcılar
      case AppRouter.usersManagement:
        return const UsersManagementPage();

      // Dashboard (Home)
      case AppRouter.home:
      default:
        return Padding(
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
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Hoş geldiniz! Lütfen sol menüden bir seçim yapın.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
