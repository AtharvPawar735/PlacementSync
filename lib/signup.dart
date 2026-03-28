import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementsync/login.dart';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'STUDENT';
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Original logic — untouched ──────────────────────────────────────────────
  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    const String apiUrl = "http://10.0.2.2:9494/PlacementSync/SignupServlet";

    setState(() => _isLoading = true);

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "fullName": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "role": _selectedRole,
        },
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created! Please login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
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
    const Color bg = Color(0xFF0D0F14);
    const Color surface = Color(0xFF161A23);
    const Color cardBg = Color(0xFF1C2030);
    const Color accent = Color(0xFF4F8EF7);
    const Color accentGold = Color(0xFFFFC857);
    const Color textPrimary = Color(0xFFEEF0F5);
    const Color textSecondary = Color(0xFF7A8099);
    const Color border = Color(0xFF2A2F42);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Decorative background blobs ──────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withOpacity(0.18),
                    accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentGold.withOpacity(0.12),
                    accentGold.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── Main scrollable content ──────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ── Logo / brand mark ─────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [accent, Color(0xFF2E5FD9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
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
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 44),

                      // ── Heading ───────────────────────────────────────
                      const Text(
                        "Create your\naccount",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Join thousands of students & colleges",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Form card ─────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: border, width: 1),
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
                            _buildLabel("Full Name"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _nameController,
                              hint: "John Doe",
                              icon: Icons.person_outline_rounded,
                              accentColor: accent,
                              borderColor: border,
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              surfaceColor: surface,
                            ),

                            const SizedBox(height: 20),
                            _buildLabel("Email Address"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: "john@college.edu",
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              accentColor: accent,
                              borderColor: border,
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              surfaceColor: surface,
                            ),

                            const SizedBox(height: 20),
                            _buildLabel("Password"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: "Min. 8 characters",
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              accentColor: accent,
                              borderColor: border,
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              surfaceColor: surface,
                            ),

                            const SizedBox(height: 20),
                            _buildLabel("I am a..."),
                            const SizedBox(height: 8),

                            // ── Role selector ─────────────────────────
                            Row(
                              children: [
                                _buildRoleChip(
                                  label: "Student",
                                  value: "STUDENT",
                                  icon: Icons.school_outlined,
                                  accent: accent,
                                  border: border,
                                  surface: surface,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                ),
                                const SizedBox(width: 12),
                                _buildRoleChip(
                                  label: "College Admin",
                                  value: "COLLEGE",
                                  icon: Icons.apartment_outlined,
                                  accent: accent,
                                  border: border,
                                  surface: surface,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Sign Up button ────────────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _handleSignup,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLoading
                                  ? [
                                      accent.withOpacity(0.5),
                                      const Color(0xFF2E5FD9).withOpacity(0.5),
                                    ]
                                  : [accent, const Color(0xFF2E5FD9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: accent.withOpacity(0.38),
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
                                        "Create Account",
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

                      const SizedBox(height: 24),

                      // ── Login redirect ────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account?  ",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "Log in",
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
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

  // ── Helper widgets ───────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFADB5C8),
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
    required Color surfaceColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 15),
      cursorColor: accentColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(icon, color: hintColor, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    required Color border,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final bool isSelected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? accent.withOpacity(0.15) : surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? accent : border,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? accent : textSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? accent : textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}