import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ocr_task_scheduler/pages/splash_screen.dart';
import 'package:ocr_task_scheduler/utils/BlurredBackgroundBlob.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool show = false;
  bool loading = false;

  Future<void> handleSignInWithEmail() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final User? user = res.user;

      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      final errorMessage = e is PostgrestException ? e.message : e.toString();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            BlurredBackgroundBlob(),
            Center(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/images/bexsys_logo.png",
                                width: 150,
                              ),
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text("Email"),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedMail01,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                              obscureText: !show,
                              decoration: InputDecoration(
                                label: const Text("Password"),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedKey01,
                                    color: Colors.black54,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      show = !show;
                                    });
                                  },
                                  icon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: HugeIcon(
                                      icon: show
                                          ? HugeIcons.strokeRoundedView
                                          : HugeIcons.strokeRoundedViewOff,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  } else {
                                    handleSignInWithEmail();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Sign in",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
