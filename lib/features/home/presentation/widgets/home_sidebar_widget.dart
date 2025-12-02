import 'package:flutter/material.dart';
import '../../../../config/routes/app_router.dart';

class HomeSidebarWidget extends StatefulWidget {
  final bool isCollapsed;
  final String currentRoute;
  final VoidCallback onLogout;
  final String userRole;
  final String userName;
  final String? expandedMenuItem;
  final Function(String?) onExpandMenuItem;

  const HomeSidebarWidget({
    super.key,
    required this.isCollapsed,
    required this.currentRoute,
    required this.onLogout,
    required this.userRole,
    required this.userName,
    this.expandedMenuItem,
    required this.onExpandMenuItem,
  });

  @override
  State<HomeSidebarWidget> createState() => _HomeSidebarWidgetState();
}

class _HomeSidebarWidgetState extends State<HomeSidebarWidget> {
  List<Widget> _getMenuItems() {
    final items = <Widget>[];

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
        child: widget.isCollapsed
            ? Image.asset(
                'assets/images/narposloginlogo.png',
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.admin_panel_settings,
                      size: 30, color: Color(0xFFF57C00));
                },
              )
            : Image.asset(
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
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        route: AppRouter.home,
      ),
    );

    // 📱 Cihazlar (devices)
    items.add(
      _buildExpandableMenuItem(
        icon: Icons.devices_other_outlined,
        title: 'Cihazlar',
        menuKey: 'devices',
        children: [
          _buildSubMenuItem(
            icon: Icons.list,
            title: 'Tüm Cihazlar',
            route: AppRouter.deviceList,
          ),
          _buildSubMenuItem(
            icon: Icons.warehouse_outlined,
            title: 'Depodaki Cihazlar',
            route: AppRouter.depotDevices,
          ),
          _buildSubMenuItem(
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
        icon: Icons.shopping_cart_outlined,
        title: 'Satışlar',
        menuKey: 'sales',
        children: [
          _buildSubMenuItem(
            icon: Icons.hourglass_empty,
            title: 'Onay Bekleyen Satışlar',
            route: AppRouter.pendingSales,
          ),
          _buildSubMenuItem(
            icon: Icons.local_shipping,
            title: 'Kargolanan Satışlar',
            route: AppRouter.shippedSales,
          ),
          _buildSubMenuItem(
            icon: Icons.inventory_2,
            title: 'Teslim Edilen Satışlar',
            route: AppRouter.deliveredSales,
          ),
          _buildSubMenuItem(
            icon: Icons.done_all,
            title: 'Tamamlanan Satışlar',
            route: AppRouter.completedSales,
          ),
          _buildSubMenuItem(
            icon: Icons.cancel_outlined,
            title: 'Reddedilen Satışlar',
            route: AppRouter.rejectedSales,
          ),
          // Sadece admin görebilir
          if (widget.userRole.toLowerCase() == 'admin')
            _buildSubMenuItem(
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
        icon: Icons.local_shipping_outlined,
        title: 'Satış Kargolama',
        menuKey: 'shipments',
        children: [
          _buildSubMenuItem(
            icon: Icons.pending_actions,
            title: 'Kargolama Bekleyen Satışlar',
            route: AppRouter.approvedSales,
          ),
          _buildSubMenuItem(
            icon: Icons.inventory,
            title: 'Kısmi Kargolanan Satışlar',
            route: AppRouter.partiallyShippedSales,
          ),
        ],
      ),
    );

    // 🔧 Teknik Servis Kaydı (technicianservice)
    items.add(
      _buildExpandableMenuItem(
        icon: Icons.build_outlined,
        title: 'Teknik Servis Kaydı',
        menuKey: 'technicalservice',
        children: [
          _buildSubMenuItem(
            icon: Icons.app_registration,
            title: 'Servis Ön Kayıtları',
            route: AppRouter.servicePreRegistrations,
          ),
          _buildSubMenuItem(
            icon: Icons.pending_actions,
            title: 'Devam Eden İşlemler',
            route: AppRouter.serviceOngoing,
          ),
          _buildSubMenuItem(
            icon: Icons.fact_check,
            title: 'Son Kontroller',
            route: AppRouter.serviceFinalChecks,
          ),
          _buildSubMenuItem(
            icon: Icons.check_circle,
            title: 'Tamamlanan İşlemler',
            route: AppRouter.serviceCompleted,
          ),
        ],
      ),
    );

    // 🗺️ Saha Yönetimi (fieldmanagement) - Sadece admin
    if (widget.userRole.toLowerCase() == 'admin') {
      items.add(
        _buildExpandableMenuItem(
          icon: Icons.map_outlined,
          title: 'Saha Yönetimi',
          menuKey: 'fieldmanagement',
          children: [
            _buildSubMenuItem(
              icon: Icons.pending_actions,
              title: 'Bekleyen Görevler',
              route: AppRouter.pendingTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.task_alt,
              title: 'Kabul Edilen',
              route: AppRouter.acceptedTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.autorenew,
              title: 'Devam Eden Görevler',
              route: AppRouter.ongoingTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.check_circle,
              title: 'Tamamlanan Görevler',
              route: AppRouter.completedTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.cancel,
              title: 'Reddedilen Görevler',
              route: AppRouter.cancelledTasks,
            ),
          ],
        ),
      );
    }

    // 📋 Saha Görevleri (fieldtasks) - Sadece fielder rolü
    if (widget.userRole.toLowerCase() == 'fielder') {
      items.add(
        _buildExpandableMenuItem(
          icon: Icons.assignment_outlined,
          title: 'Saha Görevleri',
          menuKey: 'fieldtasks',
          children: [
            _buildSubMenuItem(
              icon: Icons.assignment,
              title: 'Atanan Görevlerim',
              route: AppRouter.myAssignedTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.thumb_up,
              title: 'Kabul Edilen Görevlerim',
              route: AppRouter.myAcceptedTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.loop,
              title: 'Devam Eden Görevlerim',
              route: AppRouter.myOngoingTasks,
            ),
            _buildSubMenuItem(
              icon: Icons.done_all,
              title: 'Tamamlanan Görevlerim',
              route: AppRouter.myCompletedTasks,
            ),
          ],
        ),
      );
    }

    // 🏢 Müşteriler - Admin ve stock manager
    if (widget.userRole.toLowerCase() == 'admin' ||
        widget.userRole.toLowerCase() == 'stock_manager') {
      items.add(
        _buildMenuItem(
          icon: Icons.people_outline,
          title: 'Müşteriler',
          route: AppRouter.customerList,
        ),
      );
    }

    // 📊 Raporlama - Sadece admin
    if (widget.userRole.toLowerCase() == 'admin') {
      items.add(
        _buildMenuItem(
          icon: Icons.assessment_outlined,
          title: 'Raporlama',
          route: AppRouter.customerReports,
        ),
      );
    }

    // 📝 Loglama - Sadece admin
    if (widget.userRole.toLowerCase() == 'admin') {
      items.add(
        _buildMenuItem(
          icon: Icons.article_outlined,
          title: 'Loglama',
          route: AppRouter.logging,
        ),
      );
    }

    // 👤 Kullanıcılar - Sadece admin
    if (widget.userRole.toLowerCase() == 'admin') {
      items.add(
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Kullanıcılar',
          route: AppRouter.usersManagement,
        ),
      );
    }

    // ⚙️ Ayarlar
    items.add(
      _buildMenuItem(
        icon: Icons.settings_outlined,
        title: 'Ayarlar',
        route: '/settings',
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _getMenuItems(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
    bool isSelected = false,
  }) {
    final isActive = isSelected || widget.currentRoute == route;

    if (widget.isCollapsed) {
      return Tooltip(
        message: title,
        child: Container(
          decoration: BoxDecoration(
            border: isActive
                ? const Border(
                    left: BorderSide(color: Color(0xFFF34723), width: 4),
                  )
                : null,
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isActive ? const Color(0xFFF34723) : Colors.black87,
            ),
            onTap: () {
              Navigator.pushNamed(context, route);
            },
            dense: true,
          ),
        ),
      );
    }

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
        trailing: isActive ? null : const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required String menuKey,
    required List<Widget> children,
  }) {
    final isExpanded = widget.expandedMenuItem == menuKey;

    if (widget.isCollapsed) {
      return Tooltip(
        message: title,
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          onTap: () {
            // Collapsed modda ilk child'a git
            if (children.isNotEmpty) {
              // İlk child'ı bul ve ona navigate et
            }
          },
          dense: true,
        ),
      );
    }

    return ExpansionTile(
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
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        widget.onExpandMenuItem(expanded ? menuKey : null);
      },
      children: children,
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = widget.currentRoute == route;

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
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
