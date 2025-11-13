import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/constants/api_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageConstants.accessToken);

      // Backend'e logout isteği gönder
      if (token != null) {
        final url = '${ApiConstants.baseUrl}${ApiConstants.logout}';
        await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      // Tüm verileri temizle
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    } catch (e) {
      // Hata olsa bile local verileri temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            // TODO: Drawer açılacak
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menü yakında eklenecek')),
            );
          },
        ),
        title: const Text(
          'Admin Paneli',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle_outlined, color: Colors.black87),
            onSelected: (value) {
              if (value == 'profile') {
                // TODO: Profil sayfasına git
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil sayfası yakında eklenecek')),
                );
              } else if (value == 'logout') {
                // Çıkış yap - token'ları temizle ve login sayfasına git
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Profili Görüntüle'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Bu sayfa için içerik buraya gelecek.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
