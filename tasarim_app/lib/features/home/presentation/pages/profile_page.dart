import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

// Settings item model
class _SettingItem {
  final String id;
  final IconData icon;
  final String title;
  final bool isDestructive;

  const _SettingItem({
    required this.id,
    required this.icon,
    required this.title,
    this.isDestructive = false,
  });
}

class ProfilePage extends StatelessWidget {
  final String userName;
  final String userRole;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  // Settings items list - Single source of truth
  static const List<_SettingItem> _settingsItems = [
    _SettingItem(
      id: 'edit_profile',
      icon: Icons.person_outline,
      title: 'Profili Düzenle',
    ),
    _SettingItem(
      id: 'change_password',
      icon: Icons.lock_outline,
      title: 'Şifre Değiştir',
    ),
    _SettingItem(
      id: 'privacy',
      icon: Icons.security_outlined,
      title: 'Gizlilik ve Güvenlik',
    ),
    _SettingItem(
      id: 'language',
      icon: Icons.language_outlined,
      title: 'Dil',
    ),
    _SettingItem(
      id: 'help',
      icon: Icons.help_outline,
      title: 'Yardım ve Destek',
    ),
    _SettingItem(
      id: 'about',
      icon: Icons.info_outline,
      title: 'Hakkında',
    ),
    _SettingItem(
      id: 'logout',
      icon: Icons.exit_to_app,
      title: 'Çıkış Yap',
      isDestructive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.login,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Profil',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
        children: [
          _buildProfileHeader(),
          // Ayarlar Listesi
          Expanded(
            child: ListView.separated(
              itemCount: _settingsItems.length,
              separatorBuilder: (context, index) => _buildDivider(),
              itemBuilder: (context, index) {
                final item = _settingsItems[index];
                return _buildSettingItem(
                  context,
                  icon: item.icon,
                  title: item.title,
                  onTap: () => _handleSettingTap(context, item.id),
                  isDestructive: item.isDestructive,
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Single handler for all settings actions - SRP principle
  void _handleSettingTap(BuildContext context, String settingId) {
    switch (settingId) {
      case 'logout':
        _showLogoutDialog(context);
        break;
      case 'edit_profile':
        _showComingSoonMessage(context, 'Profil düzenleme yakında eklenecek');
        break;
      case 'change_password':
        _showComingSoonMessage(context, 'Şifre değiştirme yakında eklenecek');
        break;
      case 'privacy':
        _showComingSoonMessage(context, 'Gizlilik ayarları yakında eklenecek');
        break;
      case 'language':
        _showComingSoonMessage(context, 'Dil ayarları yakında eklenecek');
        break;
      case 'help':
        _showComingSoonMessage(context, 'Yardım sayfası yakında eklenecek');
        break;
      case 'about':
        _showComingSoonMessage(context, 'Hakkında sayfası yakında eklenecek');
        break;
    }
  }

  // Reusable method for coming soon messages - DRY principle
  void _showComingSoonMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Profile header widget - extracted for reusability
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 16),
          _buildUserInfo(),
        ],
      ),
    );
  }

  // Profile avatar widget - extracted for clarity
  Widget _buildProfileAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF57C00),
            Color(0xFFF34723),
            Color(0xFFF57C00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            size: 42,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  // User info widget - extracted for clarity
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          userName.isNotEmpty ? userName : 'User001',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userRole.isNotEmpty ? userRole : 'Bekleyen Kullanıcı',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[200],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // BLoC'u daha güvenli şekilde al - try-catch ile
    HomeBloc? homeBloc;
    try {
      homeBloc = context.read<HomeBloc>();
    } catch (e) {
      print('HomeBloc bulunamadı: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış işlemi başarısız oldu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Çıkış Yap',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'İptal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (homeBloc != null) {
                  homeBloc.add(const LogoutRequested());
                }
              },
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
