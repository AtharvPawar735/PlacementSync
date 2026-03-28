import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementsync/Drive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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

  // ── Original logic — untouched ──────────────────────────────────────────────
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
  // ── End of original logic ───────────────────────────────────────────────────

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Background blobs ───────────────────────────────────────────
          Positioned(
            top: -60,
            right: -50,
            child: _blob(_accent, 220, 0.15),
          ),
          Positioned(
            top: 140,
            left: -70,
            child: _blob(_accentGold, 180, 0.10),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildStatsBar(),
                  const SizedBox(height: 8),
                  _buildSectionLabel(),
                  Expanded(child: _buildDriveList()),
                ],
              ),
            ),
          ),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_accent, Color(0xFF2E5FD9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sync_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "PlacementSync",
                    style: TextStyle(
                      color: _textPri,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Upcoming Drives",
                style: TextStyle(
                  color: _textPri,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Find your next opportunity",
                style: TextStyle(
                  color: _textSec,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          // Avatar / notification bell
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _textSec,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats bar ──────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          _statChip(Icons.business_center_outlined, "Live Drives", _accent),
          const SizedBox(width: 12),
          _statChip(Icons.trending_up_rounded, "Top CTCs", _accentGold),
          const SizedBox(width: 12),
          _statChip(Icons.check_circle_outline_rounded, "Open Now", _green),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
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
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
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
            "ALL DRIVES",
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
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Fetching drives...",
                  style: TextStyle(color: _textSec, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Error
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
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Connection Failed",
                    style: TextStyle(
                        color: _textPri,
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _textSec, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty
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
                  child:
                      const Icon(Icons.inbox_rounded, color: _accent, size: 34),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Drives Yet",
                  style: TextStyle(
                      color: _textPri,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Database connected, but 0 drives found!",
                  style: TextStyle(color: _textSec, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Data
        if (snapshot.hasData) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Drive drive = snapshot.data![index];
              return _DriveCard(drive: drive, index: index);
            },
          );
        }

        return const Center(
          child: Text(
            "No upcoming drives found",
            style: TextStyle(color: _textSec),
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _blob(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }
}

// ── Drive card widget ─────────────────────────────────────────────────────────
class _DriveCard extends StatefulWidget {
  final Drive drive;
  final int index;
  const _DriveCard({required this.drive, required this.index});

  @override
  State<_DriveCard> createState() => _DriveCardState();
}

class _DriveCardState extends State<_DriveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Cycle through accent colors per card
  static const List<Color> _accentCycle = [
    Color(0xFF4F8EF7),
    Color(0xFFFFC857),
    Color(0xFF34D399),
    Color(0xFFFC6E6E),
    Color(0xFFA78BFA),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 60),
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
    final Color accent = _accentCycle[widget.index % _accentCycle.length];
    final Drive d = widget.drive;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2030),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2F42)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Top colored strip + company info ───────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.07),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom:
                        BorderSide(color: accent.withOpacity(0.18), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Company initial avatar
                    Container(
                      width: 48,
                      height: 48,
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.companyName ?? "Company Name Not Available",
                            style: const TextStyle(
                              color: Color(0xFFEEF0F5),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            d.jobRole ?? "Job Role Not Available",
                            style: TextStyle(
                              color: accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "OPEN" badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF34D399).withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        "OPEN",
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Chips row ──────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _infoChip(
                      Icons.currency_rupee_rounded,
                      "${d.ctcLpa ?? 0.0} LPA",
                      const Color(0xFFFFC857),
                    ),
                    const SizedBox(width: 10),
                    _infoChip(
                      Icons.school_outlined,
                      "Min ${d.minCgpaRequired ?? 0.0} CGPA",
                      const Color(0xFFA78BFA),
                    ),
                    const Spacer(),
                    // ── Apply button — original onPressed kept ─────────
                    GestureDetector(
                      onTap: () {}, // original empty onPressed
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent, accent.withOpacity(0.70)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}