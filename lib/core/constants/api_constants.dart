import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.get('API_BASE_URL');
  static const String apiVersion = '/api';
  static String get roleChangeHubUrl =>
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/roleChangeHub';
  static String get dashboardHubUrl =>
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/dashboardHub';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh-token';
  static const String logout = '$apiVersion/auth/logout';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';

  // Customer endpoints
  static const String customerPaged = '$apiVersion/Customer/paged';
  static const String customerSearch = '$apiVersion/Customer/search';
  static String customerById(int id) => '$apiVersion/Customer/$id';
  static String customerByUniqueId(String uniqueId) =>
      '$apiVersion/Customer/unique/$uniqueId';
  static String customerDevices(int id) => '$apiVersion/Customer/$id/devices';
  static const String customerCreate = '$apiVersion/Customer';
  static String customerUpdate(int id) => '$apiVersion/Customer/$id';
  static String customerDelete(int id) => '$apiVersion/Customer/$id';
  static const String customerBulk = '$apiVersion/Customer/bulk';

  // Device endpoints
  static const String devicePaged = '$apiVersion/Device/paged';
  static const String deviceSearch = '$apiVersion/Device/search';
  static const String deviceFilterSearch =
      '$apiVersion/Device/search-by-multiple-features';
  static const String deviceMovementsPaged = '$apiVersion/Device/movements';
  static String deviceById(int id) => '$apiVersion/Device/$id';
  static const String deviceCreate = '$apiVersion/Device';
  static String deviceUpdate(int id) => '$apiVersion/Device/$id';
  static String deviceDelete(int id) => '$apiVersion/Device/$id';
  static const String deviceBulkCreate = '$apiVersion/Device/bulk-create';

  // Backup Assignment endpoints
  static const String backupAssignmentSearch =
      '$apiVersion/BackupAssignment/search';

  // Device Type and Supplier API Endpoints
  static const String deviceTypes = '$apiVersion/devicetype';
  static const String suppliers = '$apiVersion/Supplier';
  static String deviceMovements(int id) => '$apiVersion/Device/$id/movements';

  // Sale endpoints
  static const String saleCreate = '$apiVersion/Sale';
  static const String saleSearch = '$apiVersion/sale/search';
  static String saleApprove(int id) => '$apiVersion/Sale/$id/approve';
  static String saleReject(int id) => '$apiVersion/Sale/$id/reject';

  // Return endpoints
  static const String returnCreateAndComplete =
      '$apiVersion/Return/create-and-complete';

  // Shipment endpoints
  static String shipmentById(int id) => '$apiVersion/Shipment/$id';
  static String shipmentBySaleId(int saleId) =>
      '$apiVersion/shipment/sale/$saleId';
  static const String shipmentCreate = '$apiVersion/Shipment/sale';
  static const String serviceRequestShipment =
      '$apiVersion/Shipment/service-request';

  // Carrier endpoints
  static const String carrierAll = '$apiVersion/Carrier';
  static String carrierById(int id) => '$apiVersion/Carrier/$id';
  static const String carrierCreate = '$apiVersion/Carrier';
  static String carrierUpdate(int id) => '$apiVersion/Carrier/$id';
  static String carrierDelete(int id) => '$apiVersion/Carrier/$id';

  // User endpoints
  static const String userPaged = '$apiVersion/User/paged';
  static const String userSearch = '$apiVersion/User/search';
  static String userById(int id) => '$apiVersion/User/$id';
  static String shipmentMarkDelivered(int id) =>
      '$apiVersion/Shipment/$id/mark-delivered';

  static String usersByRole(String role) =>
      '$apiVersion/User/byrolename/${Uri.encodeComponent(role)}';
  static String get userByRoleFielder => usersByRole('Fielder');

  // Role endpoints
  static const String role = '$apiVersion/Role';

  // Approval Workflow endpoints
  static const String approvalWorkflow = '$apiVersion/ApprovalWorkflow';
  static String approvalWorkflowById(int id) =>
      '$apiVersion/ApprovalWorkflow/$id';
  static String approvalWorkflowActivate(int id) =>
      '$apiVersion/ApprovalWorkflow/$id/activate';
  static String approvalWorkflowDeactivate(int id) =>
      '$apiVersion/ApprovalWorkflow/$id/deactivate';

  static String deviceActiveWarranty(int deviceId) =>
      '$apiVersion/Warranty/device/$deviceId/active';

  // Service Request endpoints
  static const String serviceRequestPaged = '$apiVersion/ServiceRequest/paged';
  static const String serviceRequestCreate = '$apiVersion/ServiceRequest';

  // Task Type endpoints
  static const String taskTypes = '$apiVersion/task-types';
  static const String taskTypesAll = '$apiVersion/task-types/all';
  static String taskTypeById(int id) => '$apiVersion/task-types/$id';

  // Dashboard endpoints
  static const String dashboardInventory =
      '$apiVersion/Dashboard/kpi/inventory';

  // Field task endpoints
  static const String fieldTasks = '$apiVersion/field-tasks';
  static const String fieldTasksMyTasks = '$apiVersion/field-tasks/my-tasks';
  static String fieldTaskAccept(int id) => '$apiVersion/field-tasks/$id/accept';
}
