import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import 'status_badge.dart';

class BusCard extends StatelessWidget {
  final BusModel bus;
  final VoidCallback onTap;

  const BusCard({
    super.key,
    required this.bus,
    required this.onTap,
  });

  // Current BusSync theme
  static const Color yellow = Color(0xFFE8B949);
  static const Color yellowDark = Color(0xFFC99516);
  static const Color yellowLight = Color(0xFFFFF7DD);
  static const Color yellowSoft = Color(0xFFFFFCF5);

  static const Color black = Color(0xFF242424);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF252525);
  static const Color textMuted = Color(0xFF666666);
  static const Color border = Color(0xFFE8E0C8);

  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFEAF8EF);
  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFDECEC);

  @override
  Widget build(BuildContext context) {
    final bool hasSeats = bus.availableSeats > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasSeats ? yellow.withOpacity(0.75) : border,
          width: hasSeats ? 1.2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------
            // TOP THEME BAR
            // ----------------------------------------------------------
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: hasSeats
                    ? const LinearGradient(
                  colors: [
                    yellow,
                    yellowDark,
                  ],
                )
                    : const LinearGradient(
                  colors: [
                    black,
                    Color(0xFF444444),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------------------------------------------
                  // BUS HEADER
                  // ----------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: black,
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: yellow,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // FIXED:
                                    // Prevents "Bus Bus 570"
                                    bus.busNumber,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 3),

                                  const Text(
                                    'Available for your trip',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
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

                  const SizedBox(height: 14),

                  // ----------------------------------------------------
                  // AVAILABLE SEATS
                  // ----------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: hasSeats
                          ? yellowLight
                          : redLight,
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color: hasSeats
                            ? yellow.withOpacity(0.65)
                            : red.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: hasSeats
                                ? yellow
                                : red,
                            borderRadius:
                            BorderRadius.circular(9),
                          ),
                          child: Icon(
                            Icons.event_seat_rounded,
                            size: 18,
                            color: hasSeats
                                ? black
                                : white,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bus.availableSeats} AVAILABLE',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: hasSeats
                                    ? black
                                    : red,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              hasSeats
                                  ? 'Seats ready to reserve'
                                  : 'No seats remaining',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w500,
                                color: hasSeats
                                    ? yellowDark
                                    : red.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ----------------------------------------------------
                  // PARKING LOCATION
                  // ----------------------------------------------------
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: yellowSoft,
                      borderRadius:
                      BorderRadius.circular(10),
                      border: Border.all(
                        color: border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: yellowLight,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_parking_rounded,
                            size: 17,
                            color: yellowDark,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PARKED AT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: yellowDark,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                bus.parkingLocation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: textDark,
                                ),
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ----------------------------------------------------
                  // STOPS
                  // ----------------------------------------------------
                  if (bus.stops.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.alt_route_rounded,
                          size: 16,
                          color: yellowDark,
                        ),

                        const SizedBox(width: 5),

                        const Text(
                          'ROUTE STOPS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: yellowDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: bus.stops.map((stop) {
                        return Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: yellowSoft,
                            borderRadius:
                            BorderRadius.circular(8),
                            border: Border.all(
                              color: border,
                            ),
                          ),
                          child: Text(
                            stop.name,
                            style: const TextStyle(
                              fontSize: 10,
                              color: textDark,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ----------------------------------------------------
                  // VIEW DETAILS
                  // ----------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: border,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: hasSeats
                                    ? yellowDark
                                    : red,
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 7),

                            const Text(
                              'Tap to view bus details',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: black,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}