import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signup(
      _emailController.text.trim(),
      _passwordController.text,
      _nicknameController.text.trim(),
    );
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nicknameController,
                  decoration: _inputDecoration('닉네임'),
                  validator: (v) => v != null && v.length >= 2 ? null : '2자 이상 입력하세요',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('이메일'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '이메일을 입력하세요';
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    return emailRegex.hasMatch(v) ? null : '올바른 이메일 형식을 입력하세요';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('비밀번호 (6자 이상)'),
                  validator: (v) => v != null && v.length >= 6 ? null : '6자 이상 입력하세요',
                ),
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.error != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(auth.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('회원가입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppTheme.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
