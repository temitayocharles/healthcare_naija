import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/result/app_result.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedRole = AppConstants.rolePatient;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final result = await ref.read(authRepositoryProvider).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result is AppSuccess<User>) {
          await ref.read(currentUserProvider.notifier).setUser(result.data);
          if (mounted) {
            context.go('/');
          }
        } else if (result is AppFailure<User>) {
          _showError(result.message);
        }
      } else {
        final result = await ref.read(authRepositoryProvider).registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (result is AppSuccess<User>) {
          final user = result.data.copyWith(role: _selectedRole);
          await ref.read(currentUserProvider.notifier).setUser(user);
          if (mounted) {
            context.go('/');
          }
        } else if (result is AppFailure<User>) {
          _showError(result.message);
        }
      }
    } catch (error) {
      _showError('Authentication failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _continueAsGuest() async {
    final guest = User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      phone: 'guest',
      name: 'Guest User',
      role: AppConstants.rolePatient,
      createdAt: DateTime.now(),
      isVerified: false,
    );
    await ref.read(currentUserProvider.notifier).setUser(guest);
    if (mounted) {
      context.go('/');
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nigeria Health Care',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your health, our priority',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                                color: _isLogin ? AppTheme.primaryColor : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Register',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                                color: !_isLogin ? AppTheme.primaryColor : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (!_isLogin && (value == null || value.trim().isEmpty)) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    final v = value ?? '';
                    if (v.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (!_isLogin && v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: 'e.g., 08012345678',
                    ),
                    validator: (value) {
                      if (!_isLogin) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.trim().length < 11) {
                          return 'Please enter a valid Nigerian phone number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'I am a:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _RoleChip(
                        label: 'Patient',
                        value: AppConstants.rolePatient,
                        selected: _selectedRole,
                        onSelected: (v) => setState(() => _selectedRole = v),
                      ),
                      _RoleChip(
                        label: 'Physician',
                        value: AppConstants.rolePhysician,
                        selected: _selectedRole,
                        onSelected: (v) => setState(() => _selectedRole = v),
                      ),
                      _RoleChip(
                        label: 'Nurse',
                        value: AppConstants.roleNurse,
                        selected: _selectedRole,
                        onSelected: (v) => setState(() => _selectedRole = v),
                      ),
                      _RoleChip(
                        label: 'Pharmacy',
                        value: AppConstants.rolePharmacy,
                        selected: _selectedRole,
                        onSelected: (v) => setState(() => _selectedRole = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isLogin ? 'Login' : 'Create Account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _continueAsGuest,
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onSelected;

  const _RoleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}
