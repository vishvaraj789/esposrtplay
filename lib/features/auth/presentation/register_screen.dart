import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../navigation/main_navigation.dart';
import 'login_screen.dart';
import '../../../routes/app_router.dart';
import '../../profile/widgets/user_form.dart';
import '../../../core/services/user_service.dart';
import '../../profile/widgets/custom_text_field.dart';
import '../../profile/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // v7: GoogleSignIn is a singleton, not a constructor.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;
  bool isRegisterEnabled = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(checkFields);
    passwordController.addListener(checkFields);
    confirmPasswordController.addListener(checkFields);
    _initGoogleSignIn();
  }

  /// v7 requires an explicit initialize() call before authenticate()/
  /// signOut() can be used. Do this once, early.
  ///
  /// NOTE: if login_screen.dart also calls _googleSignIn.initialize(),
  /// calling it a second time here on the same singleton is safe but
  /// redundant. Consider initializing GoogleSignIn once in main.dart
  /// instead, so both screens share the same initialized instance.
  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        // serverClientId: 'YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn init failed: $e');
    }
  }

  void checkFields() {
    setState(() {
      isRegisterEnabled =
          emailController.text.trim().isNotEmpty &&
              passwordController.text.trim().isNotEmpty &&
              confirmPasswordController.text.trim().isNotEmpty &&
              agreeToTerms &&
              !isLoading;
    });
  }

  @override
  void dispose() {
    emailController.removeListener(checkFields);
    passwordController.removeListener(checkFields);
    confirmPasswordController.removeListener(checkFields);
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Routes the user forward after a successful sign-up
  Future<void> _routeAfterSignUp(String uid) async {
    if (!mounted) return;

    final hasProfile = await UserService.instance.hasProfile(uid);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        hasProfile ? const MainNavigation() : const UserForm(),
      ),
    );
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength
  bool _isValidPassword(String password) {
    // At least 6 characters, contains letters and numbers
    final passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Email/Password Registration
  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final confirmPassword = confirmPasswordController.text.trim();

        // Verify email format
        if (!_isValidEmail(email)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid email format"),
                backgroundColor: Color(0xFFFF3D5A),
              ),
            );
          }
          setState(() => isLoading = false);
          return;
        }

        // Verify passwords match
        if (password != confirmPassword) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Passwords do not match"),
                backgroundColor: Color(0xFFFF3D5A),
              ),
            );
          }
          setState(() => isLoading = false);
          return;
        }

        // Verify password strength
        if (!_isValidPassword(password)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Password must be at least 6 characters and contain letters and numbers",
                ),
                backgroundColor: Color(0xFFFF3D5A),
              ),
            );
          }
          setState(() => isLoading = false);
          return;
        }

        // Create user account
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful ✅"),
              backgroundColor: Color(0xFF34A853),
            ),
          );
          await _routeAfterSignUp(userCredential.user!.uid);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Registration failed";

        if (e.code == 'weak-password') {
          errorMessage = "Password is too weak.\nUse at least 6 characters with letters and numbers.";
        } else if (e.code == 'email-already-in-use') {
          errorMessage = "Email already registered.\nPlease log in or use a different email.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email format";
        } else if (e.code == 'operation-not-allowed') {
          errorMessage = "Email/password sign-up is not enabled";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many registration attempts.\nPlease try again later";
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: const Color(0xFFFF3D5A),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: const Color(0xFFFF3D5A),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  /// Google Sign-Up
  void signUpWithGoogle() {
    if (isGoogleLoading || isLoading) return;
    _handleGoogleSignUp();
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => isGoogleLoading = true);

    try {
      if (!_googleSignInInitialized) {
        await _initGoogleSignIn();
      }

      // Sign out first to ensure a fresh account picker.
      await _googleSignIn.signOut();

      // v7: authenticate() replaces signIn(). It throws
      // GoogleSignInException (code .canceled) instead of returning null
      // when the user dismisses the picker.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // v7: GoogleSignInAuthentication only exposes idToken now.
      // Firebase only needs the idToken to sign in.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign up to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-Up Successful ✅"),
            backgroundColor: Color(0xFF34A853),
          ),
        );
        await _routeAfterSignUp(userCredential.user!.uid);
      }
    } on GoogleSignInException catch (e) {
      if (mounted && e.code != GoogleSignInExceptionCode.canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google sign-up failed: ${e.description}"),
            backgroundColor: const Color(0xFFFF3D5A),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Google sign-up failed";

      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = "This email is already registered with a different method";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Invalid credentials";
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = "Google sign-up is not enabled";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFFF3D5A),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google sign-up failed: ${e.toString()}"),
            backgroundColor: const Color(0xFFFF3D5A),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGoogleLoading = false);
      }
    }
  }

  void signUpWithFacebook() {
    if (isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Facebook sign-up coming soon"),
        backgroundColor: Color(0xFF1877F2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branded header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_esports,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "EsportPlay",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Join the Tournament Platform",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Form card
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Account",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sign up to start joining tournaments.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        CustomTextField(
                          controller: emailController,
                          label: "Email",
                          hint: "Enter your email",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!_isValidEmail(value)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: passwordController,
                          label: "Password",
                          hint: "At least 6 characters",
                          icon: Icons.lock,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                              return "Password must contain letters";
                            }
                            if (!RegExp(r'\d').hasMatch(value)) {
                              return "Password must contain numbers";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        CustomTextField(
                          controller: confirmPasswordController,
                          label: "Confirm Password",
                          hint: "Re-enter your password",
                          icon: Icons.lock_outline,
                          obscureText: obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword = !obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (value != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Terms & Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: agreeToTerms,
                                activeColor: const Color(0xFFFF3D5A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    agreeToTerms = value ?? false;
                                    checkFields();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: RichText(
                                  text: TextSpan(
                                    text: "I agree to the ",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Terms & Conditions",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFF3D5A),
                                        ),
                                      ),
                                      const TextSpan(text: " and "),
                                      TextSpan(
                                        text: "Privacy Policy",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFF3D5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Register Button
                        PrimaryButton(
                          text: isLoading ? "Creating Account..." : "Create Account",
                          icon: Icons.person_add,
                          onPressed: (isRegisterEnabled && !isLoading && !isGoogleLoading)
                              ? register
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "OR SIGN UP WITH",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Google Sign-Up Button
                        GoogleSignUpButton(
                          isLoading: isGoogleLoading,
                          onPressed: (!isLoading && !isGoogleLoading)
                              ? signUpWithGoogle
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Facebook Sign-Up Button
                        FacebookSignUpButton(
                          onPressed: (!isLoading && !isGoogleLoading)
                              ? signUpWithFacebook
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Login Link
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: (!isLoading && !isGoogleLoading)
                          ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3D5A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSignUpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignUpButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          disabledForegroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleLogo(size: 20),
            const SizedBox(width: 10),
            const Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;

  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final strokeWidth = size.width * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(radius: radius - strokeWidth / 2, center: center);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.45, 1.55, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.15, 1.55, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.75, 1.1, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.9, 1.9, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FacebookSignUpButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const FacebookSignUpButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.facebook, size: 22),
            SizedBox(width: 10),
            Text(
              "Continue with Facebook",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}