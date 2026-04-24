import 'role_utils.dart';

class RoleAccessPolicy {
  const RoleAccessPolicy._();

  static const String _home = '/home';
  static const String _pendingUser = '/pending-user';
  static const String _fielderDashboard = '/fielder-dashboard';

  static String initialRouteForRole(String? roleName) {
    final role = normalizeRole(roleName);
    if (role == 'pendinguser' || role == 'pending') {
      return _pendingUser;
    }
    if (isFielderRole(role)) {
      return _fielderDashboard;
    }
    return _home;
  }

  static bool canSeeDevices(String? role) => !isFielderRole(role);
  static bool canSeeShipments(String? role) => !isFielderRole(role);
  static bool canSeeTechnicalService(String? role) => !isFielderRole(role);
  static bool canSeeFieldTasks(String? role) => isFielderRole(role);
  static bool canSeeFieldManagement(String? role) => isAdminRole(role);

  static bool canSeeCustomers(String? role) {
    final normalized = normalizeRole(role);
    return isAdminRole(role) || normalized == 'stock_manager';
  }

  static bool canSeeAdminModules(String? role) => isAdminRole(role);

  static bool canCreateSale(String? role) => !isFielderRole(role);
  static bool canShipSale(String? role) => !isFielderRole(role);
  static bool canApproveOrRejectSale(String? role) => !isFielderRole(role);
  static bool canConfirmShipmentDelivery(String? role) => !isFielderRole(role);
  static bool canManageSaleReturns(String? role) => !isFielderRole(role);

  static bool isRouteAllowedInHome({
    required String route,
    required String? role,
  }) {
    if (!isFielderRole(role)) {
      return true;
    }

    return _fielderHomeRoutes.contains(route);
  }

  static const Set<String> _fielderHomeRoutes = {
    '/home',
    '/sales/pending',
    '/sales/shipped',
    '/sales/delivered',
    '/sales/completed',
    '/sales/rejected',
    '/field-tasks/my-assigned-tasks',
    '/field-tasks/my-accepted-tasks',
    '/field-tasks/my-ongoing-tasks',
    '/field-tasks/my-completed-tasks',
  };
}
