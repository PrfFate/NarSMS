import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../pages/profile_page.dart';

class _BottomNavDestination {
  final IconData icon;
  final String label;
  final String? route;
  final bool opensProfile;
  final String? comingSoonMessage;

  const _BottomNavDestination({
    required this.icon,
    required this.label,
    this.route,
    this.opensProfile = false,
    this.comingSoonMessage,
  });
}

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final String userName;
  final String userRole;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    const destinations = [
      _BottomNavDestination(
        icon: Icons.home_outlined,
        label: 'Ana Sayfa',
        route: AppRouter.home,
      ),
      _BottomNavDestination(
        icon: Icons.search_outlined,
        label: 'Arama',
        comingSoonMessage: 'Arama özelliği yakında eklenecek',
      ),
      _BottomNavDestination(
        icon: Icons.notifications_outlined,
        label: 'Bildirimler',
        comingSoonMessage: 'Bildirimler yakında eklenecek',
      ),
      _BottomNavDestination(
        icon: Icons.person_outline,
        label: 'Profil',
        opensProfile: true,
      ),
    ];
    final effectiveSelectedIndex =
        selectedIndex == 3 || selectedIndex >= destinations.length
            ? 0
            : selectedIndex;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            _buildNavItem(
              context,
              destinations[index],
              index,
              effectiveSelectedIndex,
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    _BottomNavDestination destination,
    int index,
    int effectiveSelectedIndex,
  ) {
    final isSelected = effectiveSelectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context, destination, index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                destination.icon,
                color: isSelected ? AppColors.accentDark : AppColors.textHint,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                style: TextStyle(
                  color: isSelected ? AppColors.accentDark : AppColors.textHint,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    _BottomNavDestination destination,
    int index,
  ) async {
    final homeBloc = context.read<HomeBloc>();

    if (destination.opensProfile) {
      onIndexChanged(0);
      homeBloc.add(const ChangeNavigation(0));
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: homeBloc,
            child: ProfilePage(
              userName: userName,
              userRole: userRole,
            ),
          ),
        ),
      );
      if (context.mounted) {
        onIndexChanged(0);
        homeBloc.add(const ChangeNavigation(0));
      }
      return;
    }

    if (destination.comingSoonMessage != null) {
      onIndexChanged(0);
      homeBloc.add(const ChangeNavigation(0));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(destination.comingSoonMessage!)),
      );
      return;
    }

    final route = destination.route;
    if (route == null) return;

    onIndexChanged(index);
    homeBloc.add(SelectPage(route));
  }
}
