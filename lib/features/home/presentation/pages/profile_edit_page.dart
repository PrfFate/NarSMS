import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class ProfileEditPage extends StatefulWidget {
  final String fallbackUserName;

  const ProfileEditPage({
    super.key,
    required this.fallbackUserName,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  SharedPreferences get _prefs => getIt<SharedPreferences>();
  UpdateProfileUseCase get _updateProfile => getIt<UpdateProfileUseCase>();

  @override
  void initState() {
    super.initState();
    _nameController.text =
        _prefs.getString(StorageConstants.userName) ?? widget.fallbackUserName;
    _emailController.text = _prefs.getString(StorageConstants.userEmail) ?? '';
    _phoneController.text = _prefs.getString(StorageConstants.userPhone) ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId =
        int.tryParse(_prefs.getString(StorageConstants.userId) ?? '');
    if (userId == null || userId == 0) {
      _showSnackBar('Kullanıcı bilgisi bulunamadı', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _updateProfile(
      UpdateProfileParams(
        id: userId,
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => _showSnackBar(failure.message, isError: true),
      (_) {
        context.read<HomeBloc>().add(const LoadUserInfo());
        _showSnackBar('Profil bilgileri güncellendi');
        Navigator.pop(context, true);
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormScaffold(
      title: 'Profili Düzenle',
      bottomButtonText: 'Güncelle',
      isLoading: _isLoading,
      onBottomButtonPressed: _submit,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Ad Soyad',
                hint: 'Ad soyad girin',
                controller: _nameController,
                isRequired: true,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ad soyad zorunlu'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'E-posta',
                hint: 'E-posta adresi girin',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'E-posta zorunlu';
                  if (!email.contains('@')) return 'Geçerli bir e-posta girin';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Telefon',
                hint: 'Telefon numarası girin',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
