import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/profile_page.dart';
import '../bloc/home_bloc.dart';

/// Alt navigasyon çubuğu widget'ı.
///
/// Renk ve stil değerleri hardcoded yerine [AppColors] üzerinden alınır;
/// tek bir tema değişikliği ile tüm uygulamayı günceller.
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
          _buildNavItem(context, Icons.home_outlined, 'Ana Sayfa', 0),
          _buildNavItem(context, Icons.search_outlined, 'Arama', 1),
          _buildNavItem(
              context, Icons.notifications_outlined, 'Bildirimler', 3),
          _buildNavItem(context, Icons.person_outline, 'Profil', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onIndexChanged(index);

            if (index == 4) {
              final homeBloc = context.read<HomeBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (newContext) => BlocProvider.value(
                    value: homeBloc,
                    child: ProfilePage(
                      userName: userName,
                      userRole: userRole,
                    ),
                  ),
                ),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.accentDark : AppColors.textHint,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.accentDark : AppColors.textHint,
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
