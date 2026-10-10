import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/stop_model.dart';
import '../../providers/passenger_provider.dart';
import 'available_buses_screen.dart';

// ======================================================================
// BUSSYNC YELLOW / BLACK VISUAL SYSTEM
// ======================================================================

const Color yellow = Color(0xFFE8B949);
const Color yellowDark = Color(0xFFC99516);
const Color yellowLight = Color(0xFFFFF7DD);
const Color yellowSoft = Color(0xFFFFFCF5);

const Color black = Color(0xFF242424);
const Color white = Color(0xFFFFFFFF);

const Color textDark = Color(0xFF252525);
const Color textMuted = Color(0xFF666666);
const Color border = Color(0xFFE8E0C8);

// ======================================================================
// DESTINATION SELECTION SCREEN
// ======================================================================

class DestinationSelectionScreen extends StatefulWidget {
  const DestinationSelectionScreen({super.key});

  @override
  State<DestinationSelectionScreen> createState() =>
      _DestinationSelectionScreenState();
}

class _DestinationSelectionScreenState
    extends State<DestinationSelectionScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  List<StopModel> _filteredStops = [];

  // Only ONE recent destination is stored.
  String? _recentPick;

  @override
  void initState() {
    super.initState();

    _loadRecentPick();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PassengerProvider>(
        context,
        listen: false,
      ).fetchStops();
    });

    _searchController.addListener(_onSearchChanged);
  }

  // ====================================================================
  // LOAD LAST SELECTED DESTINATION
  // ====================================================================

  Future<void> _loadRecentPick() async {
    final prefs = await SharedPreferences.getInstance();

    final recentPick =
    prefs.getString('bussync_recent_pick');

    if (!mounted) return;

    setState(() {
      _recentPick = recentPick;
    });
  }

  // ====================================================================
  // SAVE LAST SELECTED DESTINATION
  // ====================================================================

  Future<void> _saveRecentPick(String stopName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'bussync_recent_pick',
      stopName,
    );

    if (!mounted) return;

    setState(() {
      _recentPick = stopName;
    });
  }

  // ====================================================================
  // SEARCH
  // ====================================================================

  void _onSearchChanged() {
    final query =
    _searchController.text.toLowerCase().trim();

    final passengerProvider =
    Provider.of<PassengerProvider>(
      context,
      listen: false,
    );

    setState(() {
      if (query.isEmpty) {
        _filteredStops = passengerProvider.stops;
      } else {
        _filteredStops = passengerProvider.stops
            .where(
              (stop) =>
              stop.name.toLowerCase().contains(query),
        )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ====================================================================
  // SELECT DESTINATION
  // ====================================================================

  Future<void> _proceedToBuses(
      StopModel? stop,
      ) async {
    if (stop == null || stop.id == -1) {
      return;
    }

    final passengerProvider =
    Provider.of<PassengerProvider>(
      context,
      listen: false,
    );

    // Existing provider logic remains unchanged.
    passengerProvider.selectStop(stop);

    // Replace the previous recent pick with this one.
    await _saveRecentPick(stop.name);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AvailableBusesScreen(),
      ),
    );
  }

  // ====================================================================
  // SELECT LAST DESTINATION
  // ====================================================================

  void _selectRecentPick(
      PassengerProvider provider,
      ) {
    if (_recentPick == null) {
      return;
    }

    final found = provider.stops.firstWhere(
          (stop) =>
      stop.name.toLowerCase() ==
          _recentPick!.toLowerCase(),
      orElse: () => StopModel(
        id: -1,
        name: _recentPick!,
      ),
    );

    if (found.id != -1) {
      _proceedToBuses(found);
    }
  }

  @override
  Widget build(BuildContext context) {
    final passengerProvider =
    Provider.of<PassengerProvider>(context);

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final horizontalPadding =
    (screenWidth * 0.055).clamp(18.0, 26.0);

    final stopsList =
    _searchController.text.trim().isEmpty
        ? passengerProvider.stops
        : _filteredStops;

    final isSearching =
        _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: yellowSoft,

      // ================================================================
      // APP BAR
      // ================================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: yellowSoft,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 6,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Your Bus',
          style: TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: yellowLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: border,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_bus_rounded,
                  size: 14,
                  color: yellowDark,
                ),
                SizedBox(width: 5),
                Text(
                  'BUSSYNC',
                  style: TextStyle(
                    color: yellowDark,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // ==========================================================
            // SUBTLE BACKGROUND DECORATION
            // ==========================================================

            Positioned(
              top: -screenWidth * 0.25,
              right: -screenWidth * 0.20,
              child: _DestinationCircle(
                size: screenWidth * 0.60,
                color: const Color(0x18E8B949),
              ),
            ),

            Positioned(
              bottom: -screenWidth * 0.30,
              left: -screenWidth * 0.25,
              child: _DestinationCircle(
                size: screenWidth * 0.62,
                color: const Color(0x12C99516),
              ),
            ),

            // ==========================================================
            // MAIN CONTENT
            // ==========================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // ====================================================
                  // HERO
                  // ====================================================

                  const _SearchHero(),

                  const SizedBox(height: 16),

                  // ====================================================
                  // SEARCH
                  // ====================================================

                  _DestinationSearchField(
                    controller: _searchController,
                  ),

                  const SizedBox(height: 18),

                  // ====================================================
                  // SEARCHING MODE
                  // ====================================================

                  if (isSearching)
                    _SearchResultsHeader(
                      resultCount: stopsList.length,
                    )
                  else ...[
                    // ==================================================
                    // LAST SELECTED DESTINATION
                    // ==================================================

                    if (_recentPick != null) ...[
                      const _SectionHeader(
                        eyebrow: 'RECENT',
                        title: 'Recent pick',
                        icon: Icons.history_rounded,
                        iconColor: yellowDark,
                      ),

                      const SizedBox(height: 10),

                      _RecentPickCard(
                        stopName: _recentPick!,
                        onTap: () =>
                            _selectRecentPick(
                              passengerProvider,
                            ),
                      ),

                      const SizedBox(height: 18),
                    ],

                    // ==================================================
                    // ALL DESTINATIONS HEADER
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: _SectionHeader(
                            eyebrow: 'DESTINATIONS',
                            title: 'Browse all stops',
                            icon: Icons.place_rounded,
                            iconColor: yellowDark,
                          ),
                        ),
                        if (!passengerProvider
                            .isLoadingStops)
                          _CountBadge(
                            count: stopsList.length,
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],

                  // ====================================================
                  // DESTINATION LIST
                  // ====================================================

                  Expanded(
                    child:
                    passengerProvider.isLoadingStops
                        ? const _LoadingStops()
                        : stopsList.isEmpty
                        ? _EmptyStopsView(
                      searchText:
                      _searchController
                          .text,
                    )
                        : ListView.builder(
                      physics:
                      const BouncingScrollPhysics(),
                      padding:
                      const EdgeInsets.only(
                        top: 2,
                        bottom: 24,
                      ),
                      itemCount:
                      stopsList.length,
                      itemBuilder:
                          (context, index) {
                        final stop =
                        stopsList[index];

                        return _DestinationCard(
                          stop: stop,
                          index: index,
                          onTap: () =>
                              _proceedToBuses(
                                stop,
                              ),
                        );
                      },
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

// ======================================================================
// SEARCH HERO
// ======================================================================

class _SearchHero extends StatelessWidget {
  const _SearchHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            yellowLight,
            yellowSoft,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                  yellowDark.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    yellow,
                    yellowDark,
                  ],
                ),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_searching_rounded,
                color: white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'WHERE ARE YOU HEADING?',
                  style: TextStyle(
                    color: yellowDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Find a destination',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Choose a stop to see available buses.',
                  style: TextStyle(
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

// ======================================================================
// SEARCH FIELD
// ======================================================================

class _DestinationSearchField extends StatelessWidget {
  final TextEditingController controller;

  const _DestinationSearchField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            yellowDark.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 13,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: yellowLight,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: yellowDark,
              size: 20,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: textMuted,
            ),
            onPressed: () {
              controller.clear();
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// SECTION HEADER
// ======================================================================

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
            iconColor.withValues(alpha: 0.10),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: yellowDark,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: textDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ======================================================================
// RECENT PICK CARD
// ======================================================================

class _RecentPickCard extends StatelessWidget {
  final String stopName;
  final VoidCallback onTap;

  const _RecentPickCard({
    required this.stopName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: border,
            ),
            boxShadow: [
              BoxShadow(
                color:
                black.withValues(alpha: 0.035),
                blurRadius: 11,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient:
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      yellow,
                      yellowDark,
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR LAST DESTINATION',
                      style: TextStyle(
                        color: yellowDark,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stopName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: yellowLight,
                  borderRadius:
                  BorderRadius.circular(11),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: yellowDark,
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
// SEARCH RESULTS HEADER
// ======================================================================

class _SearchResultsHeader extends StatelessWidget {
  final int resultCount;

  const _SearchResultsHeader({
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'SEARCH RESULTS',
                style: TextStyle(
                  color: yellowDark,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Matching destinations',
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _CountBadge(count: resultCount),
      ],
    );
  }
}

// ======================================================================
// COUNT BADGE
// ======================================================================

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: yellowLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),
      child: Text(
        '$count ${count == 1 ? 'stop' : 'stops'}',
        style: const TextStyle(
          color: yellowDark,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ======================================================================
// DESTINATION CARD
// ======================================================================

class _DestinationCard extends StatelessWidget {
  final StopModel stop;
  final int index;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.stop,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            black.withValues(alpha: 0.035),
            blurRadius: 11,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            child: Row(
              children: [
                // ------------------------------------------------------
                // NUMBER
                // ------------------------------------------------------

                Container(
                  width: 38,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient:
                    const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        yellow,
                        yellowDark,
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(width: 11),

                // ------------------------------------------------------
                // DESTINATION
                // ------------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons
                                .directions_bus_outlined,
                            size: 13,
                            color: textMuted,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View buses for this stop',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------------
                // ARROW
                // ------------------------------------------------------

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: yellowLight,
                    borderRadius:
                    BorderRadius.circular(11),
                    border: Border.all(
                      color: border,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: yellowDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// LOADING
// ======================================================================

class _LoadingStops extends StatelessWidget {
  const _LoadingStops();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 60,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient:
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    yellowLight,
                    yellowSoft,
                  ],
                ),
                borderRadius:
                BorderRadius.circular(21),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: yellowDark,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Loading destinations',
              style: TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Finding available stops...',
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

// ======================================================================
// EMPTY SEARCH RESULT
// ======================================================================

class _EmptyStopsView extends StatelessWidget {
  final String searchText;

  const _EmptyStopsView({
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final hasSearch =
        searchText.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: yellowLight,
                borderRadius:
                BorderRadius.circular(23),
                border: Border.all(
                  color: border,
                ),
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.location_off_rounded,
                size: 34,
                color: yellowDark,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              hasSearch
                  ? 'No destination found'
                  : 'No destinations available',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try searching with a different destination name.'
                  : 'There are no stops available right now.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// BACKGROUND CIRCLE
// ======================================================================

class _DestinationCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DestinationCircle({
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