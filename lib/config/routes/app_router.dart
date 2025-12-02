import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';

// Role-based dashboards
import '../../features/roles/admin/pages/admin_dashboard_page.dart';
import '../../features/roles/dealer/pages/dealer_dashboard_page.dart';
import '../../features/roles/user/pages/user_dashboard_page.dart';
import '../../features/roles/stock_manager/pages/stock_manager_dashboard_page.dart';
import '../../features/roles/salesperson/pages/salesperson_dashboard_page.dart';
import '../../features/roles/accounting/pages/accounting_dashboard_page.dart';
import '../../features/roles/fielder/pages/fielder_dashboard_page.dart';

// Field Management
import '../../features/field_management/presentation/pages/pending_tasks_page.dart';
import '../../features/field_management/presentation/pages/accepted_tasks_page.dart';
import '../../features/field_management/presentation/pages/ongoing_tasks_page.dart';
import '../../features/field_management/presentation/pages/completed_tasks_page.dart';
import '../../features/field_management/presentation/pages/cancelled_tasks_page.dart';

// Field Tasks
import '../../features/field_tasks/presentation/pages/my_assigned_tasks_page.dart';
import '../../features/field_tasks/presentation/pages/my_accepted_tasks_page.dart';
import '../../features/field_tasks/presentation/pages/my_ongoing_tasks_page.dart';
import '../../features/field_tasks/presentation/pages/my_completed_tasks_page.dart';

// Sales
import '../../features/sales/presentation/pages/pending_sales_page.dart';
import '../../features/sales/presentation/pages/approved_sales_page.dart';
import '../../features/sales/presentation/pages/rejected_sales_page.dart';
import '../../features/sales/presentation/pages/partially_shipped_sales_page.dart';
import '../../features/sales/presentation/pages/shipped_sales_page.dart';
import '../../features/sales/presentation/pages/delivered_sales_page.dart';
import '../../features/sales/presentation/pages/completed_sales_page.dart';
import '../../features/sales/presentation/pages/sale_add_page.dart';

// Devices
import '../../features/devices/presentation/pages/device_list_page.dart';
import '../../features/devices/presentation/pages/device_add_page.dart';
import '../../features/devices/presentation/pages/device_edit_page.dart';
import '../../features/devices/presentation/pages/device_return_page.dart';
import '../../features/devices/presentation/pages/depot_devices_page.dart';
import '../../features/devices/presentation/pages/depot_backup_devices_page.dart';
import '../../features/devices/presentation/pages/assigned_backup_devices_page.dart';

// Customers
import '../../features/customers/presentation/pages/customer_list_page.dart';
import '../../features/customers/presentation/pages/customer_add_page.dart';

// Reporting
import '../../features/reporting/presentation/pages/customer_reports_page.dart';
import '../../features/reporting/presentation/pages/device_reports_page.dart';
import '../../features/reporting/presentation/pages/sales_reports_page.dart';
import '../../features/reporting/presentation/pages/user_reports_page.dart';

// Helpers
import '../../features/carrier/presentation/pages/carrier_management_page.dart';
import '../../features/supplier/presentation/pages/supplier_management_page.dart';
import '../../features/technical_service/presentation/pages/technical_service_page.dart';

// Technical Service
import '../../features/technical_service/presentation/pages/service_pre_registrations_page.dart';
import '../../features/technical_service/presentation/pages/service_ongoing_page.dart';
import '../../features/technical_service/presentation/pages/service_final_checks_page.dart';
import '../../features/technical_service/presentation/pages/service_completed_page.dart';

// Admin
import '../../features/admin/presentation/pages/approval_mechanism_page.dart';
import '../../features/admin/presentation/pages/users_management_page.dart';
import '../../features/admin/presentation/pages/logging_page.dart';

class AppRouter {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  // Role-based dashboard routes
  static const String adminDashboard = '/admin-dashboard';
  static const String dealerDashboard = '/dealer-dashboard';
  static const String userDashboard = '/user-dashboard';
  static const String stockManagerDashboard = '/stock-manager-dashboard';
  static const String salespersonDashboard = '/salesperson-dashboard';
  static const String accountingDashboard = '/accounting-dashboard';
  static const String fielderDashboard = '/fielder-dashboard';

  // Field Management routes
  static const String pendingTasks = '/field-management/pending-tasks';
  static const String acceptedTasks = '/field-management/accepted-tasks';
  static const String ongoingTasks = '/field-management/ongoing-tasks';
  static const String completedTasks = '/field-management/completed-tasks';
  static const String cancelledTasks = '/field-management/cancelled-tasks';

  // Field Tasks routes
  static const String myAssignedTasks = '/field-tasks/my-assigned-tasks';
  static const String myAcceptedTasks = '/field-tasks/my-accepted-tasks';
  static const String myOngoingTasks = '/field-tasks/my-ongoing-tasks';
  static const String myCompletedTasks = '/field-tasks/my-completed-tasks';

  // Sales routes
  static const String pendingSales = '/sales/pending';
  static const String approvedSales = '/sales/approved';
  static const String rejectedSales = '/sales/rejected';
  static const String partiallyShippedSales = '/sales/partially-shipped';
  static const String shippedSales = '/sales/shipped';
  static const String deliveredSales = '/sales/delivered';
  static const String completedSales = '/sales/completed';
  static const String saleAdd = '/sales/add';

  // Device routes
  static const String deviceList = '/devices/list';
  static const String deviceAdd = '/devices/add';
  static const String deviceEdit = '/devices/edit';
  static const String deviceReturn = '/devices/return';
  static const String depotDevices = '/devices/depot';
  static const String depotBackupDevices = '/devices/depot-backup';
  static const String assignedBackupDevices = '/devices/assigned-backup';

  // Customer routes
  static const String customerList = '/customers/list';
  static const String customerAdd = '/customers/add';

  // Reporting routes
  static const String customerReports = '/reports/customers';
  static const String deviceReports = '/reports/devices';
  static const String salesReports = '/reports/sales';
  static const String userReports = '/reports/users';

  // Helper routes
  static const String carrierManagement = '/carrier-management';
  static const String supplierManagement = '/supplier-management';
  static const String technicalService = '/technical-service';

  // Technical Service routes
  static const String servicePreRegistrations = '/technical-service/pre-registrations';
  static const String serviceOngoing = '/technical-service/ongoing';
  static const String serviceFinalChecks = '/technical-service/final-checks';
  static const String serviceCompleted = '/technical-service/completed';

  // Admin routes
  static const String approvalMechanism = '/admin/approval-mechanism';
  static const String usersManagement = '/admin/users';
  static const String logging = '/admin/logging';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: const LoginPage(),
          ),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<HomeBloc>(),
            child: const HomePage(),
          ),
        );

      // Role-based dashboards
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case dealerDashboard:
        return MaterialPageRoute(builder: (_) => const DealerDashboardPage());

      case userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboardPage());

      case stockManagerDashboard:
        return MaterialPageRoute(
            builder: (_) => const StockManagerDashboardPage());

      case salespersonDashboard:
        return MaterialPageRoute(
            builder: (_) => const SalespersonDashboardPage());

      case accountingDashboard:
        return MaterialPageRoute(
            builder: (_) => const AccountingDashboardPage());

      case fielderDashboard:
        return MaterialPageRoute(builder: (_) => const FielderDashboardPage());

      // Field Management
      case pendingTasks:
        return MaterialPageRoute(builder: (_) => const PendingTasksPage());

      case acceptedTasks:
        return MaterialPageRoute(builder: (_) => const AcceptedTasksPage());

      case ongoingTasks:
        return MaterialPageRoute(builder: (_) => const OngoingTasksPage());

      case completedTasks:
        return MaterialPageRoute(builder: (_) => const CompletedTasksPage());

      case cancelledTasks:
        return MaterialPageRoute(builder: (_) => const CancelledTasksPage());

      // Field Tasks
      case myAssignedTasks:
        return MaterialPageRoute(builder: (_) => const MyAssignedTasksPage());

      case myAcceptedTasks:
        return MaterialPageRoute(builder: (_) => const MyAcceptedTasksPage());

      case myOngoingTasks:
        return MaterialPageRoute(builder: (_) => const MyOngoingTasksPage());

      case myCompletedTasks:
        return MaterialPageRoute(builder: (_) => const MyCompletedTasksPage());

      // Sales
      case pendingSales:
        return MaterialPageRoute(builder: (_) => const PendingSalesPage());

      case approvedSales:
        return MaterialPageRoute(builder: (_) => const ApprovedSalesPage());

      case rejectedSales:
        return MaterialPageRoute(builder: (_) => const RejectedSalesPage());

      case partiallyShippedSales:
        return MaterialPageRoute(
            builder: (_) => const PartiallyShippedSalesPage());

      case shippedSales:
        return MaterialPageRoute(builder: (_) => const ShippedSalesPage());

      case deliveredSales:
        return MaterialPageRoute(builder: (_) => const DeliveredSalesPage());

      case completedSales:
        return MaterialPageRoute(builder: (_) => const CompletedSalesPage());

      case saleAdd:
        return MaterialPageRoute(builder: (_) => const SaleAddPage());

      // Devices
      case deviceList:
        return MaterialPageRoute(builder: (_) => const DeviceListPage());

      case deviceAdd:
        return MaterialPageRoute(builder: (_) => const DeviceAddPage());

      case deviceEdit:
        return MaterialPageRoute(builder: (_) => const DeviceEditPage());

      case deviceReturn:
        return MaterialPageRoute(builder: (_) => const DeviceReturnPage());

      case depotDevices:
        return MaterialPageRoute(builder: (_) => const DepotDevicesPage());

      case depotBackupDevices:
        return MaterialPageRoute(
            builder: (_) => const DepotBackupDevicesPage());

      case assignedBackupDevices:
        return MaterialPageRoute(
            builder: (_) => const AssignedBackupDevicesPage());

      // Customers
      case customerList:
        return MaterialPageRoute(builder: (_) => const CustomerListPage());

      case customerAdd:
        return MaterialPageRoute(builder: (_) => const CustomerAddPage());

      // Reporting
      case customerReports:
        return MaterialPageRoute(builder: (_) => const CustomerReportsPage());

      case deviceReports:
        return MaterialPageRoute(builder: (_) => const DeviceReportsPage());

      case salesReports:
        return MaterialPageRoute(builder: (_) => const SalesReportsPage());

      case userReports:
        return MaterialPageRoute(builder: (_) => const UserReportsPage());

      // Helpers
      case carrierManagement:
        return MaterialPageRoute(
            builder: (_) => const CarrierManagementPage());

      case supplierManagement:
        return MaterialPageRoute(
            builder: (_) => const SupplierManagementPage());

      case technicalService:
        return MaterialPageRoute(builder: (_) => const TechnicalServicePage());

      // Technical Service routes
      case servicePreRegistrations:
        return MaterialPageRoute(
            builder: (_) => const ServicePreRegistrationsPage());

      case serviceOngoing:
        return MaterialPageRoute(builder: (_) => const ServiceOngoingPage());

      case serviceFinalChecks:
        return MaterialPageRoute(
            builder: (_) => const ServiceFinalChecksPage());

      case serviceCompleted:
        return MaterialPageRoute(builder: (_) => const ServiceCompletedPage());

      // Admin routes
      case approvalMechanism:
        return MaterialPageRoute(
            builder: (_) => const ApprovalMechanismPage());

      case usersManagement:
        return MaterialPageRoute(
            builder: (_) => const UsersManagementPage());

      case logging:
        return MaterialPageRoute(builder: (_) => const LoggingPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 - Page Not Found'),
            ),
          ),
        );
    }
  }
}
