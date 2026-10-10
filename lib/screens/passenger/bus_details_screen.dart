import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/bus_model.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/status_badge.dart';

// ====================================================================
// BUSSYNC / YELLOW + BLACK PALETTE
// COLOR ONLY — LAYOUT UNCHANGED
// ====================================================================

const Color busYellow = Color(0xFFE8B949);
const Color busYellowDark = Color(0xFFC99516);
const Color busYellowLight = Color(0xFFFFF7DD);
const Color busYellowSoft = Color(0xFFFFFCF5);

const Color busBlack = Color(0xFF242424);
const Color busWhite = Color(0xFFFFFFFF);

const Color busTextDark = Color(0xFF252525);
const Color busTextMuted = Color(0xFF666666);
const Color busBorder = Color(0xFFE8E0C8);

class BusDetailsScreen extends StatefulWidget {
  final int busId;

  const BusDetailsScreen({
    super.key,
    required this.busId,
  });

  @override
  State<BusDetailsScreen> createState() =>
      _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  int _seatCount = 1;
  bool _isReserving = false;

  // ====================================================================
  // SEAT COUNTER
  // ====================================================================

  void _incrementSeats(int maxAvailable) {
    if (_seatCount < maxAvailable) {
      setState(() {
        _seatCount++;
      });
    }
  }

  void _decrementSeats() {
    if (_seatCount > 1) {
      setState(() {
        _seatCount--;
      });
    }
  }

  // ====================================================================
  // RESERVE SEATS
  // ====================================================================

  Future<void> _handleReserve(BusModel bus) async {
    if (bus.availableSeats <= 0) {
      _showError('No seats are currently available.');
      return;
    }

    if (_seatCount > bus.availableSeats) {
      _showError(
        'Only ${bus.availableSeats} seat'
            '${bus.availableSeats == 1 ? '' : 's'} available.',
      );
      return;
    }

    setState(() {
      _isReserving = true;
    });

    final passengerProvider =
    Provider.of<PassengerProvider>(
      context,
      listen: false,
    );

    try {
      await passengerProvider.reserveSeats(
        bus.id,
        _seatCount,
      );

      if (!mounted) return;

      final reservedCount = _seatCount;

      setState(() {
        _isReserving = false;
        _seatCount = 1;
      });

      _showSuccessDialog(
        bus,
        reservedCount,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isReserving = false;
      });

      final errorMessage =
      e.toString().replaceAll('Exception: ', '');

      _showError(
        errorMessage.isEmpty
            ? 'Unable to reserve seats. Please try again.'
            : errorMessage,
      );
    }
  }

  // ====================================================================
  // ERROR MESSAGE
  // ====================================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: busWhite,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ====================================================================
  // SUCCESS DIALOG
  // ====================================================================

  void _showSuccessDialog(
      BusModel bus,
      int reservedCount,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: busWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------------
                // SUCCESS ICON
                // ------------------------------------------------------

                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        busYellow,
                        busYellowDark,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: busYellow.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: busWhite,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------------
                // TITLE
                // ------------------------------------------------------

                const Text(
                  'Reservation Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: busTextDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 9),

                // ------------------------------------------------------
                // MESSAGE
                // ------------------------------------------------------

                Text(
                  '$reservedCount seat'
                      '${reservedCount == 1 ? '' : 's'} reserved successfully!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: busTextMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------------
                // BUS INFORMATION
                // ------------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        busYellowLight,
                        busYellowSoft,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: Color(0xFFE8D9A8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: busWhite,
                          borderRadius:
                          BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: busYellowDark,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BUS',
                              style: TextStyle(
                                color: busTextMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bus.busNumber,
                              style: const TextStyle(
                                color: busTextDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ------------------------------------------------------
                // REMAINING SEATS
                // ------------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: busYellowLight,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color(0xFFE8D9A8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_seat_rounded,
                        color: busYellowDark,
                        size: 21,
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Text(
                          'Seats still available',
                          style: TextStyle(
                            color: busTextMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${bus.availableSeats}',
                        style: const TextStyle(
                          color: busYellowDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ------------------------------------------------------
                // PARKING LOCATION
                // ------------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: busYellowLight,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color(0xFFE8D9A8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_parking_rounded,
                        color: busYellowDark,
                        size: 21,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PARKED AT',
                              style: TextStyle(
                                color: busYellowDark,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bus.parkingLocation,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: busTextDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------------
                // DONE BUTTON
                // ------------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: busBlack,
                      foregroundColor: busWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ====================================================================
  // BUILD
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    final passengerProvider =
    Provider.of<PassengerProvider>(context);

    final BusModel bus =
    passengerProvider.buses.firstWhere(
          (b) => b.id == widget.busId,
      orElse: () => BusModel(
        id: -1,
        busNumber: 'Bus',
        capacity: 0,
        studentsBoarded: 0,
        reservedSeats: 0,
        availableSeats: 0,
        lastUpdated: DateTime.now(),
        parkingLocation: 'Unknown',
        stops: [],
      ),
    );

    // ================================================================
    // BUS NOT FOUND
    // ================================================================

    if (bus.id == -1) {
      return Scaffold(
        backgroundColor: busYellowSoft,
        appBar: AppBar(
          backgroundColor: busYellowSoft,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: busTextDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Bus Details',
            style: TextStyle(
              color: busTextDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Bus details not found',
            style: TextStyle(
              color: busTextMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final bool hasAvailableSeats =
        bus.availableSeats > 0;

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final horizontalPadding =
    (screenWidth * 0.055).clamp(18.0, 26.0);

    // ================================================================
    // KEEP SELECTED SEATS VALID
    // ================================================================

    if (hasAvailableSeats &&
        _seatCount > bus.availableSeats) {
      _seatCount = bus.availableSeats;
    }

    if (!hasAvailableSeats && _seatCount != 1) {
      _seatCount = 1;
    }

    return Scaffold(
      backgroundColor: busYellowSoft,

      // ==============================================================
      // APP BAR
      // ==============================================================

      appBar: AppBar(
        backgroundColor: busYellowSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: busTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          bus.busNumber,
          style: const TextStyle(
            color: busTextDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ==============================================================
      // BODY
      // ==============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
            horizontalPadding,
            screenHeight * 0.035,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ========================================================
              // BUS HEADER
              // ========================================================

              _BusHeaderCard(
                bus: bus,
              ),

              const SizedBox(height: 15),

              // ========================================================
              // SEAT STATUS
              // ========================================================

              _SeatStatusCard(
                bus: bus,
                hasAvailableSeats:
                hasAvailableSeats,
              ),

              const SizedBox(height: 15),

              // ========================================================
              // RESERVATION CARD
              // ========================================================

              _ReservationCard(
                bus: bus,
                seatCount: _seatCount,
                isReserving: _isReserving,
                hasAvailableSeats:
                hasAvailableSeats,
                onDecrement: _decrementSeats,
                onIncrement: () =>
                    _incrementSeats(
                      bus.availableSeats,
                    ),
                onReserve: () =>
                    _handleReserve(bus),
              ),

              const SizedBox(height: 15),

              // ========================================================
              // PARKING LOCATION
              // ========================================================

              _ParkingLocationCard(
                parkingLocation:
                bus.parkingLocation,
              ),

              const SizedBox(height: 22),

              // ========================================================
              // STOPS
              // ========================================================

              _StopsSection(
                stops: bus.stops,
              ),

              const SizedBox(height: 28),

              // ========================================================
              // FOOTER
              // ========================================================

              const Center(
                child: Text(
                  'Check. Choose. Board.',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// BUS HEADER CARD
// ======================================================================

class _BusHeaderCard extends StatelessWidget {
  final BusModel bus;

  const _BusHeaderCard({
    required this.bus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            busYellowLight,
            busYellowSoft,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFFE8D9A8),
        ),
        boxShadow: [
          BoxShadow(
            color:
            busYellow.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  busYellow,
                  busYellowDark,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: busYellow.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: busWhite,
              size: 32,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'BUS',
                  style: TextStyle(
                    color: busTextMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bus.busNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: busTextDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose seats and reserve',
                  style: TextStyle(
                    color: busTextMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          StatusBadge(
            status: bus.busStatus,
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// SEAT STATUS CARD
// ======================================================================

class _SeatStatusCard extends StatelessWidget {
  final BusModel bus;
  final bool hasAvailableSeats;

  const _SeatStatusCard({
    required this.bus,
    required this.hasAvailableSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: busWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: busBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 17,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------------------
          // HEADER
          // ------------------------------------------------------------

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEAT STATUS',
                      style: TextStyle(
                        color: busYellowDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Current seat availability',
                      style: TextStyle(
                        color: busTextDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: bus.busStatus,
              ),
            ],
          ),

          const SizedBox(height: 17),

          // ------------------------------------------------------------
          // AVAILABLE + RESERVED
          // ------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _SeatMetric(
                  value: bus.availableSeats,
                  label: 'AVAILABLE',
                  icon: Icons.event_seat_rounded,
                  backgroundColor: hasAvailableSeats
                      ? busYellowLight
                      : const Color(0xFFFFF1F2),
                  borderColor: hasAvailableSeats
                      ? const Color(0xFFE8D9A8)
                      : const Color(0xFFFECDD3),
                  valueColor: hasAvailableSeats
                      ? busYellowDark
                      : const Color(0xFFDC2626),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _SeatMetric(
                  value: bus.reservedSeats,
                  label: 'RESERVED',
                  icon: Icons.bookmark_rounded,
                  backgroundColor:
                  const Color(0xFFF8F5EC),
                  borderColor:
                  busBorder,
                  valueColor:
                  busTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// SEAT METRIC
// ======================================================================

class _SeatMetric extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color valueColor;

  const _SeatMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: valueColor,
            size: 20,
          ),

          const SizedBox(height: 7),

          Text(
            '$value',
            style: TextStyle(
              color: valueColor,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: TextStyle(
              color: valueColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// RESERVATION CARD
// ======================================================================

class _ReservationCard extends StatelessWidget {
  final BusModel bus;
  final int seatCount;
  final bool isReserving;
  final bool hasAvailableSeats;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onReserve;

  const _ReservationCard({
    required this.bus,
    required this.seatCount,
    required this.isReserving,
    required this.hasAvailableSeats,
    required this.onDecrement,
    required this.onIncrement,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: busWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: busBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'HOW MANY SEATS DO YOU NEED?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: busTextMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Reserve seats for yourself or your friends',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 10.5,
            ),
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------------------
          // COUNTER
          // ------------------------------------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                enabled:
                hasAvailableSeats && seatCount > 1,
                onPressed: onDecrement,
              ),

              Container(
                width: 76,
                height: 58,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      busYellowLight,
                      busYellowSoft,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Color(0xFFE8D9A8),
                  ),
                ),
                child: Text(
                  '$seatCount',
                  style: const TextStyle(
                    color: busTextDark,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              _CounterButton(
                icon: Icons.add_rounded,
                enabled: hasAvailableSeats &&
                    seatCount < bus.availableSeats,
                onPressed: onIncrement,
              ),
            ],
          ),

          const SizedBox(height: 17),

          // ------------------------------------------------------------
          // RESERVE BUTTON
          // ------------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton.icon(
              onPressed:
              hasAvailableSeats && !isReserving
                  ? onReserve
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: busBlack,
                foregroundColor: busWhite,
                disabledBackgroundColor:
                const Color(0xFFD6D1C4),
                disabledForegroundColor:
                busWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: isReserving
                  ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  color: busWhite,
                  strokeWidth: 2.2,
                ),
              )
                  : const Icon(
                Icons.bookmark_add_rounded,
                size: 21,
              ),
              label: Text(
                isReserving
                    ? 'RESERVING...'
                    : hasAvailableSeats
                    ? 'RESERVE $seatCount '
                    'SEAT${seatCount == 1 ? '' : 'S'}'
                    : 'NO SEATS AVAILABLE',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// COUNTER BUTTON
// ======================================================================

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? busYellowLight
          : const Color(0xFFF5F1E8),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFE8D9A8)
                  : const Color(0xFFE2DDD1),
            ),
          ),
          child: Icon(
            icon,
            size: 23,
            color: enabled
                ? busYellowDark
                : const Color(0xFFB8B2A5),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// PARKING LOCATION CARD
// ======================================================================

class _ParkingLocationCard extends StatelessWidget {
  final String parkingLocation;

  const _ParkingLocationCard({
    required this.parkingLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: busWhite,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: busBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: busYellowLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_parking_rounded,
              color: busYellowDark,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT PARKING LOCATION',
                  style: TextStyle(
                    color: busYellowDark,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  parkingLocation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: busTextDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// STOPS SECTION
// ======================================================================

class _StopsSection extends StatelessWidget {
  final List<dynamic> stops;

  const _StopsSection({
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------------
        // HEADER
        // --------------------------------------------------------------

        Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUTE',
                    style: TextStyle(
                      color: busYellowDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Destination stops',
                    style: TextStyle(
                      color: busTextDark,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            if (stops.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: busWhite,
                  borderRadius:
                  BorderRadius.circular(20),
                  border: Border.all(
                    color: busBorder,
                  ),
                ),
                child: Text(
                  '${stops.length} '
                      '${stops.length == 1 ? 'stop' : 'stops'}',
                  style: const TextStyle(
                    color: busTextMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 5),

        const Text(
          'Choose this bus if your destination is listed below.',
          style: TextStyle(
            color: busTextMuted,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 12),

        // --------------------------------------------------------------
        // EMPTY
        // --------------------------------------------------------------

        if (stops.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: busWhite,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: busBorder,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.route_rounded,
                  size: 34,
                  color: Color(0xFF999999),
                ),
                SizedBox(height: 9),
                Text(
                  'No destination stops configured',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: busTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        // --------------------------------------------------------------
        // STOP LIST
        // --------------------------------------------------------------
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: busWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: busBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              padding:
              const EdgeInsets.symmetric(vertical: 6),
              itemCount: stops.length,
              separatorBuilder: (_, __) =>
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: Color(0xFFF0EDE5),
              ),
              itemBuilder: (context, index) {
                final stop = stops[index];

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient:
                          const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              busYellowLight,
                              busYellowSoft,
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(13),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: busYellowDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          stop.name,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: busTextDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.check_circle_rounded,
                        color: busYellowDark,
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}