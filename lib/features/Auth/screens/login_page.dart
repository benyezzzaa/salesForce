  import 'package:flutter/material.dart';

  import 'package:animate_do/animate_do.dart';
  import 'package:get/get.dart';
  import 'package:pfe/core/routes/app_routes.dart';
  import 'package:pfe/features/Auth/controllers/login_controller.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
  }

  class _LoginPageState extends State<LoginPage> {
    final LoginController loginController = Get.put(LoginController());

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool _obscurePassword = true;
    String? errorMessage;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FC),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 900),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 90),
                      const SizedBox(height: 20),
                      const Text(
                        'Sales Force Login',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2B3A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Connectez-vous pour continuer',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("Adresse email"),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration("Mot de passe").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.forgotPasswordPage);
                            },
                            child: const Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(color: Color(0xFF3F51B5)),
                            ),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              // onPressed: (){  Get.offAllNamed(AppRoutes.homePage);},
                                onPressed:  loginController.isLoading.value
                                      ? null
                                      : () {
                                        loginController.updateEmail(
                                          emailController.text,
                                        );
                                        loginController.updatePassword(
                                          passwordController.text,
                                        );
                                        loginController.login();
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  loginController.isLoading.value
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Se connecter',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
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
      );
    }

    InputDecoration _inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
  }
