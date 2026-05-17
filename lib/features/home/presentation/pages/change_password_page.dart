import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  ChangePasswordUseCase get _changePassword => getIt<ChangePasswordUseCase>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await _changePassword(
      ChangePasswordParams(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => _showSnackBar(failure.message, isError: true),
      (message) {
        _showSnackBar(message);
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
      title: 'Şifre Değiştir',
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
                label: 'Mevcut Şifre',
                hint: 'Mevcut şifrenizi girin',
                controller: _oldPasswordController,
                obscureText: _hideOldPassword,
                isRequired: true,
                suffixIcon: _VisibilityButton(
                  isHidden: _hideOldPassword,
                  onPressed: () => setState(
                    () => _hideOldPassword = !_hideOldPassword,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Mevcut şifre zorunlu'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Yeni Şifre',
                hint: 'Yeni şifrenizi girin',
                controller: _newPasswordController,
                obscureText: _hideNewPassword,
                isRequired: true,
                suffixIcon: _VisibilityButton(
                  isHidden: _hideNewPassword,
                  onPressed: () => setState(
                    () => _hideNewPassword = !_hideNewPassword,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yeni şifre zorunlu';
                  }
                  if (value.length < 6) {
                    return 'Yeni şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Yeni Şifre Tekrar',
                hint: 'Yeni şifrenizi tekrar girin',
                controller: _confirmPasswordController,
                obscureText: _hideConfirmPassword,
                isRequired: true,
                suffixIcon: _VisibilityButton(
                  isHidden: _hideConfirmPassword,
                  onPressed: () => setState(
                    () => _hideConfirmPassword = !_hideConfirmPassword,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre tekrarı zorunlu';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Yeni şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  final bool isHidden;
  final VoidCallback onPressed;

  const _VisibilityButton({
    required this.isHidden,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
    );
  }
}
