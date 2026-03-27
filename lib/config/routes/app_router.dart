import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/pending_user_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/home_event.dart';
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
import 'package:tasarim_app/features/sales/presentation/pages/completed_sales_page.dart';
import 'package:tasarim_app/features/sales/presentation/pages/sale_add_page.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/pages/approval_workflows_page.dart';
import 'package:tasarim_app/features/sales/presentation/pages/workflow_create_page.dart';
import 'package:tasarim_app/features/sales/presentation/pages/sale_detail_page.dart';
import 'package:tasarim_app/features/sales/presentation/pages/shipped_sale_detail_page.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/carrier_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/pages/carrier_add_page.dart';
import 'package:tasarim_app/features/sales/presentation/pages/shipment_add_page.dart';
import 'package:tasarim_app/features/sales/domain/entities/carrier_entity.dart';
import 'package:tasarim_app/features/sales/domain/entities/sale_entity.dart';

// Devices
import '../../features/devices/domain/entities/device_entity.dart';
import '../../features/devices/presentation/bloc/device_bloc.dart';
import '../../features/devices/presentation/pages/device_list_page.dart';
import '../../features/devices/presentation/pages/device_detail_page.dart';
import '../../features/devices/presentation/pages/device_add_page.dart';
import '../../features/devices/presentation/pages/device_bulk_add_page.dart';
import '../../features/devices/presentation/pages/device_models_page.dart';
import '../../features/devices/presentation/pages/device_model_add_page.dart';
import '../../features/devices/presentation/pages/suppliers_page.dart';
import '../../features/devices/presentation/pages/supplier_detail_page.dart';
import '../../features/devices/presentation/pages/supplier_add_page.dart';
import '../../features/devices/domain/entities/supplier_entity.dart';
import '../../features/devices/domain/entities/device_type_entity.dart';
import '../../features/devices/presentation/bloc/device_type_bloc.dart';
import '../../features/devices/presentation/bloc/supplier_bloc.dart';
import '../../features/devices/presentation/pages/device_edit_page.dart';
import '../../features/devices/presentation/pages/device_return_page.dart';
import '../../features/devices/presentation/pages/depot_devices_page.dart';
import '../../features/devices/presentation/pages/depot_backup_devices_page.dart';
import '../../features/devices/presentation/pages/assigned_backup_devices_page.dart';
import '../../features/devices/presentation/pages/backup_assignment_assign_page.dart';

// Customers
import '../../features/customers/presentation/pages/customer_list_page.dart';
import '../../features/customers/presentation/pages/customer_add_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_edit_page.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';
import '../../features/customers/domain/entities/customer_entity.dart';

// Reporting
import '../../features/reporting/presentation/pages/customer_reports_page.dart';
import '../../features/reporting/presentation/pages/device_reports_page.dart';
import '../../features/reporting/presentation/pages/sales_reports_page.dart';
import '../../features/reporting/presentation/pages/user_reports_page.dart';

// Helpers
import '../../features/sales/presentation/pages/carrier_management_page.dart';
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
  static const String pendingUser = '/pending-user';

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
  static const String partiallyShippedSales = '/partially-shipped-sales';
  static const String approvalWorkflows = '/approval-workflows';
  static const String workflowCreate = '/workflow-create';
  static const String shippedSales = '/sales/shipped';
  static const String deliveredSales = '/sales/delivered';
  static const String completedSales = '/sales/completed';
  static const String saleAdd = '/sales/add';
  static const String saleDetail = '/sales/detail';
  static const String shippedSaleDetail = '/sales/shipped-detail';
  static const String saleShip = '/sales/ship';

  // Device routes
  static const String deviceList = '/devices/list';
  static const String deviceDetail = '/devices/detail';
  static const String deviceAdd = '/devices/add';
  static const String deviceBulkAdd = '/devices/bulk-add';
  static const String deviceModels = '/devices/models';
  static const String deviceModelAdd = '/devices/models/add';
  static const String suppliers = '/devices/suppliers';
  static const String supplierDetail = '/devices/suppliers/detail';
  static const String supplierAdd = '/devices/suppliers/add';
  static const String deviceEdit = '/devices/edit';
  static const String deviceReturn = '/devices/return';
  static const String depotDevices = '/devices/depot';
  static const String depotBackupDevices = '/devices/depot-backup';
  static const String assignedBackupDevices = '/devices/assigned-backup';
  static const String backupAssignmentAssign = '/devices/backup-assign';

  // Customer routes
  static const String customerList = '/customers/list';
  static const String customerAdd = '/customers/add';
  static const String customerDetail = '/customers/detail';
  static const String customerEdit = '/customers/edit';

  // Reporting routes
  static const String customerReports = '/reports/customers';
  static const String deviceReports = '/reports/devices';
  static const String salesReports = '/reports/sales';
  static const String userReports = '/reports/users';

  // Helper routes
  static const String carrierManagement = '/carrier-management';
  static const String carrierAdd = '/carrier/add';
  static const String supplierManagement = '/supplier-management';
  static const String technicalService = '/technical-service';

  // Technical Service routes
  static const String servicePreRegistrations =
      '/technical-service/pre-registrations';
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
          builder: (_) => const SplashPage(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<HomeBloc>()..add(const LoadUserInfo()),
            child: const HomePage(),
          ),
        );

      case pendingUser:
        return MaterialPageRoute(builder: (_) => const PendingUserPage());

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
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: const PendingSalesPage(),
          ),
        );

      case approvedSales:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: const ApprovedSalesPage(),
          ),
        );

      case rejectedSales:
        return MaterialPageRoute(builder: (_) => const RejectedSalesPage());

      case partiallyShippedSales:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: const PartiallyShippedSalesPage(),
          ),
        );

      case shippedSales:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: const ShippedSalesPage(),
          ),
        );

      case deliveredSales:
        return MaterialPageRoute(builder: (_) => const DeliveredSalesPage());

      case saleAdd:
        final initialDevice = settings.arguments as DeviceEntity?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: SaleAddPage(initialDevice: initialDevice),
          ),
        );

      case completedSales:
        return MaterialPageRoute(builder: (_) => const CompletedSalesPage());

      case saleDetail:
        final sale = settings.arguments as SaleEntity;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: SaleDetailPage(sale: sale),
          ),
        );
      case saleShip:
        final sale = settings.arguments as SaleEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: ShipmentAddPage(sale: sale),
          ),
        );

      case shippedSaleDetail:
        final sale = settings.arguments as SaleEntity;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => getIt<SaleBloc>(),
            child: ShippedSaleDetailPage(sale: sale),
          ),
        );

      // Devices
      case deviceList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: const DeviceListPage(),
          ),
        );

      case deviceAdd:
        final isBackup = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: DeviceAddPage(isBackup: isBackup),
          ),
        );

      case deviceBulkAdd:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: const DeviceBulkAddPage(),
          ),
        );

      case deviceModels:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceTypeBloc>(),
            child: const DeviceModelsPage(),
          ),
        );

      case deviceModelAdd:
        final deviceModel = settings.arguments as DeviceTypeEntity?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceTypeBloc>(),
            child: DeviceModelAddPage(deviceModel: deviceModel),
          ),
        );

      case suppliers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SupplierBloc>(),
            child: const SuppliersPage(),
          ),
        );

      case supplierAdd:
        final supplierParams = settings.arguments as SupplierEntity?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SupplierBloc>(),
            child: SupplierAddPage(supplier: supplierParams),
          ),
        );

      case supplierDetail:
        final supplier = settings.arguments as SupplierEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SupplierBloc>(),
            child: SupplierDetailPage(supplier: supplier),
          ),
        );

      case deviceDetail:
        final device = settings.arguments as DeviceEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: DeviceDetailPage(device: device),
          ),
        );

      case deviceEdit:
        final device = settings.arguments as DeviceEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: DeviceEditPage(device: device),
          ),
        );

      case deviceReturn:
        return MaterialPageRoute(builder: (_) => const DeviceReturnPage());

      case depotDevices:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: const DepotDevicesPage(),
          ),
        );

      case depotBackupDevices:
        return MaterialPageRoute(
            builder: (_) => const DepotBackupDevicesPage());

      case assignedBackupDevices:
        return MaterialPageRoute(
            builder: (_) => const AssignedBackupDevicesPage());

      case backupAssignmentAssign:
        final device = settings.arguments as DeviceEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeviceBloc>(),
            child: BackupAssignmentAssignPage(device: device),
          ),
        );

      // Customers
      case customerList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CustomerBloc>(),
            child: const CustomerListPage(),
          ),
        );

      case customerAdd:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CustomerBloc>(),
            child: const CustomerAddPage(),
          ),
        );

      case customerDetail:
        final customerId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CustomerBloc>(),
            child: CustomerDetailPage(customerId: customerId),
          ),
        );

      case customerEdit:
        final customer = settings.arguments as CustomerEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CustomerBloc>(),
            child: CustomerEditPage(customer: customer),
          ),
        );

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
          builder: (_) => BlocProvider(
            create: (_) => getIt<CarrierBloc>(),
            child: const CarrierManagementPage(),
          ),
        );
      case carrierAdd:
        final carrier = settings.arguments as CarrierEntity?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CarrierBloc>(),
            child: CarrierAddPage(carrier: carrier),
          ),
        );

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
        return MaterialPageRoute(builder: (_) => const ApprovalMechanismPage());

      case usersManagement:
        return MaterialPageRoute(builder: (_) => const UsersManagementPage());

      case logging:
        return MaterialPageRoute(builder: (_) => const LoggingPage());

      case approvalWorkflows:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ApprovalBloc>(),
            child: const ApprovalWorkflowsPage(),
          ),
        );

      case workflowCreate:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ApprovalBloc>(),
            child: const WorkflowCreatePage(),
          ),
        );

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
