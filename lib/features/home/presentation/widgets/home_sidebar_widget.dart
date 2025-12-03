import 'package:flutter/material.dart';
import '../../../../config/routes/app_router.dart';

class HomeSidebarWidget extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onLogout;
  final String userRole;
  final String userName;
  final Map<String, bool> expandedMenus;
  final Function(String) onMenuToggle;
  final Function(String) onPageSelect;

  const HomeSidebarWidget({
    super.key,
    required this.currentRoute,
    required this.onLogout,
    required this.userRole,
    required this.userName,
    required this.expandedMenus,
    required this.onMenuToggle,
    required this.onPageSelect,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.only(top: statusBarHeight),
      children: _getMenuItems(context),
    );
  }

  List<Widget> _getMenuItems(BuildContext context) {
    final items = <Widget>[];

    // Rol kontrolü için normalize edilmiş rol
    // TEST: Geçici olarak her zaman admin olarak işaretle
    final normalizedRole = 'admin'; // userRole.toLowerCase().trim();

    // Header/Logo
    items.add(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child:Image.asset(
              'assets/images/narposloginlogo.png',
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.admin_panel_settings,
                    size: 50, color: Color(0xFFF57C00));
              },
        ),
      ),
    );

    // 🏠 Dashboard
    items.add(
      _buildMenuItem(
        context: context,
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        route: AppRouter.home,
      ),
    );

    // 📱 Cihazlar (devices)
    items.add(
      _buildExpandableMenuItem(
        context: context,
        icon: Icons.devices_other_outlined,
        title: 'Cihazlar',
        menuKey: 'devices',
        children: [
          _buildSubMenuItem(
            context: context,
            icon: Icons.list,
            title: 'Tüm Cihazlar',
            route: AppRouter.deviceList,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.warehouse_outlined,
            title: 'Depodaki Cihazlar',
            route: AppRouter.depotDevices,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.backup_outlined,
            title: 'Yedek Cihazlar',
            route: AppRouter.depotBackupDevices,
          ),
        ],
      ),
    );

    // 💰 Satışlar (sales)
    items.add(
      _buildExpandableMenuItem(
        context: context,
        icon: Icons.shopping_cart_outlined,
        title: 'Satışlar',
        menuKey: 'sales',
        children: [
          _buildSubMenuItem(
            context: context,
            icon: Icons.hourglass_empty,
            title: 'Onay Bekleyen Satışlar',
            route: AppRouter.pendingSales,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.local_shipping,
            title: 'Kargolanan Satışlar',
            route: AppRouter.shippedSales,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.inventory_2,
            title: 'Teslim Edilen Satışlar',
            route: AppRouter.deliveredSales,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.done_all,
            title: 'Tamamlanan Satışlar',
            route: AppRouter.completedSales,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.cancel_outlined,
            title: 'Reddedilen Satışlar',
            route: AppRouter.rejectedSales,
          ),
          // Sadece admin görebilir
          if (normalizedRole == 'admin')
            _buildSubMenuItem(
              context: context,
              icon: Icons.approval,
              title: 'Onay Adımları',
              route: AppRouter.approvalMechanism,
            ),
        ],
      ),
    );

    // 📦 Satış Kargolama (shipments)
    items.add(
      _buildExpandableMenuItem(
        context: context,
        icon: Icons.local_shipping_outlined,
        title: 'Satış Kargolama',
        menuKey: 'shipments',
        children: [
          _buildSubMenuItem(
            context: context,
            icon: Icons.pending_actions,
            title: 'Kargolama Bekleyen Satışlar',
            route: AppRouter.approvedSales,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.inventory,
            title: 'Kısmi Kargolanan Satışlar',
            route: AppRouter.partiallyShippedSales,
          ),
        ],
      ),
    );

    // 🔧 Teknik Servis Kaydı (technicalservice)
    items.add(
      _buildExpandableMenuItem(
        context: context,
        icon: Icons.build_outlined,
        title: 'Teknik Servis Kaydı',
        menuKey: 'technicalservice',
        children: [
          _buildSubMenuItem(
            context: context,
            icon: Icons.app_registration,
            title: 'Servis Ön Kayıtları',
            route: AppRouter.servicePreRegistrations,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.pending_actions,
            title: 'Devam Eden İşlemler',
            route: AppRouter.serviceOngoing,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.fact_check,
            title: 'Son Kontroller',
            route: AppRouter.serviceFinalChecks,
          ),
          _buildSubMenuItem(
            context: context,
            icon: Icons.check_circle,
            title: 'Tamamlanan İşlemler',
            route: AppRouter.serviceCompleted,
          ),
        ],
      ),
    );

    // 🗺️ Saha Yönetimi (fieldmanagement) - Sadece admin
    if (normalizedRole == 'admin') {
      items.add(
        _buildExpandableMenuItem(
          context: context,
          icon: Icons.map_outlined,
          title: 'Saha Yönetimi',
          menuKey: 'fieldmanagement',
          children: [
            _buildSubMenuItem(
              context: context,
              icon: Icons.pending_actions,
              title: 'Bekleyen Görevler',
              route: AppRouter.pendingTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.task_alt,
              title: 'Kabul Edilen',
              route: AppRouter.acceptedTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.autorenew,
              title: 'Devam Eden Görevler',
              route: AppRouter.ongoingTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.check_circle,
              title: 'Tamamlanan Görevler',
              route: AppRouter.completedTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.cancel,
              title: 'Reddedilen Görevler',
              route: AppRouter.cancelledTasks,
            ),
          ],
        ),
      );
    }

    // 📋 Saha Görevleri (fieldtasks) - Sadece fielder rolü
    if (normalizedRole == 'fielder') {
      items.add(
        _buildExpandableMenuItem(
          context: context,
          icon: Icons.assignment_outlined,
          title: 'Saha Görevleri',
          menuKey: 'fieldtasks',
          children: [
            _buildSubMenuItem(
              context: context,
              icon: Icons.assignment,
              title: 'Atanan Görevlerim',
              route: AppRouter.myAssignedTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.thumb_up,
              title: 'Kabul Edilen Görevlerim',
              route: AppRouter.myAcceptedTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.loop,
              title: 'Devam Eden Görevlerim',
              route: AppRouter.myOngoingTasks,
            ),
            _buildSubMenuItem(
              context: context,
              icon: Icons.done_all,
              title: 'Tamamlanan Görevlerim',
              route: AppRouter.myCompletedTasks,
            ),
          ],
        ),
      );
    }

    // 🏢 Müşteriler - Admin ve stock manager
    if (normalizedRole == 'admin' || normalizedRole == 'stock_manager') {
      items.add(
        _buildMenuItem(
          context: context,
          icon: Icons.people_outline,
          title: 'Müşteriler',
          route: AppRouter.customerList,
        ),
      );
    }

    // 📊 Raporlama - Sadece admin
    if (normalizedRole == 'admin') {
      items.add(
        _buildMenuItem(
          context: context,
          icon: Icons.assessment_outlined,
          title: 'Raporlama',
          route: AppRouter.customerReports,
        ),
      );
    }

    // 📝 Loglama - Sadece admin
    if (normalizedRole == 'admin') {
      items.add(
        _buildMenuItem(
          context: context,
          icon: Icons.article_outlined,
          title: 'Loglama',
          route: AppRouter.logging,
        ),
      );
    }

    // 👤 Kullanıcılar - Sadece admin
    if (normalizedRole == 'admin') {
      items.add(
        _buildMenuItem(
          context: context,
          icon: Icons.person_outline,
          title: 'Kullanıcılar',
          route: AppRouter.usersManagement,
        ),
      );
    }

    return items;
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF57C00).withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        selected: isActive,
        selectedTileColor: const Color(0xFFF57C00).withValues(alpha: 0.1),
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFFF57C00) : Colors.black87,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFFF57C00) : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          onPageSelect(route);
          Navigator.of(context).pop(); // Close drawer
        },
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String menuKey,
    required List<Widget> children,
  }) {
    final isExpanded = expandedMenus[menuKey] ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_more : Icons.chevron_right,
            color: Colors.black54,
          ),
          onTap: () {
            // Toggle menu expansion - DRAWER KAPANMAZ
            onMenuToggle(menuKey);
          },
        ),
        // Conditional submenu rendering
        if (isExpanded) ...children,
      ],
    );
  }

  Widget _buildSubMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFFF57C00) : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFFF57C00) : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {
          onPageSelect(route);
          Navigator.of(context).pop(); // Close drawer
        },
      ),
    );
  }
}
