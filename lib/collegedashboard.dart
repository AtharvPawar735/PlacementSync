import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementsync/Drive.dart';
import 'package:placementsync/login.dart';

class CollegeDashboardScreen extends StatefulWidget {
  const CollegeDashboardScreen({super.key});

  @override
  State<CollegeDashboardScreen> createState() => _CollegeDashboardScreenState();
}

class _CollegeDashboardScreenState extends State<CollegeDashboardScreen>
    with SingleTickerProviderStateMixin {

  // ── Theme constants ─────────────────────────────────────────────────────────
  static const Color _bg         = Color(0xFF0D0F14);
  static const Color _surface    = Color(0xFF161A23);
  static const Color _cardBg     = Color(0xFF1C2030);
  static const Color _accent     = Color(0xFF4F8EF7);
  static const Color _accentGold = Color(0xFFFFC857);
  static const Color _green      = Color(0xFF34D399);
  static const Color _textPri    = Color(0xFFEEF0F5);
  static const Color _textSec    = Color(0xFF7A8099);
  static const Color _border     = Color(0xFF2A2F42);

  static const List<Color> _accentCycle = [
    Color(0xFF4F8EF7),
    Color(0xFFFFC857),
    Color(0xFF34D399),
    Color(0xFFFC6E6E),
    Color(0xFFA78BFA),
  ];

  // ── Controllers ─────────────────────────────────────────────────────────────
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _roleController    = TextEditingController();
  final TextEditingController _ctcController     = TextEditingController();
  final TextEditingController _cgpaController    = TextEditingController();
  String? _selectedDate;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    _ctcController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  // ── Original logic — untouched ──────────────────────────────────────────────
  Future<void> _pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitDrive() async {
    if (_companyController.text.isEmpty ||
        _roleController.text.isEmpty ||
        _ctcController.text.isEmpty ||
        _cgpaController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and pick a date!")),
      );
      return;
    }

    const String apiUrl =
        "http://10.0.2.2:9494/PlacementSync/AddDriveServlet";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "companyName": _companyController.text,
          "jobRole": _roleController.text,
          "ctcLpa": _ctcController.text,
          "minCgpa": _cgpaController.text,
          "deadline": _selectedDate!,
        },
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Drive Added Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server")),
      );
    }
  }

  final String apiUrl = "http://10.0.2.2:9494/PlacementSync/DriveServlet";

  Future<List<Drive>> fetchDrives() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Drive> finalize =
          jsonList.map((json) => Drive.fromJson(json)).toList();
      print(finalize);
      return finalize;
    } else {
      throw Exception(
          "Tomcat Error! Code: ${response.statusCode}, Message: ${response.body}");
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future _submit(BuildContext context) {
    // Clear fields every time sheet opens
    _companyController.clear();
    _roleController.clear();
    _ctcController.clear();
    _cgpaController.clear();
    _selectedDate = null;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF161A23),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0xFF2A2F42)),
                  left: BorderSide(color: Color(0xFF2A2F42)),
                  right: BorderSide(color: Color(0xFF2A2F42)),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        height: 4,
                        width: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2F42),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sheet title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent, Color(0xFF2E5FD9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_business_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add New Drive",
                              style: TextStyle(
                                color: _textPri,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "Fill details to publish",
                              style:
                                  TextStyle(color: _textSec, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Company name
                    _sheetLabel("Company Name"),
                    const SizedBox(height: 8),
                    _sheetField(
                      controller: _companyController,
                      hint: "e.g. Google",
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 18),

                    // Job role
                    _sheetLabel("Job Role"),
                    const SizedBox(height: 8),
                    _sheetField(
                      controller: _roleController,
                      hint: "e.g. Software Engineer",
                      icon: Icons.work_outline_rounded,
                    ),
                    const SizedBox(height: 18),

                    // CTC + CGPA row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sheetLabel("CTC (LPA)"),
                              const SizedBox(height: 8),
                              _sheetField(
                                controller: _ctcController,
                                hint: "e.g. 12.5",
                                icon: Icons.currency_rupee_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sheetLabel("Min CGPA"),
                              const SizedBox(height: 8),
                              _sheetField(
                                controller: _cgpaController,
                                hint: "e.g. 7.5",
                                icon: Icons.school_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Deadline picker
                    _sheetLabel("Application Deadline"),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        await _pickDeadline();
                        setSheetState(() {}); // refresh sheet UI
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedDate != null
                                ? _accent.withOpacity(0.6)
                                : _border,
                            width: _selectedDate != null ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: _selectedDate != null
                                  ? _accent
                                  : _textSec,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? "Pick a deadline date"
                                  : _selectedDate!,
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? _textPri
                                    : _textSec,
                                fontSize: 14.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _accent.withOpacity(0.3)),
                              ),
                              child: const Text(
                                "Select",
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Publish button
                    GestureDetector(
                      onTap: _submitDrive,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_accent, Color(0xFF2E5FD9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text(
                              "Publish Drive",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // ── End of original logic ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Background blobs ─────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _blob(_accent, 240, 0.14),
          ),
          Positioned(
            bottom: 80,
            left: -70,
            child: _blob(_accentGold, 200, 0.10),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildAdminBanner(),
                  _buildSectionLabel(),
                  Expanded(child: _buildDriveList()),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accent, Color(0xFF2E5FD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _submit(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Add Drive",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, Color(0xFF2E5FD9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.sync_alt_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "PlacementSync",
                style: TextStyle(
                  color: _textPri,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          // Logout
          GestureDetector(
            onTap: _logout,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                    color: Colors.redAccent.withOpacity(0.25)),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Admin info banner ──────────────────────────────────────────────────────
  Widget _buildAdminBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _accent.withOpacity(0.18),
              const Color(0xFF2E5FD9).withOpacity(0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: _accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      color: _textPri,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Manage & publish placement drives",
                    style: TextStyle(
                      color: _textSec,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _green.withOpacity(0.35)),
              ),
              child: const Text(
                "LIVE",
                style: TextStyle(
                  color: _green,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "POSTED DRIVES",
            style: TextStyle(
              color: _textSec,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Drive list ─────────────────────────────────────────────────────────────
  Widget _buildDriveList() {
    return FutureBuilder<List<Drive>>(
      future: fetchDrives(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                      color: _accent, strokeWidth: 2.5),
                ),
                const SizedBox(height: 14),
                const Text("Loading drives...",
                    style: TextStyle(color: _textSec, fontSize: 14)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_off_rounded,
                        color: Colors.redAccent, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text("Connection Failed",
                      style: TextStyle(
                          color: _textPri,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text("Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: _textSec, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inbox_rounded,
                      color: _accent, size: 34),
                ),
                const SizedBox(height: 16),
                const Text("No Drives Yet",
                    style: TextStyle(
                        color: _textPri,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text("Click + to add your first drive!",
                    style: TextStyle(color: _textSec, fontSize: 13)),
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Drive drive = snapshot.data![index];
              return _AdminDriveCard(
                  drive: drive,
                  index: index,
                  accentCycle: _accentCycle);
            },
          );
        }

        return const Center(
          child: Text("No data found",
              style: TextStyle(color: _textSec)),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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

  Widget _sheetLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFFADB5C8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      );

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: _textPri, fontSize: 14.5),
        cursorColor: _accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textSec, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSec, size: 19),
          filled: true,
          fillColor: _surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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

// ── Admin drive card ──────────────────────────────────────────────────────────
class _AdminDriveCard extends StatefulWidget {
  final Drive drive;
  final int index;
  final List<Color> accentCycle;

  const _AdminDriveCard({
    required this.drive,
    required this.index,
    required this.accentCycle,
  });

  @override
  State<_AdminDriveCard> createState() => _AdminDriveCardState();
}

class _AdminDriveCardState extends State<_AdminDriveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 55),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent =
        widget.accentCycle[widget.index % widget.accentCycle.length];
    final Drive d = widget.drive;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2030),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2F42)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Company avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.55)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      (d.companyName ?? "?")[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Company info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.companyName ?? "N/A",
                        style: const TextStyle(
                          color: Color(0xFFEEF0F5),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.jobRole ?? "Role N/A",
                        style: TextStyle(
                          color: accent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _miniChip(
                            Icons.currency_rupee_rounded,
                            "${d.ctcLpa ?? 0} LPA",
                            const Color(0xFFFFC857),
                          ),
                          const SizedBox(width: 8),
                          _miniChip(
                            Icons.school_outlined,
                            "${d.minCgpaRequired ?? 0} CGPA",
                            const Color(0xFFA78BFA),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit icon — original trailing icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2F42),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Color(0xFF7A8099), size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}