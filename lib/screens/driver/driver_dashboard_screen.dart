import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../models/stop_model.dart';
import '../../models/parking_location_model.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final TextEditingController _stopSearchController =
  TextEditingController();

  List<StopModel> _filteredStopSuggestions = [];

  // ================================================================
  // INITIALIZATION
  // ================================================================

  @override
  void initState() {
    super.initState();

    _stopSearchController.addListener(_onStopSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).token;

      if (token != null) {
        Provider.of<DriverProvider>(
          context,
          listen: false,
        ).fetchDriverData(token);
      }
    });
  }

  // ================================================================
  // STOP SEARCH
  // ================================================================

  void _onStopSearchChanged() {
    final query = _stopSearchController.text.trim().toLowerCase();

    final driverProvider = Provider.of<DriverProvider>(
      context,
      listen: false,
    );

    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        _filteredStopSuggestions = [];
      } else {
        _filteredStopSuggestions = driverProvider.allStops
            .where(
              (stop) =>
          stop.name.toLowerCase().contains(query) &&
              !driverProvider.selectedStops.contains(stop),
        )
            .toList();
      }
    });
  }

  // ================================================================
  // SAVE / PUBLISH
  // ================================================================

  Future<void> _handleSave() async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final driverProvider = Provider.of<DriverProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null) return;

    final success = await driverProvider.saveBusUpdate(token);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bus location and stops updated successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    _stopSearchController.removeListener(_onStopSearchChanged);
    _stopSearchController.dispose();
    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverProvider = Provider.of<DriverProvider>(context);

    final assignedBus = driverProvider.assignedBus;

    // ---------------------------------------------------------------
    // LOADING
    // ---------------------------------------------------------------

    if (driverProvider.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFCF5),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(17),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFE8B949),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Loading your bus...',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ---------------------------------------------------------------
    // NO BUS
    // ---------------------------------------------------------------

    if (assignedBus == null) {
      return _buildNoBusAssigned(
        context,
        authProvider,
        driverProvider,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),

      // ==============================================================
      // APP BAR
      // ==============================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF5),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7DD),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: Color(0xFFE8B949),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver Dashboard',
                  style: TextStyle(
                    color: Color(0xFF242424),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'BusSync Transport',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              final token = authProvider.token;

              if (token != null) {
                await driverProvider.fetchDriverData(token);
              }
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF666666),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),

      // ==============================================================
      // BODY
      // ==============================================================

      body: RefreshIndicator(
        color: const Color(0xFFE8B949),
        backgroundColor: Colors.white,
        onRefresh: () async {
          final token = authProvider.token;

          if (token != null) {
            await driverProvider.fetchDriverData(token);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBusHero(
                assignedBus.busNumber,
              ),

              const SizedBox(height: 18),

              if (driverProvider.errorMessage != null) ...[
                _buildErrorBanner(
                  driverProvider.errorMessage!,
                ),
                const SizedBox(height: 18),
              ],

              const _DashboardSectionHeader(
                eyebrow: 'BUS MANAGEMENT',
                title: 'Update your bus',
                subtitle:
                'Keep your parking location and destination stops accurate.',
                icon: Icons.edit_road_rounded,
              ),

              const SizedBox(height: 16),

              _buildParkingCard(
                context,
                driverProvider,
              ),

              const SizedBox(height: 14),

              _buildStopsCard(
                context,
                driverProvider,
              ),

              const SizedBox(height: 20),

              _buildPublishCard(
                context,
                driverProvider,
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'BusSync • Check. Choose. Board.',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BUS HERO
  // ================================================================

  Widget _buildBusHero(String busNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8B949),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B949).withOpacity(0.22),
            blurRadius: 25,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASSIGNED BUS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      busNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'DRIVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // IMPORTANT WARNING
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              13,
              12,
              13,
              12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7DD),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFD5A62A),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B949),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF5A4510),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMPORTANT',
                        style: TextStyle(
                          color: Color(0xFF765A14),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Keep your parking location and route stops updated.',
                        style: TextStyle(
                          color: Color(0xFF2F2A1F),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Students use this information to find the right bus.',
                        style: TextStyle(
                          color: Color(0xFF6B6040),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
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
    );
  }

  // ================================================================
  // PARKING CARD
  // ================================================================

  Widget _buildParkingCard(
      BuildContext context,
      DriverProvider driverProvider,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8B949),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B949).withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7DD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '1  •  PARKING LOCATION',
              style: TextStyle(
                color: Color(0xFFE8B949),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 11),

          const _MiniCardHeader(
            icon: Icons.local_parking_rounded,
            title: 'Parking location',
            subtitle:
            'Where is your bus currently parked?',
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<ParkingLocationModel>(
            value:
            driverProvider.selectedParkingLocation,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Choose parking location',
              filled: true,
              fillColor: const Color(0xFFFFFCF5),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
              ),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E7EF),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E7EF),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE8B949),
                  width: 1.5,
                ),
              ),
            ),
            items: driverProvider.parkingLocations
                .map(
                  (location) =>
                  DropdownMenuItem<
                      ParkingLocationModel>(
                    value: location,
                    child: Text(
                      location.name,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
            )
                .toList(),
            onChanged: (value) {
              driverProvider.setParkingLocation(
                value,
              );
            },
          ),

          const SizedBox(height: 11),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7DD),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: Color(0xFFE8B949),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Students will see this location when choosing a bus.',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10.5,
                      height: 1.3,
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

  // ================================================================
  // STOPS CARD
  // ================================================================

  Widget _buildStopsCard(
      BuildContext context,
      DriverProvider driverProvider,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8B949),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B949).withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7DD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '2  •  BUS STOPS',
              style: TextStyle(
                color: Color(0xFFE8B949),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              const Expanded(
                child: _MiniCardHeader(
                  icon: Icons.alt_route_rounded,
                  title: 'Bus stops',
                  subtitle:
                  'Choose every stop served by this bus.',
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B949)
                      .withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  '${driverProvider.selectedStops.length}',
                  style: const TextStyle(
                    color: Color(0xFFE8B949),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _stopSearchController,
            textInputAction:
            TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search for a stop...',
              filled: true,
              fillColor:
              const Color(0xFFFFFCF5),
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
              suffixIcon:
              _stopSearchController.text
                  .isNotEmpty
                  ? IconButton(
                tooltip: 'Clear',
                icon: const Icon(
                  Icons.close_rounded,
                ),
                onPressed: () {
                  _stopSearchController
                      .clear();
                },
              )
                  : null,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E7EF),
                ),
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E7EF),
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE8B949),
                  width: 1.5,
                ),
              ),
            ),
          ),

          if (_filteredStopSuggestions.isNotEmpty) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF5),
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFE4EAF1),
                ),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding:
                    EdgeInsets.fromLTRB(
                      14,
                      11,
                      14,
                      7,
                    ),
                    child: Align(
                      alignment:
                      Alignment.centerLeft,
                      child: Text(
                        'MATCHING STOPS',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  ..._filteredStopSuggestions
                      .take(6)
                      .map(
                        (stop) => InkWell(
                      onTap: () {
                        driverProvider
                            .addStop(stop);

                        _stopSearchController
                            .clear();

                        FocusScope.of(
                          context,
                        ).unfocus();
                      },
                      child: Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFE8B949,
                                ).withOpacity(
                                  0.10,
                                ),
                                shape:
                                BoxShape
                                    .circle,
                              ),
                              child:
                              const Icon(
                                Icons.add_rounded,
                                color:
                                Color(
                                  0xFFE8B949,
                                ),
                                size: 18,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                stop.name,
                                style:
                                const TextStyle(
                                  color:
                                  Color(
                                    0xFF333333,
                                  ),
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons
                                  .chevron_right_rounded,
                              color:
                              Color(
                                0xFF888888,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          Text(
            'SELECTED STOPS',
            style:
            theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF777777),
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          if (driverProvider.selectedStops.isEmpty)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF5),
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE7ECF2),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.alt_route_rounded,
                    size: 30,
                    color: Color(0xFF888888),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No stops selected',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Search above to add your route stops',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
              driverProvider.selectedStops
                  .map(
                    (stop) {
                  return Container(
                    padding:
                    const EdgeInsets
                        .only(
                      left: 11,
                      right: 3,
                      top: 5,
                      bottom: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFE8B949,
                      ).withOpacity(0.10),
                      borderRadius:
                      BorderRadius
                          .circular(
                        24,
                      ),
                      border:
                      Border.all(
                        color:
                        const Color(
                          0xFFE8B949,
                        ).withOpacity(0.20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .location_on_rounded,
                          size: 14,
                          color:
                          Color(
                            0xFFE8B949,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          stop.name,
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF333333,
                            ),
                            fontSize: 12,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                        IconButton(
                          constraints:
                          const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding:
                          EdgeInsets.zero,
                          iconSize: 16,
                          tooltip:
                          'Remove stop',
                          icon:
                          const Icon(
                            Icons
                                .close_rounded,
                            color:
                            Color(
                              0xFFE8B949,
                            ),
                          ),
                          onPressed: () {
                            driverProvider
                                .removeStop(
                              stop,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              )
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // PUBLISH CARD
  // ================================================================

  Widget _buildPublishCard(
      BuildContext context,
      DriverProvider driverProvider,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8B949),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(
                        0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: Color(0xFFE8B949),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to publish?',
                      style: TextStyle(
                        color: Color(0xFF242424),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Students will see your updated route information.',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: Material(
              borderRadius:
              BorderRadius.circular(15),
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(15),
                  onTap: driverProvider.isSaving
                      ? null
                      : _handleSave,
                  child: Center(
                    child: driverProvider.isSaving
                        ? const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Publishing update...',
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    )
                        : const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.publish_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Publish Bus Location & Stops',
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ERROR BANNER
  // ================================================================

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF5C6C6),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD64545),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NO BUS ASSIGNED
  // ================================================================

  Widget _buildNoBusAssigned(
      BuildContext context,
      AuthProvider authProvider,
      DriverProvider driverProvider,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFFFFFCF5),
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(
            color: Color(0xFF242424),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF666666),
            ),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFFE4EAF2),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(
                    0.035,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration:
                  const BoxDecoration(
                    color: Color(0xFFFFF7DD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .directions_bus_outlined,
                    size: 42,
                    color:
                    Color(0xFFE8B949),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'No Bus Assigned',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color:
                    Color(0xFF242424),
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  driverProvider
                      .errorMessage ??
                      'Please contact the system administrator.',
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFFF7DD,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                  child: const Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .info_outline_rounded,
                        size: 16,
                        color:
                        Color(0xFFE8B949),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Contact your administrator',
                        style: TextStyle(
                          color:
                          Color(
                            0xFF666666,
                          ),
                          fontSize: 10.5,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
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
// DASHBOARD SECTION HEADER
// ======================================================================

class _DashboardSectionHeader
    extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  const _DashboardSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7DD),
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE8B949),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xFFE8B949),
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF242424),
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// MINI CARD HEADER
// ======================================================================

class _MiniCardHeader
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MiniCardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8B949)
                .withOpacity(0.10),
            borderRadius:
            BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE8B949),
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF242424),
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}