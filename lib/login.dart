import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementsync/collegedashboard.dart';
import 'package:placementsync/home_screen.dart';
import 'package:placementsync/signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  // ── Theme constants ─────────────────────────────────────────────────────────
  static const Color _bg      = Color(0xFF0D0F14);
  static const Color _surface = Color(0xFF161A23);
  static const Color _cardBg  = Color(0xFF1C2030);
  static const Color _accent  = Color(0xFF4F8EF7);
  static const Color _textPri = Color(0xFFEEF0F5);
  static const Color _textSec = Color(0xFF7A8099);
  static const Color _border  = Color(0xFF2A2F42);

  // ── Controllers ─────────────────────────────────────────────────────────────
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading       = false;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Original logic — untouched ──────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    const String apiUrl = "http://10.0.2.2:9494/PlacementSync/LoginServlet";

    setState(() => _isLoading = true);

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "email": _emailController.text,
          "password": _passwordController.text,
        },
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        String role = jsonResponse['role'];
        String name = jsonResponse['name'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome back, $name!"),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'STUDENT') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else if (role == 'COLLEGE') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CollegeDashboardScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("College Dashboard coming soon!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Network Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // ── End of original logic ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Decorative background blobs ──────────────────────────────────
          Positioned(
            top: -100,
            left: -60,
            child: _blob(_accent, 280, 0.14),
          ),
          Positioned(
            bottom: 40,
            right: -80,
            child: _blob(const Color(0xFFFFC857), 220, 0.09),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ── Brand mark ──────────────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_accent, Color(0xFF2E5FD9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.sync_alt_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "PlacementSync",
                            style: TextStyle(
                              color: _textPri,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 56),

                      // ── Hero icon ───────────────────────────────────────
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _accent.withOpacity(0.20),
                                    _accent.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                            // Inner circle
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_accent, Color(0xFF2E5FD9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.40),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Heading ─────────────────────────────────────────
                      const Center(
                        child: Text(
                          "Welcome back",
                          style: TextStyle(
                            color: _textPri,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          "Sign in to your account",
                          style: TextStyle(
                            color: _textSec,
                            fontSize: 14.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 44),

                      // ── Form card ───────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email
                            _fieldLabel("Email Address"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: "you@college.edu",
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),

                            // Password
                            _fieldLabel("Password"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: "Enter your password",
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _textSec,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Login button ────────────────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _handleLogin,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLoading
                                  ? [
                                      _accent.withOpacity(0.5),
                                      const Color(0xFF2E5FD9).withOpacity(0.5),
                                    ]
                                  : [_accent, const Color(0xFF2E5FD9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: _accent.withOpacity(0.38),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Divider ─────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Container(height: 1, color: _border),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              "or",
                              style: TextStyle(
                                color: _textSec.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: _border),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Create account button ───────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                          ),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                text: "New to PlacementSync?  ",
                                style: TextStyle(
                                  color: _textSec,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Create account",
                                    style: TextStyle(
                                      color: _accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Footer ──────────────────────────────────────────
                      Center(
                        child: Text(
                          "Connecting students with opportunities",
                          style: TextStyle(
                            color: _textSec.withOpacity(0.55),
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _blob(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
          ),
        ),
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFFADB5C8),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: _textPri, fontSize: 15),
        cursorColor: _accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textSec, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSec, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: _surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 1.8),
          ),
        ),
      );
}