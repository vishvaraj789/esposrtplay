import 'package:eposrtplay/screens/player/choose_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register_screen.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/google_login_button.dart';
import '../../core/widgets/facebook_login_button.dart';
// import '../../core/widgets/appleid_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState( ) => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoginEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(checkFields);
    passwordController.addListener(checkFields);
  }

  void checkFields() {
    setState(() {
      isLoginEnabled =
          emailController.text.trim().isNotEmpty &&
              passwordController.text.trim().isNotEmpty &&
              !isLoading;
    });
  }

  @override
  void dispose() {
    emailController.removeListener(checkFields);
    passwordController.removeListener(checkFields);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Email/Password Login
  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful ✅")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChooseRoleScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Login failed";

        if (e.code == 'user-not-found') {
          errorMessage = "No user found with this email";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Wrong password";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email format";
        } else if (e.code == 'user-disabled') {
          errorMessage = "This account has been disabled";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many login attempts. Try again later";
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  // Google Sign-In
  void loginWithGoogle() {
    if (isLoading) return;

    _handleGoogleSignIn();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChooseRoleScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google login failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void loginWithFacebook() {
    if (isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Facebook login coming soon")),
    );
  }

  // void loginWithApple() {
  //   if (isLoading) return;
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Apple sign-in coming soon")),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EsportPlay"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.sports_esports,
                  size: 90,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  "EsportPlay",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Free Fire Max Tournament Platform",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  hint: "Enter your email",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  icon: Icons.lock,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text("Remember Me"),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Forgot Password feature coming soon!",
                            ),
                          ),
                        );
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  text: isLoading ? "Logging in..." : "Login",
                  icon: Icons.login,
                  onPressed: (isLoginEnabled && !isLoading) ? login : null,
                ),
                const SizedBox(height: 15),
                GoogleLoginButton(
                  onPressed: !isLoading ? loginWithGoogle : null,
                ),

                FacebookLoginButton(
                  onPressed: !isLoading ? loginWithFacebook : null,
                ),
                //
                // AppleLoginButton(
                //   onPressed: !isLoading ? loginWithApple : null,
                // ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: !isLoading
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const RegisterScreen(),
                          ),
                        );
                      }
                          : null,
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}