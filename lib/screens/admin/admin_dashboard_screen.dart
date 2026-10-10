import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/passenger_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ================================================================
  // BUSSYNC / YELLOW + BLACK PALETTE
  // ================================================================

  static const Color yellow = Color(0xFFE8B949);
  static const Color yellowDark = Color(0xFFC99516);
  static const Color yellowLight = Color(0xFFFFF7DD);
  static const Color yellowSoft = Color(0xFFFFFCF5);

  static const Color black = Color(0xFF242424);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF252525);
  static const Color textMuted = Color(0xFF666666);
  static const Color background = Color(0xFFFFFCF5);

  static const Color green = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
      Provider.of<PassengerProvider>(context, listen: false);

      provider.fetchBuses();
      provider.fetchStops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final passengerProvider =
    Provider.of<PassengerProvider>(context);

    final buses = passengerProvider.buses;

    final availableBuses = buses
        .where((bus) => bus.availableSeats > 0)
        .length;

    return Scaffold(
      backgroundColor: background,

      // ==============================================================
      // APP BAR
      // ==============================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BusSync',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: textDark,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Admin Console',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: yellowLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Refresh',
              icon: const Icon(
                Icons.refresh_rounded,
                color: yellowDark,
              ),
              onPressed: passengerProvider.isLoadingBuses
                  ? null
                  : () {
                passengerProvider.fetchBuses();
                passengerProvider.fetchStops();
              },
            ),
          ),

          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Sign out',
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
              ),
              onPressed: () async {
                await authProvider.logout();

                if (mounted) {
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        ],
      ),

      // ==============================================================
      // BODY
      // ==============================================================

      body: Stack(
        children: [
          // Soft decorative background
          Positioned(
            top: -100,
            right: -80,
            child: _GlowCircle(
              size: 230,
              color: yellow.withOpacity(0.065),
            ),
          ),

          Positioned(
            top: 280,
            left: -120,
            child: _GlowCircle(
              size: 240,
              color: yellowDark.withOpacity(0.045),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              color: yellow,
              onRefresh: () async {
                await passengerProvider.fetchBuses();
                await passengerProvider.fetchStops();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HERO
                    // ==================================================

                    _buildHero(
                      totalBuses: buses.length,
                      availableBuses: availableBuses,
                      totalStops: passengerProvider.stops.length,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // SECTION HEADER
                    // ==================================================

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BUS MANAGEMENT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: yellowDark,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Managed Buses',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '${buses.length} buses',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // BUS LIST
                    // ==================================================

                    passengerProvider.isLoadingBuses
                        ? const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 70,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: yellow,
                        ),
                      ),
                    )
                        : buses.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: buses.length,
                      itemBuilder: (context, index) {
                        final bus = buses[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 14,
                          ),
                          child: _buildBusCard(bus),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // SYSTEM INFO
                    // ==================================================

                    _buildSystemInfo(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // HERO
  // ==================================================================

  Widget _buildHero({
    required int totalBuses,
    required int availableBuses,
    required int totalStops,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8B949),
            Color(0xFFD9A32D),
            Color(0xFFC99516),
          ],
          stops: [0.0, 0.48, 1.0],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: yellow.withOpacity(0.20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'College Transport',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Administration',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: Colors.white.withOpacity(0.16),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _buildHeroStat(
                  value: '$totalBuses',
                  label: 'Total Buses',
                  icon: Icons.directions_bus_rounded,
                ),
              ),
              _buildHeroDivider(),
              Expanded(
                child: _buildHeroStat(
                  value: '$availableBuses',
                  label: 'Available',
                  icon: Icons.event_available_rounded,
                ),
              ),
              _buildHeroDivider(),
              Expanded(
                child: _buildHeroStat(
                  value: '$totalStops',
                  label: 'Stops',
                  icon: Icons.place_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.white.withOpacity(0.85),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDivider() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.white.withOpacity(0.15),
    );
  }

  // ==================================================================
  // BUS CARD
  // ==================================================================

  Widget _buildBusCard(dynamic bus) {
    final bool isFull = bus.availableSeats <= 0;
    final bool isAlmostFull =
        bus.availableSeats > 0 && bus.availableSeats <= 5;

    final Color statusColor = isFull
        ? const Color(0xFFDC2626)
        : isAlmostFull
        ? const Color(0xFFD97706)
        : green;

    final String statusText = isFull
        ? 'FULL'
        : isAlmostFull
        ? 'ALMOST FULL'
        : 'AVAILABLE';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFE8E0C8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ----------------------------------------------------------
            // TOP
            // ----------------------------------------------------------

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF7DD),
                        Color(0xFFFFFCF5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: yellowDark,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BUS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bus.busNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------------
            // AVAILABLE SEATS
            // ----------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.055),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.event_seat_rounded,
                      size: 20,
                      color: statusColor,
                    ),
                  ),

                  const SizedBox(width: 11),

                  const Expanded(
                    child: Text(
                      'Available Seats',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                      ),
                    ),
                  ),

                  Text(
                    '${bus.availableSeats}',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            // ----------------------------------------------------------
            // PARKING
            // ----------------------------------------------------------

            _buildInfoRow(
              icon: Icons.local_parking_rounded,
              iconColor: yellowDark,
              label: 'Parked at',
              value:
              bus.parkingLocation?.toString() ??
                  'Not assigned',
            ),

            const SizedBox(height: 9),

            // ----------------------------------------------------------
            // STOPS
            // ----------------------------------------------------------

            _buildInfoRow(
              icon: Icons.route_rounded,
              iconColor: yellow,
              label: 'Stops',
              value: _buildStopsText(bus),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================================
  // INFO ROW
  // ==================================================================

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: iconColor,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================================================================
  // STOPS TEXT
  // ==================================================================

  String _buildStopsText(dynamic bus) {
    try {
      final stops = bus.stops;

      if (stops == null || stops.isEmpty) {
        return 'No stops assigned';
      }

      return stops
          .map<String>(
            (stop) => stop.name.toString(),
      )
          .join('  •  ');
    } catch (_) {
      return 'Stops assigned';
    }
  }

  // ==================================================================
  // EMPTY STATE
  // ==================================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E0C8),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 48,
            color: Color(0xFF888888),
          ),
          SizedBox(height: 12),
          Text(
            'No buses available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Bus information will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // SYSTEM INFO
  // ==================================================================

  Widget _buildSystemInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8D9A8),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: yellowDark,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bus information is synced with the BusSync system.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF66582F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// DECORATIVE CIRCLE
// ======================================================================

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
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