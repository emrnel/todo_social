import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordAgain = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Şifre eşleşme kontrolü
    if (_passwordController.text != _passwordAgainController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şifreler eşleşmiyor!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Use ref.read to call the register method
    await ref.read(authProvider.notifier).registerUser(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    // Check auth state to determine success/failure
    final authState = ref.read(authProvider);
    if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata: ${authState.errorMessage}"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (authState.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt başarılı!"),
          backgroundColor: Colors.green,
        ),
      );
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for loading indicator
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "E-posta",
                            hintText: "ornek@mail.com",
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "E-posta boş olamaz.";
                            }
                            if (!RegExp(r"^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$")
                                .hasMatch(value)) {
                              return "Geçerli bir e-posta giriniz.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Kullanıcı Adı",
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kullanıcı adı boş olamaz";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Şifre",
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre boş olamaz";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordAgainController,
                          obscureText: _obscurePasswordAgain,
                          decoration: InputDecoration(
                            labelText: "Şifre (Tekrar)",
                            prefixIcon: const Icon(Icons.lock_reset,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePasswordAgain
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePasswordAgain =
                                      !_obscurePasswordAgain;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "Şifreler eşleşmiyor";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authState.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Kayıt Ol",
                                  style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(Routes.login),
                          child: const Text(
                            "Zaten hesabın var mı? Giriş yap",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
