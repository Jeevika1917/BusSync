import 'package:flutter/material.dart';

import '../passenger/destination_selection_screen.dart';
import '../auth/driver_login_screen.dart';
import '../auth/admin_login_screen.dart';

// ================================================================
// BUSSYNC — CURRENT YELLOW + BLACK THEME
// ================================================================

const Color yellow = Color(0xFFE8B949);
const Color yellowDark = Color(0xFFC99516);
const Color yellowLight = Color(0xFFFFF7DD);
const Color yellowSoft = Color(0xFFFFFCF5);

const Color black = Color(0xFF242424);
const Color white = Color(0xFFFFFFFF);

const Color textDark = Color(0xFF252525);
const Color textMuted = Color(0xFF666666);
const Color border = Color(0xFFE8E0C8);

const Color green = Color(0xFF16A34A);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final screenWidth = size.width;
    final screenHeight = size.height;

    final horizontalPadding =
    (screenWidth * 0.06).clamp(20.0, 28.0);

    final logoSize =
    (screenWidth * 0.34).clamp(120.0, 145.0);

    final buttonHeight =
    (screenHeight * 0.075).clamp(58.0, 70.0);

    final iconBoxSize =
    (screenWidth * 0.095).clamp(36.0, 42.0);

    final sectionSpacing =
    (screenHeight * 0.022).clamp(12.0, 24.0);

    final titleSize =
    (screenWidth * 0.09).clamp(30.0, 38.0);

    return Scaffold(
      backgroundColor: yellowSoft,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              yellowLight,
              yellowSoft,
              white,
            ],
            stops: [
              0.0,
              0.48,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ==========================================================
            // DECORATIVE BACKGROUND CIRCLES
            // ==========================================================

            Positioned(
              top: -screenWidth * 0.18,
              right: -screenWidth * 0.16,
              child: _BackgroundCircle(
                size: screenWidth * 0.55,
                color: yellow.withValues(alpha: 0.12),
              ),
            ),

            Positioned(
              top: screenHeight * 0.20,
              left: -screenWidth * 0.25,
              child: _BackgroundCircle(
                size: screenWidth * 0.50,
                color: yellowDark.withValues(alpha: 0.055),
              ),
            ),

            Positioned(
              bottom: -screenWidth * 0.20,
              right: -screenWidth * 0.16,
              child: _BackgroundCircle(
                size: screenWidth * 0.55,
                color: yellow.withValues(alpha: 0.08),
              ),
            ),

            // ==========================================================
            // MAIN CONTENT
            // ==========================================================

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.018,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.vertical,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),

                      // ==================================================
                      // LOGO
                      // ==================================================

                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            logoSize * 0.22,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: yellowDark.withValues(alpha: 0.22),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            logoSize * 0.22,
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      yellow,
                                      yellowDark,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.directions_bus_rounded,
                                  size: logoSize * 0.48,
                                  color: black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        height: sectionSpacing * 0.8,
                      ),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        'BusSync',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: black,
                          letterSpacing: -1,
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.004,
                      ),

                      const Text(
                        'Check. Choose. Board.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: yellowDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.010,
                      ),

                      Text(
                        'Real-Time College Bus Seat Availability',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.034)
                              .clamp(11.0, 14.0),
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),

                      SizedBox(
                        height: sectionSpacing * 0.8,
                      ),

                      // ==================================================
                      // LIVE SYNC INDICATOR
                      // ==================================================

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.035,
                          vertical: screenHeight * 0.009,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: yellowDark.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Real-time seat sync active',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.030)
                                    .clamp(10.0, 12.0),
                                fontWeight: FontWeight.w600,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: sectionSpacing,
                      ),

                      // ==================================================
                      // ROLE CARD
                      // ==================================================

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.045,
                          screenHeight * 0.022,
                          screenWidth * 0.045,
                          screenHeight * 0.018,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: border,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: yellowDark.withValues(alpha: 0.10),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ==================================================
                            // ROLE HEADING
                            // ==================================================

                            Text(
                              'How are you travelling?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (screenWidth * 0.048)
                                    .clamp(17.0, 20.0),
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * 0.004,
                            ),

                            const Text(
                              'Choose your portal to get started',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: textMuted,
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * 0.020,
                            ),

                            // ==================================================
                            // PASSENGER BUTTON
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const DestinationSelectionScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: black,
                                  foregroundColor: white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.025,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: iconBoxSize,
                                      height: iconBoxSize,
                                      decoration: BoxDecoration(
                                        color: yellow,
                                        borderRadius:
                                        BorderRadius.circular(11),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: iconBoxSize * 0.52,
                                        color: black,
                                      ),
                                    ),

                                    SizedBox(
                                      width: screenWidth * 0.032,
                                    ),

                                    const Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Passenger',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Find a bus with available seats',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: screenWidth * 0.015,
                                    ),

                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 21,
                                      color: yellow,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * 0.014,
                            ),

                            // ==================================================
                            // DRIVER BUTTON
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const DriverLoginScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: black,
                                  foregroundColor: white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.025,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: iconBoxSize,
                                      height: iconBoxSize,
                                      decoration: BoxDecoration(
                                        color: yellow,
                                        borderRadius:
                                        BorderRadius.circular(11),
                                      ),
                                      child: Icon(
                                        Icons.directions_bus_rounded,
                                        size: iconBoxSize * 0.52,
                                        color: black,
                                      ),
                                    ),

                                    SizedBox(
                                      width: screenWidth * 0.032,
                                    ),

                                    const Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Driver Portal',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Update your bus information',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: screenWidth * 0.015,
                                    ),

                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 21,
                                      color: yellow,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.016,
                      ),

                      // ==================================================
                      // INFO CARD
                      // ==================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: yellowLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: yellow,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'All campus students can check bus availability without signing in.',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  height: 1.35,
                                  color: textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // ADMIN SIGN IN
                      // ==================================================

                      SizedBox(
                        height: screenHeight * 0.008,
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const AdminLoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: yellowDark,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.006,
                          ),
                        ),
                        child: Text(
                          'Sign in as Admin',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.034)
                                .clamp(11.0, 14.0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.004,
                      ),

                      // ==================================================
                      // FOOTER
                      // ==================================================

                      Text(
                        'BusSync • College Transport',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.025)
                              .clamp(9.0, 11.0),
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.008,
                      ),
                    ],
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

// ======================================================================
// DECORATIVE BACKGROUND CIRCLE
// ======================================================================

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}