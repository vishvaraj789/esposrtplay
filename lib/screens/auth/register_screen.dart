import 'package:eposrtplay/screens/team/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/google_login_button.dart';
import '../../core/widgets/facebook_login_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Email/Password Registration
  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // Create user with email and password
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Update user profile with username
        await _auth.currentUser?.updateDisplayName(usernameController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful! Please login."),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Registration failed";

        if (e.code == 'weak-password') {
          errorMessage = "Password is too weak";
        } else if (e.code == 'email-already-in-use') {
          errorMessage = "Email is already registered";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email format";
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

  // Google Sign-In Registration
  void registerWithGoogle() {
    if (isLoading) return;
    _handleGoogleSignUp();
  }

  Future<void> _handleGoogleSignUp() async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration Successful!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google sign up failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void registerWithFacebook() {
    if (isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Facebook registration coming soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
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
                  "Join Us to start searching",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Discover your perfect Team and Player",
                ),
                const SizedBox(height: 20),
                GoogleLoginButton(
                  onPressed: !isLoading ? registerWithGoogle : null,
                ),
                const SizedBox(height: 15),
                FacebookLoginButton(
                  onPressed: !isLoading ? registerWithFacebook : null,
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: usernameController,
                  label: "Username",
                  hint: "Enter username",
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username is required";
                    }
                    if (value.length < 3) {
                      return "Username must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  hint: "Enter email",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  hint: "Enter password",
                  icon: Icons.lock,
                  obscureText: _hidePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Re-enter password",
                  icon: Icons.lock_outline,
                  obscureText: _hideConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _hideConfirmPassword = !_hideConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: isLoading ? "Registering..." : "Register",
                  icon: Icons.person_add,
                  onPressed: !isLoading ? register : null,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: !isLoading
                      ? () {
                    Navigator.pop(context);
                  }
                      : null,
                  child: const Text(
                    "Already have an account? Login",
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