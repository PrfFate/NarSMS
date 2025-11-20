import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pages/barcode_scanner_page.dart';
import '../pages/profile_page.dart';
import '../bloc/home_bloc.dart';

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // Sol 2 Icon
              _buildNavItem(
                context,
                Icons.home_outlined,
                'Ana Sayfa',
                0,
              ),
              _buildNavItem(
                context,
                Icons.search_outlined,
                'Arama',
                1,
              ),

              // Ortada boşluk (barkod okuyucu için)
              const Spacer(),

              // Sağ 2 Icon
              _buildNavItem(
                context,
                Icons.notifications_outlined,
                'Bildirimler',
                3,
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                'Profil',
                4,
              ),
            ],
          ),

          // Ortadaki Büyük Barkod Okuyucu Butonu
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            top: -20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF57C00), Color(0xFFF34723)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF57C00).withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    onIndexChanged(2);

                    // Barkod okuyucu sayfasını aç
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerPage(),
                      ),
                    );

                    // Taranan kodu göster
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Seri No: $result'),
                          backgroundColor: const Color(0xFFF57C00),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      // TODO: Burada cihaz arama, ekleme işlemleri yapılacak
                    }
                  },
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
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

            // Profil ikonuna tıklanınca profil sayfasına git
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
                color: isSelected ? const Color(0xFFF57C00) : Colors.grey,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFF57C00) : Colors.grey,
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
}
