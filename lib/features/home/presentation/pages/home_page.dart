import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasarim_app/config/routes/app_router.dart';
import 'package:tasarim_app/core/utils/page_title_notifier.dart';
import 'package:tasarim_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:tasarim_app/features/home/presentation/bloc/home_event.dart';
import 'package:tasarim_app/features/home/presentation/bloc/home_state.dart';
import 'package:tasarim_app/features/home/presentation/widgets/home_drawer_widget.dart';

// Sayfa import'ları
import '../../../devices/presentation/pages/device_list_page.dart';
import '../../../devices/presentation/bloc/device_bloc.dart';
import '../../../devices/presentation/pages/depot_devices_page.dart';
import '../../../devices/presentation/pages/depot_backup_devices_page.dart';
import '../../../devices/presentation/pages/assigned_backup_devices_page.dart';
import '../../../sales/presentation/pages/pending_sales_page.dart';
import '../../../sales/presentation/pages/shipped_sales_page.dart';
import '../../../sales/presentation/pages/delivered_sales_page.dart';
import '../../../sales/presentation/pages/completed_sales_page.dart';
import '../../../sales/presentation/pages/rejected_sales_page.dart';
import '../../../sales/presentation/pages/approved_sales_page.dart';
import '../../../sales/presentation/pages/partially_shipped_sales_page.dart';
import '../../../technical_service/presentation/pages/service_pre_registrations_page.dart';
import '../../../technical_service/presentation/bloc/technical_service_bloc.dart';
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
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../admin/presentation/pages/logging_page.dart';
import '../../../admin/presentation/pages/users_management_page.dart';
import '../../../roles/accounting/pages/accounting_dashboard_page.dart';
import '../../../roles/dealer/pages/dealer_dashboard_page.dart';
import '../../../roles/salesperson/pages/salesperson_dashboard_page.dart';
import '../../../roles/user/pages/user_dashboard_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/pages/approval_workflows_page.dart';

/// Route → Sayfa başlığı eşleştirmesi
const Map<String, String> _routeTitles = {
  AppRouter.home: 'Dashboard',
  AppRouter.adminDashboard: 'Dashboard',
  AppRouter.dealerDashboard: 'Bayi Anasayfa',
  AppRouter.userDashboard: 'Kullanıcı Anasayfa',
  AppRouter.stockManagerDashboard: 'Dashboard',
  AppRouter.salespersonDashboard: 'Satış Anasayfa',
  AppRouter.accountingDashboard: 'Muhasebe Anasayfa',
  AppRouter.fielderDashboard: 'Dashboard',
  // Cihazlar
  AppRouter.deviceList: 'Tüm Cihazlar',
  AppRouter.depotDevices: 'Depodaki Cihazlar',
  AppRouter.depotBackupDevices: 'Depodaki Yedek Cihazlar',
  AppRouter.assignedBackupDevices: 'Atanmış Yedek Cihazlar',
  // Satışlar
  AppRouter.pendingSales: 'Onay Bekleyen Satışlar',
  AppRouter.shippedSales: 'Kargolanan Satışlar',
  AppRouter.deliveredSales: 'Teslim Edilen Satışlar',
  AppRouter.completedSales: 'Tamamlanan Satışlar',
  AppRouter.rejectedSales: 'Reddedilen Satışlar',
  AppRouter.approvalWorkflows: 'Onay Mekanizması',
  AppRouter.approvedSales: 'Onaylanan Satışlar',
  AppRouter.partiallyShippedSales: 'Kısmi Kargolanan Satışlar',
  // Teknik Servis
  AppRouter.servicePreRegistrations: 'Servis Ön Kayıtları',
  AppRouter.serviceOngoing: 'Devam Eden Servisler',
  AppRouter.serviceFinalChecks: 'Son Kontroller',
  AppRouter.serviceCompleted: 'Tamamlanan Servisler',
  // Saha Yönetimi
  AppRouter.pendingTasks: 'Bekleyen Görevler',
  AppRouter.acceptedTasks: 'Kabul Edilen Görevler',
  AppRouter.ongoingTasks: 'Devam Eden Görevler',
  AppRouter.completedTasks: 'Tamamlanan Görevler',
  AppRouter.cancelledTasks: 'Reddedilen Görevler',
  // Saha Görevlerim
  AppRouter.myAssignedTasks: 'Atanan Görevlerim',
  AppRouter.myAcceptedTasks: 'Kabul Ettiğim Görevlerim',
  AppRouter.myOngoingTasks: 'Devam Eden Görevlerim',
  AppRouter.myCompletedTasks: 'Tamamladığım Görevlerim',
  // Müşteriler
  AppRouter.customerList: 'Müşteriler',
  // Admin
  AppRouter.logging: 'Loglama',
  AppRouter.usersManagement: 'Kullanıcı Yönetimi',
};

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        } else if (state is HomeLoaded) {
          final role = state.userRole.toLowerCase().trim();
          if (role == 'pendinguser' || role == 'pending') {
            Navigator.pushReplacementNamed(context, AppRouter.pendingUser);
          }
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
          // expandedMenus değiştiğinde REBUILD ETME - bu sidebar'ın kendi işi
          // Sadece userName, userRole, selectedNavIndex değiştiğinde rebuild et
          return previous.userName != current.userName ||
              previous.userRole != current.userRole ||
              previous.selectedNavIndex != current.selectedNavIndex ||
              previous.selectedPageRoute != current.selectedPageRoute;
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

    // Route değişince başlığı güncelle
    final title = _routeTitles[state.selectedPageRoute] ?? 'Dashboard';
    PageTitleNotifier.instance.value = title;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 48,
        shape: const Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: ValueListenableBuilder<String>(
          valueListenable: PageTitleNotifier.instance,
          builder: (context, pageTitle, _) {
            return Text(
              pageTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF57C00),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Profil',
              icon: CircleAvatar(
                radius: 16,
                backgroundColor:
                    const Color(0xFFF57C00).withValues(alpha: 0.12),
                child: Text(
                  _buildInitials(state.userName),
                  style: const TextStyle(
                    color: Color(0xFFF57C00),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onPressed: () => _openProfile(context, state),
            ),
          ),
        ],
      ),
      onDrawerChanged: (isOpened) {},
      drawerScrimColor: Colors.black26,
      drawerEnableOpenDragGesture: false,
      drawer: const HomeDrawerWidget(),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
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
    );
  }

  void _openProfile(BuildContext context, HomeLoaded state) {
    final homeBloc = context.read<HomeBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: homeBloc,
          child: ProfilePage(
            userName: state.userName,
            userRole: state.userRole,
          ),
        ),
      ),
    );
  }

  String _buildInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // Seçili route'a göre içerik döndür
  Widget _getPageContent(BuildContext context, String route) {
    switch (route) {
      // Cihazlar
      case AppRouter.deviceList:
        return BlocProvider(
          create: (_) => getIt<DeviceBloc>(),
          child: const DeviceListPage(),
        );
      case AppRouter.depotDevices:
        return BlocProvider(
          create: (_) => getIt<DeviceBloc>(),
          child: const DepotDevicesPage(),
        );
      case AppRouter.depotBackupDevices:
        return BlocProvider(
          create: (_) => getIt<DeviceBloc>(),
          child: const DepotBackupDevicesPage(),
        );
      case AppRouter.assignedBackupDevices:
        return BlocProvider(
          create: (_) => getIt<DeviceBloc>(),
          child: const AssignedBackupDevicesPage(),
        );

      // Satışlar
      case AppRouter.pendingSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const PendingSalesPage(),
        );
      case AppRouter.shippedSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const ShippedSalesPage(),
        );
      case AppRouter.deliveredSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const DeliveredSalesPage(),
        );
      case AppRouter.completedSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const CompletedSalesPage(),
        );
      case AppRouter.rejectedSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const RejectedSalesPage(),
        );
      case AppRouter.approvalWorkflows:
        return BlocProvider(
          create: (_) => getIt<ApprovalBloc>(),
          child: const ApprovalWorkflowsPage(),
        );

      // Satış Kargolama
      case AppRouter.approvedSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const ApprovedSalesPage(),
        );
      case AppRouter.partiallyShippedSales:
        return BlocProvider(
          create: (_) => getIt<SaleBloc>(),
          child: const PartiallyShippedSalesPage(),
        );

      // Teknik Servis
      case AppRouter.servicePreRegistrations:
        return BlocProvider(
          create: (_) => getIt<TechnicalServiceBloc>(),
          child: const ServicePreRegistrationsPage(),
        );
      case AppRouter.serviceOngoing:
        return BlocProvider(
          create: (_) => getIt<TechnicalServiceBloc>(),
          child: const ServiceOngoingPage(),
        );
      case AppRouter.serviceFinalChecks:
        return BlocProvider(
          create: (_) => getIt<TechnicalServiceBloc>(),
          child: const ServiceFinalChecksPage(),
        );
      case AppRouter.serviceCompleted:
        return BlocProvider(
          create: (_) => getIt<TechnicalServiceBloc>(),
          child: const ServiceCompletedPage(),
        );

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
        return BlocProvider(
          create: (_) => getIt<CustomerBloc>(),
          child: const CustomerListPage(),
        );

      // Loglama
      case AppRouter.logging:
        return const LoggingPage();

      // Kullanıcılar
      case AppRouter.usersManagement:
        return const UsersManagementPage();

      // Dashboard (Home)
      case AppRouter.adminDashboard:
        return const DashboardPage();
      case AppRouter.dealerDashboard:
        return const DealerDashboardPage();
      case AppRouter.userDashboard:
        return const UserDashboardPage();
      case AppRouter.stockManagerDashboard:
        return const DashboardPage();
      case AppRouter.salespersonDashboard:
        return const SalespersonDashboardPage();
      case AppRouter.accountingDashboard:
        return const AccountingDashboardPage();
      case AppRouter.fielderDashboard:
        return const DashboardPage();
      case AppRouter.home:
      default:
        return const DashboardPage();
    }
  }
}
