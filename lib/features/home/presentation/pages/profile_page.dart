import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/auth/role_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/generic_confirmation_dialog.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'change_password_page.dart';
import 'profile_edit_page.dart';

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

  static const _editProfileItem = _SettingItem(
    id: 'edit_profile',
    icon: Icons.person_outline,
    title: 'Profili Düzenle',
  );

  static const List<_SettingItem> _commonSettingsItems = [
    _SettingItem(
      id: 'change_password',
      icon: Icons.lock_outline,
      title: 'Şifre Değiştir',
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
    final settingsItems = [
      if (isAdminRole(userRole)) _editProfileItem,
      ..._commonSettingsItems,
    ];

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
            onPressed: () => Navigator.pop(context),
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
          titleSpacing: 0,
        ),
        body: Column(
          children: [
            _buildProfileHeader(),
            Expanded(
              child: ListView.separated(
                itemCount: settingsItems.length,
                separatorBuilder: (context, index) => _buildDivider(),
                itemBuilder: (context, index) {
                  final item = settingsItems[index];
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

  void _handleSettingTap(BuildContext context, String settingId) {
    switch (settingId) {
      case 'logout':
        _showLogoutDialog(context);
        break;
      case 'edit_profile':
        if (isAdminRole(userRole)) {
          _openWithHomeBloc(
            context,
            ProfileEditPage(fallbackUserName: userName),
          );
        }
        break;
      case 'change_password':
        _openWithHomeBloc(context, const ChangePasswordPage());
        break;
      case 'help':
        _openWithHomeBloc(context, const HelpSupportPage());
        break;
      case 'about':
        _openWithHomeBloc(context, const AboutAppPage());
        break;
    }
  }

  void _openWithHomeBloc(BuildContext context, Widget page) {
    final homeBloc = context.read<HomeBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: homeBloc,
          child: page,
        ),
      ),
    );
  }

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

  Widget _buildProfileAvatar() {
    final initials = _buildInitials(userName);
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.accentDark,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDark.withValues(alpha: 0.26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  String _buildInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    final first = parts.first[0].toUpperCase();
    final last = parts.last[0].toUpperCase();
    return '$first$last';
  }

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
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight:
                      isDestructive ? FontWeight.w600 : FontWeight.normal,
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
    HomeBloc? homeBloc;
    try {
      homeBloc = context.read<HomeBloc>();
    } catch (e) {
      debugPrint('HomeBloc bulunamadı: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış işlemi başarısız oldu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return GenericConfirmationDialog(
          title: 'Çıkış Yap',
          message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          confirmLabel: 'Çıkış Yap',
          cancelLabel: 'İptal',
          accentColor: const Color(0xFFF57C00),
          onConfirm: () {
            homeBloc?.add(const LogoutRequested());
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StaticInfoPage(
      title: 'Yardım ve Destek',
      sections: const [
        _StaticInfoSection(
          icon: Icons.support_agent_outlined,
          title: 'Destek Kanalları',
          body:
              'Uygulama kullanımı, giriş sorunları, yetki talepleri ve işlem hataları için operasyon destek ekibiyle iletişime geçebilirsiniz.\n\n'
              'Telefon: 0542 330 79 95',
        ),
        _StaticInfoSection(
          icon: Icons.schedule_outlined,
          title: 'Çalışma Saatleri',
          body:
              'Hafta içi 09:00 - 18:00 arasında destek talepleri öncelikli olarak yanıtlanır. Acil saha ve teslimat sorunları yöneticinize iletilmelidir.',
        ),
        _StaticInfoSection(
          icon: Icons.rule_outlined,
          title: 'İşlem Öncesi Kontrol',
          body:
              'Cihaz seri numarası, müşteri bilgisi, görev durumu ve satış/kargo aşamasını kontrol ederek talep oluşturmanız çözüm süresini kısaltır.',
        ),
      ],
    );
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StaticInfoPage(
      title: 'Hakkında',
      sections: const [
        _StaticInfoSection(
          icon: Icons.inventory_2_outlined,
          title: 'NarSMS',
          body:
              'NarSMS; cihaz envanteri, depo yönetimi, satış süreçleri, saha görevleri ve teknik servis operasyonlarını tek panelde takip etmek için geliştirilmiştir.',
        ),
        _StaticInfoSection(
          icon: Icons.security_outlined,
          title: 'Yetki Bazlı Kullanım',
          body:
              'Menüler kullanıcı rolüne göre açılır. Admin, depo, satış, saha ve teknik servis ekipleri kendi iş akışlarına uygun ekranlara erişir.',
        ),
        _StaticInfoSection(
          icon: Icons.sync_alt_outlined,
          title: 'Operasyon Akışı',
          body:
              'Cihaz ekleme, müşteriye satış, kargo, iade, yedek cihaz atama ve saha görevi işlemleri kayıt altında tutulur.',
        ),
      ],
    );
  }
}

class _StaticInfoPage extends StatelessWidget {
  final String title;
  final List<_StaticInfoSection> sections;

  const _StaticInfoPage({
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accentDark),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => sections[index],
      ),
    );
  }
}

class _StaticInfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _StaticInfoSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentDark, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
