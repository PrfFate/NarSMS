import 'package:flutter/material.dart';

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

    // Dashboard - Seçili durum
    items.add(
      _buildMenuItem(
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        route: '/dashboard',
        isSelected: true,
      ),
    );

    // Cihazlar - Alt Menülü
    items.add(
      _buildExpandableMenuItem(
        icon: Icons.devices_other_outlined,
        title: 'Cihazlar',
        route: '/devices',
        children: [
          _buildSubMenuItem(
              icon: Icons.list, title: 'Tüm Cihazlar', route: '/devices/all'),
          _buildSubMenuItem(
              icon: Icons.warehouse_outlined,
              title: 'Depodaki Cihazlar',
              route: '/devices/warehouse'),
          _buildSubMenuItem(
              icon: Icons.backup_outlined,
              title: 'Yedek Cihazlar',
              route: '/devices/backup'),
        ],
      ),
    );

    // Müşteriler
    items.add(
      _buildMenuItem(
        icon: Icons.people_outline,
        title: 'Müşteriler',
        route: '/customers',
      ),
    );

    // Satışlar
    items.add(
      _buildMenuItem(
        icon: Icons.shopping_cart_outlined,
        title: 'Satışlar',
        route: '/sales',
      ),
    );

    // Kargo
    items.add(
      _buildMenuItem(
        icon: Icons.local_shipping_outlined,
        title: 'Kargo',
        route: '/cargo',
      ),
    );

    // Teknik Servis Kartı
    items.add(
      _buildMenuItem(
        icon: Icons.build_outlined,
        title: 'Teknik Servis Kaydı',
        route: '/service',
      ),
    );

    // Raporlama
    items.add(
      _buildMenuItem(
        icon: Icons.assessment_outlined,
        title: 'Raporlama',
        route: '/reports',
      ),
    );

    // Loglama
    items.add(
      _buildMenuItem(
        icon: Icons.article_outlined,
        title: 'Loglama',
        route: '/logs',
      ),
    );

    // Kullanıcılar - Sadece Admin için
    if (widget.userRole == 'Admin') {
      items.add(
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Kullanıcılar',
          route: '/users',
        ),
      );
    }

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
              // TODO: Navigasyon
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
          // TODO: Navigasyon
        },
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required String route,
    required List<Widget> children,
  }) {
    final isActive = widget.currentRoute.startsWith(route);
    final isExpanded = widget.expandedMenuItem == route;

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
              // TODO: Navigasyon
            },
            dense: true,
          ),
        ),
      );
    }

    return ExpansionTile(
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
      trailing: Icon(
        isExpanded ? Icons.expand_more : Icons.chevron_right,
        color: Colors.black54,
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        widget.onExpandMenuItem(expanded ? route : null);
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
          // TODO: Navigasyon
        },
      ),
    );
  }
}
