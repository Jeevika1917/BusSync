import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/passenger_provider.dart';
import '../../widgets/bus_card.dart';
import '../../widgets/error_view.dart';
import 'bus_details_screen.dart';

// ================================================================
// BUSSYNC CURRENT YELLOW + BLACK THEME
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

class AvailableBusesScreen extends StatefulWidget {
  const AvailableBusesScreen({super.key});

  @override
  State<AvailableBusesScreen> createState() =>
      _AvailableBusesScreenState();
}

class _AvailableBusesScreenState extends State<AvailableBusesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PassengerProvider>(
        context,
        listen: false,
      ).fetchBuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PassengerProvider>(context);

    final selectedStop = provider.selectedStop;
    final buses = provider.buses;

    final size = MediaQuery.of(context).size;
    final width = size.width;

    final horizontalPadding =
    (width * 0.055).clamp(18.0, 26.0);

    return Scaffold(
      backgroundColor: yellowSoft,

      // ==============================================================
      // APP BAR
      // ==============================================================

      appBar: AppBar(
        backgroundColor: yellowSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 6,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: textDark,
          ),
        ),

        title: const Text(
          'Available Buses',
          style: TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 10,
              top: 7,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: border,
              ),
            ),
            child: IconButton(
              tooltip: 'Refresh',
              onPressed: provider.isLoadingBuses
                  ? null
                  : () => provider.fetchBuses(),
              icon: const Icon(
                Icons.refresh_rounded,
                color: yellowDark,
                size: 21,
              ),
            ),
          ),
        ],
      ),

      // ==============================================================
      // BODY
      // ==============================================================

      body: Stack(
        children: [
          Positioned(
            top: -width * 0.22,
            right: -width * 0.18,
            child: _BackgroundCircle(
              size: width * 0.55,
              color: yellow.withValues(alpha: 0.10),
            ),
          ),

          Positioned(
            bottom: -width * 0.25,
            left: -width * 0.22,
            child: _BackgroundCircle(
              size: width * 0.58,
              color: yellowDark.withValues(alpha: 0.055),
            ),
          ),

          SafeArea(
            top: false,
            child: Column(
              children: [
                // ====================================================
                // DESTINATION HERO
                // ====================================================

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    4,
                    horizontalPadding,
                    0,
                  ),
                  child: _DestinationHero(
                    stopName: selectedStop?.name,
                  ),
                ),

                const SizedBox(height: 14),

                // ====================================================
                // SECTION HEADER
                // ====================================================

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BUS OPTIONS',
                              style: TextStyle(
                                color: yellowDark,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Choose your bus',
                              style: TextStyle(
                                color: textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!provider.isLoadingBuses &&
                          provider.busesError == null &&
                          buses.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: yellowLight,
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                              color: border,
                            ),
                          ),
                          child: Text(
                            '${buses.length} ${buses.length == 1 ? 'bus' : 'buses'}',
                            style: const TextStyle(
                              color: yellowDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ====================================================
                // BUS CONTENT
                // ====================================================

                Expanded(
                  child: provider.isLoadingBuses
                      ? const _LoadingState()
                      : provider.busesError != null
                      ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: ErrorView(
                      message: provider.busesError!,
                      onRetry: () =>
                          provider.fetchBuses(),
                    ),
                  )
                      : buses.isEmpty
                      ? _EmptyBusState(
                    selectedStop:
                    selectedStop?.name,
                  )
                      : RefreshIndicator(
                    color: yellowDark,
                    backgroundColor: white,
                    onRefresh: () =>
                        provider.fetchBuses(),
                    child: ListView.builder(
                      physics:
                      const AlwaysScrollableScrollPhysics(
                        parent:
                        BouncingScrollPhysics(),
                      ),
                      padding:
                      EdgeInsets.fromLTRB(
                        horizontalPadding,
                        2,
                        horizontalPadding,
                        32,
                      ),
                      itemCount: buses.length,
                      itemBuilder:
                          (context, index) {
                        final bus =
                        buses[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 2,
                          ),
                          child: BusCard(
                            bus: bus,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BusDetailsScreen(
                                        busId: bus.id,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
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

// ============================================================================
// DESTINATION HERO
// ============================================================================

class _DestinationHero extends StatelessWidget {
  final String? stopName;

  const _DestinationHero({
    required this.stopName,
  });

  @override
  Widget build(BuildContext context) {
    final hasDestination = stopName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: yellowLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: black,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              hasDestination
                  ? Icons.location_on_rounded
                  : Icons.directions_bus_rounded,
              color: yellow,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  hasDestination
                      ? 'BUSES GOING TO'
                      : 'AVAILABLE BUSES',
                  style: const TextStyle(
                    color: yellowDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasDestination
                      ? stopName!
                      : 'All destinations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasDestination
                      ? 'Choose a bus with available seats'
                      : 'Currently registered buses',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
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

// ============================================================================
// LOADING
// ============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: yellowLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: yellowDark,
                ),
              ),
            ),

            const SizedBox(height: 17),

            const Text(
              'Finding available buses',
              style: TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Checking current seat availability...',
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyBusState extends StatelessWidget {
  final String? selectedStop;

  const _EmptyBusState({
    required this.selectedStop,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: yellowLight,
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Icon(
                Icons.directions_bus_filled_outlined,
                size: 41,
                color: yellowDark,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              selectedStop != null
                  ? 'No buses available'
                  : 'No buses registered',
              style: const TextStyle(
                color: textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              selectedStop != null
                  ? 'No buses are currently serving "$selectedStop".'
                  : 'There are no buses currently registered.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Try another destination or refresh again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BACKGROUND
// ============================================================================

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