import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../navigation/main_navigation.dart';
import 'register_screen.dart';

import '../../../routes/app_router.dart';
import '../../../core/services/user_service.dart';
import '../../profile/widgets/user_form.dart';
import '../../profile/widgets/custom_text_field.dart';
import '../../profile/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // v7: GoogleSignIn is a singleton, not a constructor.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoginEnabled = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(checkFields);
    passwordController.addListener(checkFields);
    _initGoogleSignIn();
  }

  /// v7 requires an explicit initialize() call before authenticate()/
  /// signOut() can be used. Do this once, early.
  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        // If you have a web/serverClientId (needed for getting an ID token
        // to send to your backend, or for iOS), pass it here:
        // serverClientId: 'YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn init failed: $e');
    }
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

  /// Routes the user forward after a successful sign-in: straight into
  /// the app if their profile already exists, or to UserForm if this is
  /// their first time completing it. Prevents UserForm from reappearing
  /// on every subsequent login.
  Future<void> _routeAfterSignIn(String uid) async {
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

  /// Email/Password Login
  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        // Verify email format one more time
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

        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Successful ✅"),
              backgroundColor: Color(0xFF34A853),
            ),
          );
          await _routeAfterSignIn(credential.user!.uid);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Login failed";

        if (e.code == 'user-not-found') {
          errorMessage = "No account found with this email.\nPlease register first.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password.\nPlease try again.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email format";
        } else if (e.code == 'user-disabled') {
          errorMessage = "This account has been disabled";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many login attempts.\nPlease try again later";
        } else if (e.code == 'operation-not-allowed') {
          errorMessage = "Email/password sign-in is not enabled";
        } else if (e.code == 'invalid-credential') {
          errorMessage = "Invalid email or password";
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

  /// Google Sign-In
  void loginWithGoogle() {
    if (isGoogleLoading || isLoading) return;
    _handleGoogleSignIn();
  }

  Future<void> _handleGoogleSignIn() async {
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
      // accessToken is no longer part of the basic auth object — Firebase
      // only needs the idToken to sign in.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-In Successful ✅"),
            backgroundColor: Color(0xFF34A853),
          ),
        );
        await _routeAfterSignIn(userCredential.user!.uid);
      }
    } on GoogleSignInException catch (e) {
      // Handle Google Sign-In specific errors (including cancellation)
      if (mounted && e.code != GoogleSignInExceptionCode.canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google login failed: ${e.description}"),
            backgroundColor: const Color(0xFFFF3D5A),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors
      String errorMessage = "Google login failed";

      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = "An account already exists with this email";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Invalid credentials";
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = "Google sign-in is not enabled";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Network error. Please check your connection.";
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
            content: Text("Google login failed: ${e.toString()}"),
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

  void loginWithFacebook() {
    if (isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Facebook login coming soon"),
        backgroundColor: Color(0xFF1877F2),
      ),
    );
  }

  void _navigateToRegister() {
    if (!isLoading && !isGoogleLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a password reset link."),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3D5A),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter your email")),
                );
                return;
              }

              try {
                await _auth.sendPasswordResetEmail(email: email);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password reset link sent to your email ✅",
                      ),
                      backgroundColor: Color(0xFF34A853),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                String errorMessage = "Failed to send reset email";

                if (e.code == 'user-not-found') {
                  errorMessage = "No account found with this email";
                } else if (e.code == 'invalid-email') {
                  errorMessage = "Invalid email format";
                } else if (e.code == 'too-many-requests') {
                  errorMessage = "Too many requests. Try again later";
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: const Color(0xFFFF3D5A),
                    ),
                  );
                }
              }
            },
            child: const Text("Send Reset Link"),
          ),
        ],
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
                      "Free Fire Max Tournament Platform",
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

              // Form card, overlapping the header slightly for a layered look
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
                          "Welcome back",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Log in to join tournaments and manage your squad.",
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
                          hint: "Enter your password",
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
                              return "Please enter your password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },

                        ),
                        const SizedBox(height: 8),

                        // Remember Me & Forgot Password
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: rememberMe,
                                activeColor: const Color(0xFFFF3D5A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const Text(
                              "Remember me",
                              style: TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: (!isLoading && !isGoogleLoading)
                                  ? _showForgotPasswordDialog
                                  : null,
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF3D5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        PrimaryButton(
                          text: isLoading ? "Logging in..." : "Login",
                          icon: Icons.login,
                          onPressed: (isLoginEnabled && !isLoading && !isGoogleLoading)
                              ? login
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
                                "OR CONTINUE WITH",
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

                        // Google Login Button
                        GoogleLoginButton(
                          isLoading: isGoogleLoading,
                          onPressed: (!isLoading && !isGoogleLoading)
                              ? loginWithGoogle
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Facebook Login Button
                        FacebookLoginButton(
                          onPressed: (!isLoading && !isGoogleLoading)
                              ? loginWithFacebook
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Register Link
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text(
                        "Register",
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

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleLoginButton({
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

/// Google's "G" logo, drawn locally with CustomPaint instead of fetched
/// from the network. This avoids the icon flickering in, failing to load
/// on slow/offline connections, or briefly showing a fallback icon —
/// all of which undermine trust in a sign-in button specifically.
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

    // Four arcs approximating Google's brand colors, in order.
    paint.color = const Color(0xFF4285F4); // blue
    canvas.drawArc(rect, -0.45, 1.55, false, paint);

    paint.color = const Color(0xFF34A853); // green
    canvas.drawArc(rect, 1.15, 1.55, false, paint);

    paint.color = const Color(0xFFFBBC05); // yellow
    canvas.drawArc(rect, 2.75, 1.1, false, paint);

    paint.color = const Color(0xFFEA4335); // red
    canvas.drawArc(rect, 3.9, 1.9, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FacebookLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const FacebookLoginButton({
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