//  import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:royalcontinent/group/common/theme/theme.dart';
// import 'package:royalcontinent/group/controllers/search_controller.dart'
//     as search_ctrl;
// import 'package:royalcontinent/group/controllers/hotel_controller.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// //  THEME CONSTANTS  — White / Gold / Primary accent
// // ─────────────────────────────────────────────────────────────────────────────
// class _T {
//   static Color get bg => Colors.white;
//   static Color get surface => const Color(0xFFF7F5F0);
//   static Color get chipBg => Colors.white;

//   static const Color gold = Color(0xFFC9A84C);
//   static const Color goldLight = Color(0xFFE8CC80);
//   static const Color goldDim = Color(0xFF9A7A35);

//   static Color get textPrimary => const Color(0xFF1A1A1A);
//   static Color get textSub => const Color(0xFF555555);
//   static Color get textMuted => const Color(0xFF999999);

//   static const Color border = Color(0xFFE5DEC8);
//   static const Color divider = Color(0xFFEEE8D8);

//   static Color get panel => Colors.white;
//   static Color get panelDark => const Color(0xFFF2EFE8);
// }

// // ─────────────────────────────────────────────────────────────────────────────
// //  SEARCH WIDGET
// // ─────────────────────────────────────────────────────────────────────────────
// class SearchWidget extends StatefulWidget {
//   final bool update;
//   final bool showEditText;
//   final VoidCallback? onModifySearch;

//   const SearchWidget({
//     super.key,
//     this.update = false,
//     this.showEditText = false,
//     this.onModifySearch,
//   });

//   @override
//   State<SearchWidget> createState() => _SearchWidgetState();
// }

// class _SearchWidgetState extends State<SearchWidget>
//     with TickerProviderStateMixin {
//   // ── State ──────────────────────────────────────────────────────────────────
//   DateTime checkIn = DateTime.now().add(const Duration(days: 1));
//   DateTime checkOut = DateTime.now().add(const Duration(days: 2));
//   int rooms = 1;
//   List<Map<String, dynamic>> roomGuests = [];
//   String propertyCode = '';
//   String? hotelLogoUrl;
//   String hotelName = '';
//   bool _showGuestDetails = false;
//   bool _showFullSearch = false;
//   late HotelController hotelCtrl;
//   int selectedHotelIndex = 0;
//   List<dynamic> childHotels = [];

//   // ── Animations ─────────────────────────────────────────────────────────────
//   late AnimationController _panelCtrl;
//   late AnimationController _shimmerCtrl;
//   late Animation<double> _panelFade;

//   // ── Hotel selector scroll controller ───────────────────────────────────────
//   final ScrollController _hotelScrollCtrl = ScrollController();

//   // ── Derived ────────────────────────────────────────────────────────────────
//   int get totalChildren =>
//       roomGuests.fold<int>(0, (s, r) => s + (r['children'] as int));
//   int get totalAdults =>
//       roomGuests.fold<int>(0, (s, r) => s + (r['adults'] as int));
//   int get totalGuests => totalAdults + totalChildren;
//   int get remainingSlots => (4 * rooms) - totalGuests;
//   int get totalNights => checkOut.difference(checkIn).inDays;

//   @override
//   void initState() {
//     super.initState();
//     hotelCtrl = Get.find<HotelController>();
//     _initializeRoomGuests();
//     _loadConfig();
//     _loadFromController();

//     _panelCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 380),
//     );
//     _panelFade = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeInOut);

//     _shimmerCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2600),
//     )..repeat();
//   }

//   void _initializeRoomGuests() {
//     roomGuests = List.generate(
//       rooms,
//       (_) => {'adults': 1, 'children': 0, 'childAges': <int>[]},
//     );
//   }

//   @override
//   void dispose() {
//     _panelCtrl.dispose();
//     _shimmerCtrl.dispose();
//     _hotelScrollCtrl.dispose();
//     super.dispose();
//   }

//   // ── Config / controller ────────────────────────────────────────────────────
//   void _loadConfig() async {
//     try {
//       final raw = await rootBundle.loadString('assets/config.json');
//       final config = json.decode(raw);
//       final childHotels = config['childHotels'] as List? ?? [];

//       setState(() {
//         this.childHotels = childHotels;
//         if (childHotels.isNotEmpty) {
//           final defaultHotel = childHotels[0];
//           selectedHotelIndex = 0;
//           propertyCode = defaultHotel['code'] ?? config['code'] ?? '';
//           hotelName = defaultHotel['name'] ?? config['name'] ?? '';
//           hotelLogoUrl = defaultHotel['config']?['branding']?['logo'] ??
//               config['config']?['branding']?['logo'];
//           hotelCtrl.setSelectedHotel(defaultHotel);
//         } else {
//           propertyCode = config['code'] ?? '';
//           hotelName = config['name'] ?? '';
//           hotelLogoUrl = config['config']?['branding']?['logo'];
//         }
//       });
//     } catch (e) {
//       debugPrint('Config load error: $e');
//     }
//   }

//   void _loadFromController() {
//     final ctrl = Get.find<search_ctrl.AppSearchController>();
//     if (ctrl.searchPayload.isNotEmpty) {
//       final p = Map<String, dynamic>.from(ctrl.searchPayload.value);
//       setState(() {
//         checkIn = DateTime.parse(p['startDate']);
//         checkOut = DateTime.parse(p['endDate']);
//         final g = p['guests'] as Map<String, dynamic>;
//         rooms = g['rooms'] as int? ?? 1;
//         if (g['roomsArray'] != null) {
//           roomGuests = (g['roomsArray'] as List)
//               .map(
//                 (r) => {
//                   'adults': r['adults'] as int,
//                   'children': r['children'] as int,
//                   'childAges': List<int>.from(r['childAges'] ?? []),
//                 },
//               )
//               .toList();
//         } else {
//           roomGuests = List.generate(
//             rooms,
//             (_) => {'adults': 1, 'children': 0, 'childAges': <int>[]},
//           );
//         }
//       });
//     }
//   }

//   // ── Mutation ───────────────────────────────────────────────────────────────
//   void updateRooms(int n) {
//     setState(() {
//       rooms = n;
//       if (n > roomGuests.length) {
//         roomGuests.addAll(
//           List.generate(
//             n - roomGuests.length,
//             (_) => {'adults': 1, 'children': 0, 'childAges': <int>[]},
//           ),
//         );
//       } else if (n < roomGuests.length) {
//         roomGuests = roomGuests.sublist(0, n);
//       }
//     });
//   }

//   void updateAdults(int i, int v) {
//     if (v + roomGuests[i]['children']! <= 4 && v >= 1) {
//       setState(() => roomGuests[i]['adults'] = v);
//     }
//   }

//   void updateChildren(int i, int v) {
//     final currentAdults = roomGuests[i]['adults'] as int;
//     final currentChildren = roomGuests[i]['children'] as int;
//     final currentAges = List<int>.from(roomGuests[i]['childAges'] ?? []);
//     if (currentAdults + v <= 4 && v >= 0) {
//       setState(() {
//         roomGuests[i]['children'] = v;
//         if (v > currentChildren) {
//           final childrenToAdd = v - currentChildren;
//           roomGuests[i]['childAges'] = [
//             ...currentAges,
//             ...List.generate(childrenToAdd, (_) => 0),
//           ];
//         } else if (v < currentChildren) {
//           roomGuests[i]['childAges'] = currentAges.sublist(0, v);
//         }
//       });
//     }
//   }

//   void updateChildAge(int roomIndex, int childIndex, int age) {
//     if (age >= 0 && age <= 15) {
//       setState(() {
//         final ages = List<int>.from(roomGuests[roomIndex]['childAges'] ?? []);
//         if (childIndex < ages.length) {
//           ages[childIndex] = age;
//           roomGuests[roomIndex]['childAges'] = ages;
//         }
//       });
//     }
//   }

//   // ── Hotel selection ────────────────────────────────────────────────────────
//   void _selectHotel(int index) {
//     if (index >= childHotels.length) return;
//     final selectedHotel = childHotels[index];
//     hotelCtrl.setSelectedHotel(selectedHotel);
//     setState(() {
//       selectedHotelIndex = index;
//       propertyCode = selectedHotel['code'] ?? '';
//       hotelName = selectedHotel['name'] ?? '';
//       hotelLogoUrl = selectedHotel['config']?['branding']?['logo'];
//     });
//     final searchCtrl = Get.find<search_ctrl.AppSearchController>();
//     searchCtrl.updateSearchPayload(_payload);

//     // Scroll selected card into view
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_hotelScrollCtrl.hasClients) {
//         final cardWidth = 140.0 + 10.0; // card width + gap
//         final targetOffset = (index * cardWidth) -
//             (_hotelScrollCtrl.position.viewportDimension / 2) +
//             (cardWidth / 2);
//         _hotelScrollCtrl.animateTo(
//           targetOffset.clamp(0, _hotelScrollCtrl.position.maxScrollExtent),
//           duration: const Duration(milliseconds: 350),
//           curve: Curves.easeOutCubic,
//         );
//       }
//     });
//     debugPrint('✅ Hotel switched: ${selectedHotel['name']}');
//   }

//   // ── Payload ────────────────────────────────────────────────────────────────
//   Map<String, dynamic> get _payload => {
//         "propertyCode": propertyCode,
//         "startDate": checkIn.toIso8601String().split('T')[0],
//         "endDate": checkOut.toIso8601String().split('T')[0],
//         "guests": {
//           "adults": totalAdults,
//           "children": totalChildren,
//           "rooms": rooms,
//           "roomsArray": roomGuests
//               .map((room) => {
//                     "adults": room['adults'],
//                     "children": room['children'],
//                     "childAges": room['childAges'] ?? [],
//                   })
//               .toList(),
//         },
//         "location": "",
//         "numberOfRooms": rooms,
//         "promocode": "",
//       };

//   // ── Date picker ────────────────────────────────────────────────────────────
//   Future<void> _pickDate(BuildContext ctx, bool isCheckIn) async {
//     final today = DateTime.now();
//     final firstDate = isCheckIn ? today : checkIn.add(const Duration(days: 1));
//     final initDate = isCheckIn
//         ? (checkIn.isBefore(today) ? today : checkIn)
//         : (checkOut.isBefore(firstDate) ? firstDate : checkOut);

//     final picked = await showDatePicker(
//       context: ctx,
//       initialDate: initDate,
//       firstDate: firstDate,
//       lastDate: DateTime(today.year + 2, 12, 31),
//       builder: (c, child) => Theme(
//         data: Theme.of(c).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: AppColor.secondary,
//             onPrimary: Colors.white,
//             surface: Colors.white,
//             onSurface: _T.textPrimary,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked == null) return;
//     setState(() {
//       if (isCheckIn) {
//         checkIn = picked;
//         if (!checkOut.isAfter(checkIn)) {
//           checkOut = checkIn.add(const Duration(days: 1));
//         }
//       } else {
//         checkOut = picked;
//       }
//     });
//   }

//   // ── Actions ────────────────────────────────────────────────────────────────
//   void _performSearch() {
//     Get.find<search_ctrl.AppSearchController>().updateSearchPayload(_payload);
//     if (widget.showEditText && widget.onModifySearch != null) {
//       widget.onModifySearch!();
//     } else {
//       Get.toNamed('/rooms');
//     }
//     if (_showFullSearch) _togglePanel();
//   }

//   void _togglePanel() {
//     setState(() => _showFullSearch = !_showFullSearch);
//     _showFullSearch ? _panelCtrl.forward() : _panelCtrl.reverse();
//   }

//   static String _mon(int m) => const [
//         'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
//         'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
//       ][m - 1];

//   static String _weekday(DateTime d) => const [
//         'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
//       ][d.weekday - 1];

//   // ═══════════════════════════════════════════════════════════════════════════
//   //  ROOT BUILD
//   // ═══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       // Use Column with shrinkWrap; outer screen handles scrolling
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildCompactBar(),
//           _buildShimmerLine(),
//           // Expanded panel — no fixed height constraint, just min-size
//           AnimatedSize(
//             duration: const Duration(milliseconds: 360),
//             curve: Curves.easeInOut,
//             child: _showFullSearch
//                 ? FadeTransition(
//                     opacity: _panelFade,
//                     child: _buildExpandedPanel(),
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   //  COMPACT BAR
//   // ═══════════════════════════════════════════════════════════════════════════
//   Widget _buildCompactBar() {
//     return GestureDetector(
//       onTap: _togglePanel,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── ROW 1 : logo + hotel name + chevron ──────────────────────
//             Row(
//               children: [
//                 _buildLogoAvatar(),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         hotelName.isNotEmpty ? hotelName : 'Search Rooms',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w800,
//                           color: _T.textPrimary,
//                           letterSpacing: 0.2,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         childHotels.length > 1
//                             ? '${childHotels.length} properties · tap to change'
//                             : 'Tap to modify search',
//                         style: TextStyle(fontSize: 10, color: _T.textMuted),
//                       ),
//                     ],
//                   ),
//                 ),
//                 AnimatedRotation(
//                   turns: _showFullSearch ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 320),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: AppColor.secondary,
//                     size: 26,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             // ── ROW 2 : Stay  |  Nights  |  Guests ───────────────────────
//             Row(
//               children: [
//                 Expanded(
//                   flex: 4,
//                   child: _chip(
//                     label: 'STAY',
//                     value:
//                         '${_mon(checkIn.month)} ${checkIn.day}  —  ${_mon(checkOut.month)} ${checkOut.day}',
//                     icon: Icons.date_range_rounded,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 _chip(
//                   label: 'NIGHTS',
//                   value: '$totalNights',
//                   icon: Icons.nightlight_round,
//                   fixedWidth: 70,
//                 ),
//                 const SizedBox(width: 4),
//                 _chip(
//                   label: 'GUESTS',
//                   value: '$totalGuests · ${rooms}rm',
//                   icon: Icons.people_outline_rounded,
//                   fixedWidth: 74,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Compact logo avatar ─────────────────────────────────────────────────────
//   Widget _buildLogoAvatar() {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _T.border, width: 1.5),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8.5),
//         child: (hotelLogoUrl != null && hotelLogoUrl!.isNotEmpty)
//             ? Image.network(
//                 hotelLogoUrl!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => _fallbackLogoWidget(),
//               )
//             : _fallbackLogoWidget(),
//       ),
//     );
//   }

//   Widget _fallbackLogoWidget() => Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [_T.goldDim, _T.gold],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 20),
//       );

//   // ── Chip (compact bar pill) ─────────────────────────────────────────────────
//   Widget _chip({
//     required String label,
//     required String value,
//     required IconData icon,
//     double? fixedWidth,
//   }) {
//     final inner = Container(
//       width: fixedWidth,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       decoration: BoxDecoration(
//         color: _T.surface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _T.border, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 9, color: _T.gold),
//               const SizedBox(width: 3),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 8,
//                   letterSpacing: 1.2,
//                   color: _T.gold,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 3),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 11,
//               color: _T.textPrimary,
//               fontWeight: FontWeight.w700,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//     return fixedWidth != null ? inner : Expanded(flex: 5, child: inner);
//   }

//   // ── Shimmer separator line ──────────────────────────────────────────────────
//   Widget _buildShimmerLine() {
//     return AnimatedBuilder(
//       animation: _shimmerCtrl,
//       builder: (_, __) {
//         final t = _shimmerCtrl.value;
//         return Container(
//           height: 1.5,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: const [
//                 Colors.transparent,
//                 _T.goldDim,
//                 _T.goldLight,
//                 _T.goldDim,
//                 Colors.transparent,
//               ],
//               stops: [
//                 0.0,
//                 (t - 0.25).clamp(0.0, 1.0),
//                 t.clamp(0.0, 1.0),
//                 (t + 0.25).clamp(0.0, 1.0),
//                 1.0,
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   //  EXPANDED PANEL  — fully intrinsic height, no fixed constraints
//   // ═══════════════════════════════════════════════════════════════════════════
//   Widget _buildExpandedPanel() {
//     return Container(
//       color: _T.panel,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(height: 0.8, color: _T.goldDim.withOpacity(0.4)),

//           // header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
//             child: Row(
//               children: [
//                 Text(
//                   'MODIFY SEARCH',
//                   style: TextStyle(
//                     fontSize: 10,
//                     letterSpacing: 2.8,
//                     color: AppColor.secondary,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: _togglePanel,
//                   child: Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: _T.surface,
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(color: _T.border, width: 1),
//                     ),
//                     child: Icon(
//                       Icons.close_rounded,
//                       color: _T.textMuted,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Hotel selector (only if multiple hotels) ────────────────────
//           if (childHotels.length > 1) ...[
//             const SizedBox(height: 16),
//             _buildHotelSelector(),
//           ],

//           // ── Rest of panel content — intrinsic, no scroll inside ─────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Date tiles ─────────────────────────────────────────────
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: _buildDateTile('CHECK-IN', checkIn, true),
//                     ),
//                     _nightsBadge(),
//                     Expanded(
//                       child: _buildDateTile('CHECK-OUT', checkOut, false),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 18),
//                 _goldDivider(),
//                 const SizedBox(height: 18),

//                 // ── Guests & Rooms header ───────────────────────────────────
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'GUESTS & ROOMS',
//                           style: TextStyle(
//                             fontSize: 10,
//                             letterSpacing: 2.2,
//                             color: _T.gold,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           '$totalAdults adults'
//                           '${totalChildren > 0 ? ' · $totalChildren children' : ''}'
//                           ' · $rooms ${rooms == 1 ? 'room' : 'rooms'}',
//                           style: TextStyle(fontSize: 12, color: _T.textSub),
//                         ),
//                       ],
//                     ),
//                     _editDoneButton(
//                       label: _showGuestDetails ? 'DONE' : 'EDIT',
//                       active: _showGuestDetails,
//                       onTap: () => setState(
//                         () => _showGuestDetails = !_showGuestDetails,
//                       ),
//                     ),
//                   ],
//                 ),

//                 AnimatedSize(
//                   duration: const Duration(milliseconds: 320),
//                   curve: Curves.easeInOut,
//                   child: _showGuestDetails
//                       ? _buildGuestPanel()
//                       : const SizedBox(height: 4),
//                 ),

//                 const SizedBox(height: 22),
//                 _buildSearchButton(),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   //  HOTEL SELECTOR — beautiful horizontal card carousel
//   // ═══════════════════════════════════════════════════════════════════════════
//   Widget _buildHotelSelector() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section label
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
//           child: Row(
//             children: [
//               Container(
//                 width: 3,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [_T.goldDim, _T.gold],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'SELECT PROPERTY',
//                 style: TextStyle(
//                   fontSize: 10,
//                   letterSpacing: 2.5,
//                   color: _T.gold,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '${selectedHotelIndex + 1} of ${childHotels.length}',
//                 style: TextStyle(fontSize: 10, color: _T.textMuted),
//               ),
//             ],
//           ),
//         ),

//         // Horizontal scrollable hotel cards
//         SizedBox(
//           height: 116,
//           child: ListView.builder(
//             controller: _hotelScrollCtrl,
//             scrollDirection: Axis.horizontal,
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: childHotels.length,
//             itemBuilder: (context, index) {
//               final hotel = childHotels[index];
//               final isSelected = index == selectedHotelIndex;
//               return _buildHotelCard(hotel, index, isSelected);
//             },
//           ),
//         ),

//         // Dot indicators
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(childHotels.length, (i) {
//             final isSelected = i == selectedHotelIndex;
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               margin: const EdgeInsets.symmetric(horizontal: 3),
//               width: isSelected ? 20 : 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: isSelected ? _T.gold : _T.border,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   Widget _buildHotelCard(dynamic hotel, int index, bool isSelected) {
//     final logoUrl = hotel['config']?['branding']?['logo'] as String?;
//     final name = hotel['name'] as String? ?? 'Hotel ${index + 1}';
//     final code = hotel['code'] as String? ?? '';
//     final rating = hotel['rating'] as num?;

//     return GestureDetector(
//       onTap: () => _selectHotel(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOutCubic,
//         width: 150,
//         margin: EdgeInsets.only(
//           right: 10,
//           top: isSelected ? 0 : 6,
//           bottom: isSelected ? 6 : 0,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : _T.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? _T.gold : _T.border,
//             width: isSelected ? 1.8 : 1,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: _T.gold.withOpacity(0.22),
//                     blurRadius: 14,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Top row: logo + selection indicator
//                   Row(
//                     children: [
//                       // Logo
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: isSelected
//                                 ? _T.gold.withOpacity(0.4)
//                                 : _T.border,
//                             width: 1,
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(7),
//                           child: (logoUrl != null && logoUrl.isNotEmpty)
//                               ? Image.network(
//                                   logoUrl,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (_, __, ___) =>
//                                       _cardFallbackLogo(),
//                                 )
//                               : _cardFallbackLogo(),
//                         ),
//                       ),
//                       const Spacer(),
//                       // Selection checkmark / radio
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         width: 20,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isSelected ? _T.gold : Colors.transparent,
//                           border: Border.all(
//                             color: isSelected ? _T.gold : _T.border,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: isSelected
//                             ? const Icon(
//                                 Icons.check_rounded,
//                                 size: 12,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),

//                   // Hotel name
//                   Text(
//                     name,
//                     style: TextStyle(
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w800,
//                       color: isSelected ? _T.textPrimary : _T.textSub,
//                       height: 1.2,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const SizedBox(height: 4),

//                   // Code + optional rating
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 5,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? _T.gold.withOpacity(0.12)
//                               : _T.border.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           code.toUpperCase(),
//                           style: TextStyle(
//                             fontSize: 8,
//                             letterSpacing: 1.2,
//                             fontWeight: FontWeight.w700,
//                             color: isSelected ? _T.goldDim : _T.textMuted,
//                           ),
//                         ),
//                       ),
//                       if (rating != null) ...[
//                         const Spacer(),
//                         Icon(
//                           Icons.star_rounded,
//                           size: 11,
//                           color: isSelected ? _T.gold : _T.textMuted,
//                         ),
//                         const SizedBox(width: 2),
//                         Text(
//                           rating.toStringAsFixed(1),
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700,
//                             color: isSelected ? _T.goldDim : _T.textMuted,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Selected shimmer accent — top edge
//             if (isSelected)
//               Positioned(
//                 top: 0,
//                 left: 20,
//                 right: 20,
//                 child: Container(
//                   height: 2,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Colors.transparent, _T.goldLight, Colors.transparent],
//                     ),
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _cardFallbackLogo() => Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [_T.goldDim, _T.gold],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 18),
//       );

//   // ── Nights badge ────────────────────────────────────────────────────────────
//   Widget _nightsBadge() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Column(
//         children: [
//           const SizedBox(height: 26),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//             decoration: BoxDecoration(
//               color: _T.gold.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: _T.gold.withOpacity(0.35), width: 0.8),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   '$totalNights',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w900,
//                     color: _T.gold,
//                     height: 1,
//                   ),
//                 ),
//                 Text(
//                   totalNights == 1 ? 'NT' : 'NTS',
//                   style: TextStyle(
//                     fontSize: 8,
//                     letterSpacing: 1.2,
//                     color: _T.goldDim,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Date tile ───────────────────────────────────────────────────────────────
//   Widget _buildDateTile(String label, DateTime date, bool isCheckIn) {
//     return GestureDetector(
//       onTap: () => _pickDate(context, isCheckIn),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: _T.surface,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _T.border, width: 1),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.calendar_today_rounded,
//                   size: 10,
//                   color: AppColor.secondary,
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 8,
//                     letterSpacing: 1.8,
//                     color: AppColor.secondary,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.baseline,
//               textBaseline: TextBaseline.alphabetic,
//               children: [
//                 Text(
//                   '${date.day}'.padLeft(2, '0'),
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w900,
//                     color: _T.textPrimary,
//                     height: 1,
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _mon(date.month),
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w800,
//                         color: _T.gold,
//                         letterSpacing: 0.8,
//                       ),
//                     ),
//                     Text(
//                       '${date.year}',
//                       style: TextStyle(fontSize: 9, color: _T.textMuted),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 2),
//             Text(
//               _weekday(date),
//               style: TextStyle(
//                 fontSize: 9,
//                 color: _T.textMuted,
//                 letterSpacing: 0.8,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Guest panel ─────────────────────────────────────────────────────────────
//   Widget _buildGuestPanel() {
//     return Container(
//       margin: const EdgeInsets.only(top: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _T.panelDark,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _T.border, width: 1),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildCounter(
//             'ROOMS',
//             rooms,
//             Icons.meeting_room_outlined,
//             () => updateRooms(rooms > 1 ? rooms - 1 : 1),
//             () => updateRooms(rooms < 10 ? rooms + 1 : rooms),
//             minusEnabled: rooms > 1,
//             addEnabled: rooms < 10,
//           ),

//           _panelDivider(),

//           if (rooms == 1) ...[
//             _buildGuestConfiguration(0),
//           ] else
//             ...List.generate(
//               rooms,
//               (idx) => Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 3,
//                         height: 13,
//                         decoration: BoxDecoration(
//                           color: _T.gold,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'ROOM ${idx + 1}',
//                         style: const TextStyle(
//                           fontSize: 9,
//                           letterSpacing: 2.0,
//                           color: _T.gold,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   _buildGuestConfiguration(idx),
//                   if (idx < rooms - 1)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       child: Container(height: 0.8, color: _T.border),
//                     ),
//                 ],
//               ),
//             ),

//           const SizedBox(height: 10),
//           _infoRow('Maximum 4 guests per room · Children ages 0–15'),
//           const SizedBox(height: 4),
//           _infoRow(
//             '$remainingSlots slot${remainingSlots == 1 ? '' : 's'} remaining across all rooms',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoRow(String text) => Row(
//         children: [
//           Icon(Icons.info_outline_rounded, size: 12, color: _T.goldDim),
//           const SizedBox(width: 7),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: _T.textMuted,
//                 letterSpacing: 0.2,
//               ),
//             ),
//           ),
//         ],
//       );

//   // ── Guest configuration for a single room ──────────────────────────────────
//   Widget _buildGuestConfiguration(int roomIndex) {
//     final room = roomGuests[roomIndex];
//     final adults = room['adults'] as int;
//     final children = room['children'] as int;
//     final childAges = List<int>.from(room['childAges'] ?? []);

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildCounter(
//           'ADULTS',
//           adults,
//           Icons.person_outline_rounded,
//           () => updateAdults(roomIndex, adults - 1),
//           () => updateAdults(roomIndex, adults + 1),
//           minusEnabled: adults > 1,
//           addEnabled: adults + children < 4,
//         ),
//         _panelDivider(),
//         _buildCounter(
//           'CHILDREN (0–15)',
//           children,
//           Icons.child_care_rounded,
//           () => updateChildren(roomIndex, children - 1),
//           () => updateChildren(roomIndex, children + 1),
//           minusEnabled: children > 0,
//           addEnabled: adults + children < 4,
//         ),

//         if (children > 0) ...[
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: _T.border.withOpacity(0.5)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.cake_outlined, size: 14, color: _T.goldDim),
//                     const SizedBox(width: 6),
//                     Text(
//                       'CHILD AGES',
//                       style: TextStyle(
//                         fontSize: 9,
//                         letterSpacing: 1.5,
//                         color: _T.goldDim,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 ...List.generate(children, (childIndex) {
//                   final age = childIndex < childAges.length
//                       ? childAges[childIndex]
//                       : 0;
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 24,
//                           height: 24,
//                           decoration: BoxDecoration(
//                             color: _T.gold.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '${childIndex + 1}',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w700,
//                                 color: _T.goldDim,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             'Child ${childIndex + 1} age',
//                             style: TextStyle(fontSize: 11, color: _T.textSub),
//                           ),
//                         ),
//                         Container(
//                           width: 90,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: _T.border),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<int>(
//                               value: age,
//                               isDense: true,
//                               isExpanded: true,
//                               icon: Icon(
//                                 Icons.arrow_drop_down,
//                                 color: _T.goldDim,
//                               ),
//                               items:
//                                   List.generate(16, (i) => i).map((ageVal) {
//                                 return DropdownMenuItem<int>(
//                                   value: ageVal,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 10),
//                                     child: Text(
//                                       ageVal == 0
//                                           ? '< 1 yr (Infant)'
//                                           : '$ageVal yr${ageVal > 1 ? 's' : ''}',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: _T.textPrimary,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (newAge) {
//                                 if (newAge != null) {
//                                   updateChildAge(
//                                     roomIndex,
//                                     childIndex,
//                                     newAge,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // ── Search button ───────────────────────────────────────────────────────────
//   Widget _buildSearchButton() {
//     return GestureDetector(
//       onTap: _performSearch,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 15),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFFC9A84C), Color(0xFFE0C26E), Color(0xFFC9A84C)],
//           ),
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: _T.gold.withOpacity(0.30),
//               blurRadius: 18,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_rounded, size: 18, color: Colors.white),
//             const SizedBox(width: 10),
//             Text(
//               widget.showEditText ? 'UPDATE SEARCH' : 'SEARCH ROOMS',
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w900,
//                 color: Colors.white,
//                 letterSpacing: 2.2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Counter row ─────────────────────────────────────────────────────────────
//   Widget _buildCounter(
//     String label,
//     int value,
//     IconData icon,
//     VoidCallback onDec,
//     VoidCallback onInc, {
//     required bool minusEnabled,
//     required bool addEnabled,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 17, color: _T.goldDim),
//               const SizedBox(width: 10),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 11,
//                   letterSpacing: 1.4,
//                   color: _T.textPrimary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               _ctrBtn(Icons.remove_rounded, onDec, minusEnabled),
//               SizedBox(
//                 width: 42,
//                 child: Text(
//                   '$value',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: _T.textPrimary,
//                   ),
//                 ),
//               ),
//               _ctrBtn(Icons.add_rounded, onInc, addEnabled),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _ctrBtn(IconData icon, VoidCallback onTap, bool enabled) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         width: 32,
//         height: 32,
//         decoration: BoxDecoration(
//           color: enabled ? AppColor.secondary : _T.surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: enabled ? AppColor.secondary : _T.border,
//             width: 1,
//           ),
//         ),
//         child: Icon(
//           icon,
//           size: 15,
//           color: enabled ? Colors.white : _T.textMuted,
//         ),
//       ),
//     );
//   }

//   // ── Helpers ─────────────────────────────────────────────────────────────────
//   Widget _goldDivider() => Container(
//         height: 0.8,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.transparent, _T.goldDim, Colors.transparent],
//           ),
//         ),
//       );

//   Widget _panelDivider() => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Container(height: 0.6, color: _T.divider),
//       );

//   Widget _editDoneButton({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//         decoration: BoxDecoration(
//           gradient: active
//               ? const LinearGradient(colors: [_T.goldDim, _T.gold])
//               : null,
//           color: active ? null : Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: active ? _T.gold : _T.border, width: 1),
//           boxShadow: active
//               ? []
//               : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             letterSpacing: 1.8,
//             fontWeight: FontWeight.w800,
//             color: active ? Colors.white : AppColor.secondary,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:royalcontinent/group/controllers/search_controller.dart'
    as search_ctrl;
import 'package:royalcontinent/group/controllers/hotel_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  THEME CONSTANTS  — White / Gold / Primary accent
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static Color get bg => Colors.white;
  static Color get surface => const Color(0xFFF7F5F0);
  static Color get chipBg => Colors.white;

  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8CC80);
  static const Color goldDim = Color(0xFF9A7A35);

  static Color get textPrimary => const Color(0xFF1A1A1A);
  static Color get textSub => const Color(0xFF555555);
  static Color get textMuted => const Color(0xFF999999);

  static const Color border = Color(0xFFE5DEC8);
  static const Color divider = Color(0xFFEEE8D8);

  static Color get panel => Colors.white;
  static Color get panelDark => const Color(0xFFF2EFE8);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEARCH WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class SearchWidget extends StatefulWidget {
  final bool update;
  final bool showEditText;
  final VoidCallback? onModifySearch;

  const SearchWidget({
    super.key,
    this.update = false,
    this.showEditText = false,
    this.onModifySearch,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  DateTime checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime checkOut = DateTime.now().add(const Duration(days: 2));
  int rooms = 1;
  List<Map<String, dynamic>> roomGuests = [];
  String propertyCode = '';
  String? hotelLogoUrl;
  String hotelName = '';
  bool _showGuestDetails = false;
  bool _showFullSearch = false;
  late HotelController hotelCtrl;
  int selectedHotelIndex = 0;
  List<dynamic> childHotels = [];

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _panelCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _panelFade;

  // ── Derived ────────────────────────────────────────────────────────────────
  int get totalChildren =>
      roomGuests.fold<int>(0, (s, r) => s + (r['children'] as int));
  int get totalAdults =>
      roomGuests.fold<int>(0, (s, r) => s + (r['adults'] as int));
  int get totalGuests => totalAdults + totalChildren;
  int get remainingSlots => (4 * rooms) - totalGuests;
  int get totalNights => checkOut.difference(checkIn).inDays;

  @override
  void initState() {
    super.initState();
    hotelCtrl = Get.find<HotelController>();
    _initializeRoomGuests();
    _loadConfig();
    _loadFromController();

    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _panelFade = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeInOut);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  void _initializeRoomGuests() {
    roomGuests = List.generate(
      rooms,
      (_) => {
        'adults': 1,
        'children': 0,
        'childAges': <int>[],
      },
    );
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Config / controller ────────────────────────────────────────────────────
  void _loadConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final config = json.decode(raw);

      final childHotels = config['childHotels'] as List? ?? [];

      setState(() {
        this.childHotels = childHotels;
        if (childHotels.isNotEmpty) {
          final defaultHotel = childHotels[0];
          selectedHotelIndex = 0;
          propertyCode = defaultHotel['code'] ?? config['code'] ?? '';
          hotelName = defaultHotel['name'] ?? config['name'] ?? '';
          hotelLogoUrl = defaultHotel['config']?['branding']?['logo'] ??
              config['config']?['branding']?['logo'];
          hotelCtrl.setSelectedHotel(defaultHotel);
        } else {
          propertyCode = config['code'] ?? '';
          hotelName = config['name'] ?? '';
          hotelLogoUrl = config['config']?['branding']?['logo'];
        }
      });
    } catch (e) {
      debugPrint('Config load error: $e');
    }
  }

  void _loadFromController() {
    final ctrl = Get.find<search_ctrl.AppSearchController>();
    if (ctrl.searchPayload.isNotEmpty) {
      final p = Map<String, dynamic>.from(ctrl.searchPayload.value);
      setState(() {
        checkIn = DateTime.parse(p['startDate']);
        checkOut = DateTime.parse(p['endDate']);
        final g = p['guests'] as Map<String, dynamic>;
        rooms = g['rooms'] as int? ?? 1;

        if (g['roomsArray'] != null) {
          roomGuests = (g['roomsArray'] as List)
              .map(
                (r) => {
                  'adults': r['adults'] as int,
                  'children': r['children'] as int,
                  'childAges': List<int>.from(r['childAges'] ?? []),
                },
              )
              .toList();
        } else {
          roomGuests = List.generate(
            rooms,
            (_) => {'adults': 1, 'children': 0, 'childAges': <int>[]},
          );
        }
      });
    }
  }

  // ── Mutation ───────────────────────────────────────────────────────────────
  void updateRooms(int n) {
    setState(() {
      rooms = n;
      if (n > roomGuests.length) {
        roomGuests.addAll(
          List.generate(
            n - roomGuests.length,
            (_) => {'adults': 1, 'children': 0, 'childAges': <int>[]},
          ),
        );
      } else if (n < roomGuests.length) {
        roomGuests = roomGuests.sublist(0, n);
      }
    });
  }

  void updateAdults(int i, int v) {
    if (v + roomGuests[i]['children']! <= 4 && v >= 1) {
      setState(() => roomGuests[i]['adults'] = v);
    }
  }

  void updateChildren(int i, int v) {
    final currentAdults = roomGuests[i]['adults'] as int;
    final currentChildren = roomGuests[i]['children'] as int;
    final currentAges = List<int>.from(roomGuests[i]['childAges'] ?? []);

    if (currentAdults + v <= 4 && v >= 0) {
      setState(() {
        roomGuests[i]['children'] = v;
        if (v > currentChildren) {
          final childrenToAdd = v - currentChildren;
          roomGuests[i]['childAges'] = [
            ...currentAges,
            ...List.generate(childrenToAdd, (_) => 0),
          ];
        } else if (v < currentChildren) {
          roomGuests[i]['childAges'] = currentAges.sublist(0, v);
        }
      });
    }
  }

  void updateChildAge(int roomIndex, int childIndex, int age) {
    if (age >= 0 && age <= 15) {
      setState(() {
        final ages = List<int>.from(roomGuests[roomIndex]['childAges'] ?? []);
        if (childIndex < ages.length) {
          ages[childIndex] = age;
          roomGuests[roomIndex]['childAges'] = ages;
        }
      });
    }
  }

  // ── Hotel selection ────────────────────────────────────────────────────────
  void _selectHotel(int index) {
    if (index >= childHotels.length) return;
    final selectedHotel = childHotels[index];
    hotelCtrl.setSelectedHotel(selectedHotel);
    setState(() {
      selectedHotelIndex = index;
      propertyCode = selectedHotel['code'] ?? '';
      hotelName = selectedHotel['name'] ?? '';
      hotelLogoUrl = selectedHotel['config']?['branding']?['logo'];
    });
    final searchCtrl = Get.find<search_ctrl.AppSearchController>();
    searchCtrl.updateSearchPayload(_payload);
    debugPrint('✅ Hotel switched: ${selectedHotel['name']} (code: ${selectedHotel['code']})');
  }

  // ── Payload ────────────────────────────────────────────────────────────────
  Map<String, dynamic> get _payload => {
        "propertyCode": propertyCode,
        "startDate": checkIn.toIso8601String().split('T')[0],
        "endDate": checkOut.toIso8601String().split('T')[0],
        "guests": {
          "adults": totalAdults,
          "children": totalChildren,
          "rooms": rooms,
          "roomsArray": roomGuests
              .map(
                (room) => {
                  "adults": room['adults'],
                  "children": room['children'],
                  "childAges": room['childAges'] ?? [],
                },
              )
              .toList(),
        },
        "location": "",
        "numberOfRooms": rooms,
        "promocode": "",
      };

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate(BuildContext ctx, bool isCheckIn) async {
    final today = DateTime.now();
    final firstDate = isCheckIn ? today : checkIn.add(const Duration(days: 1));
    final initDate = isCheckIn
        ? (checkIn.isBefore(today) ? today : checkIn)
        : (checkOut.isBefore(firstDate) ? firstDate : checkOut);

    final picked = await showDatePicker(
      context: ctx,
      initialDate: initDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 2, 12, 31),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColor.secondary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _T.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        checkIn = picked;
        if (!checkOut.isAfter(checkIn)) {
          checkOut = checkIn.add(const Duration(days: 1));
        }
      } else {
        checkOut = picked;
      }
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _performSearch() {
    Get.find<search_ctrl.AppSearchController>().updateSearchPayload(_payload);
    if (widget.showEditText && widget.onModifySearch != null) {
      widget.onModifySearch!();
    } else {
      Get.toNamed('/rooms');
    }
    if (_showFullSearch) _togglePanel();
  }

  void _togglePanel() {
    setState(() => _showFullSearch = !_showFullSearch);
    _showFullSearch ? _panelCtrl.forward() : _panelCtrl.reverse();
  }

  static String _mon(int m) => const [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
      ][m - 1];

  // ═══════════════════════════════════════════════════════════════════════════
  //  ROOT BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        // KEY FIX: ClampingScrollPhysics prevents rubber-band fighting with
        // parent scrollables; the entire widget scrolls as one unit.
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactBar(),
            _buildShimmerLine(),
            AnimatedSize(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOut,
              child: _showFullSearch
                  ? FadeTransition(
                      opacity: _panelFade,
                      child: _buildExpandedPanel(),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  COMPACT BAR  — logo row on top, chips row below (unchanged)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCompactBar() {
    return GestureDetector(
      onTap: _togglePanel,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ROW 1 : logo + hotel name + chevron ──────────────────────
            Row(
              children: [
                _buildLogo(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotelName.isNotEmpty ? hotelName : 'Search Rooms',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _T.textPrimary,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        childHotels.length > 1
                            ? '${childHotels.length} hotels'
                            : 'Tap to modify',
                        style: TextStyle(fontSize: 10, color: _T.textMuted),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _showFullSearch ? 0.5 : 0,
                  duration: const Duration(milliseconds: 320),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColor.secondary,
                    size: 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── ROW 2 : Stay  |  Nights  |  Guests ───────────────────────
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _chip(
                    label: 'STAY',
                    value:
                        '${_mon(checkIn.month)} ${checkIn.day}  —  ${_mon(checkOut.month)} ${checkOut.day}',
                    icon: Icons.date_range_rounded,
                  ),
                ),
                const SizedBox(width: 4),
                _chip(
                  label: 'NIGHTS',
                  value: '$totalNights',
                  icon: Icons.nightlight_round,
                  fixedWidth: 70,
                ),
                const SizedBox(width: 4),
                _chip(
                  label: 'GUESTS',
                  value: '$totalGuests · ${rooms}room',
                  icon: Icons.people_outline_rounded,
                  fixedWidth: 74,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Chip (compact bar pill) ─────────────────────────────────────────────────
  Widget _chip({
    required String label,
    required String value,
    required IconData icon,
    double? fixedWidth,
  }) {
    final inner = Container(
      width: fixedWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 9, color: _T.gold),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.2,
                  color: _T.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: _T.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    return fixedWidth != null ? inner : Expanded(flex: 5, child: inner);
  }

  // ── Logo ────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return SizedBox(
      width: 60,
      height: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: (hotelLogoUrl != null && hotelLogoUrl!.isNotEmpty)
            ? Image.network(
                hotelLogoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallbackLogo(),
              )
            : _fallbackLogo(),
      ),
    );
  }

  Widget _fallbackLogo() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_T.goldDim, _T.gold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 20),
      );

  // ── Shimmer separator line ──────────────────────────────────────────────────
  Widget _buildShimmerLine() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        final t = _shimmerCtrl.value;
        return Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Colors.transparent,
                _T.goldDim,
                _T.goldLight,
                _T.goldDim,
                Colors.transparent,
              ],
              stops: [
                0.0,
                (t - 0.25).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.25).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  EXPANDED PANEL
  //  KEY FIX: No ConstrainedBox or inner SingleChildScrollView.
  //  All content is intrinsic-height Column; outer SingleChildScrollView scrolls.
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExpandedPanel() {
    return Container(
      color: _T.panel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // thin gold top rule
          Container(height: 0.8, color: _T.goldDim.withOpacity(0.4)),

          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
            child: Row(
              children: [
                Text(
                  'MODIFY SEARCH',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.8,
                    color: AppColor.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _T.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _T.border, width: 1),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: _T.textMuted,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date tiles ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDateTile('CHECK-IN', checkIn, true),
                    ),
                    _nightsBadge(),
                    Expanded(
                      child: _buildDateTile('CHECK-OUT', checkOut, false),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                _goldDivider(),
                const SizedBox(height: 18),

                // ── Guests & Rooms header ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GUESTS & ROOMS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2.2,
                            color: _T.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$totalAdults adults'
                          '${totalChildren > 0 ? ' · $totalChildren children' : ''}'
                          ' · $rooms ${rooms == 1 ? 'room' : 'rooms'}',
                          style: TextStyle(fontSize: 12, color: _T.textSub),
                        ),
                      ],
                    ),
                    _editDoneButton(
                      label: _showGuestDetails ? 'DONE' : 'EDIT',
                      active: _showGuestDetails,
                      onTap: () => setState(
                        () => _showGuestDetails = !_showGuestDetails,
                      ),
                    ),
                  ],
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  child: _showGuestDetails
                      ? _buildGuestPanel()
                      : const SizedBox(height: 4),
                ),

                const SizedBox(height: 18),

                // ── Hotel selector — only shown when multiple hotels ─────
                if (childHotels.length > 1) ...[
                  _goldDivider(),
                  const SizedBox(height: 16),
                  _buildVerticalHotelSelector(),
                  const SizedBox(height: 18),
                ],

                // ── Search button ───────────────────────────────────────
                _buildSearchButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  VERTICAL HOTEL SELECTOR
  //  Stacked full-width buttons, first hotel selected by default.
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVerticalHotelSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_T.goldDim, _T.gold],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SELECT PROPERTY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: _T.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Stacked hotel buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(childHotels.length, (index) {
            final hotel = childHotels[index];
            final isSelected = index == selectedHotelIndex;
            final name = hotel['name'] as String? ?? 'Hotel ${index + 1}';
            final logoUrl =
                hotel['config']?['branding']?['logo'] as String?;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < childHotels.length - 1 ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => _selectHotel(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _T.gold.withOpacity(0.07)
                        : _T.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _T.gold : _T.border,
                      width: isSelected ? 1.6 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _T.gold.withOpacity(0.14),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      // Logo thumbnail
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? _T.gold.withOpacity(0.5)
                                : _T.border,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: (logoUrl != null && logoUrl.isNotEmpty)
                              ? Image.network(
                                  logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _smallFallbackLogo(),
                                )
                              : _smallFallbackLogo(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Hotel name
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? _T.textPrimary
                                : _T.textSub,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Animated radio/check indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? _T.gold : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? _T.gold : _T.border,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _smallFallbackLogo() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_T.goldDim, _T.gold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 16),
      );

  // ── Nights badge ────────────────────────────────────────────────────────────
  Widget _nightsBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _T.gold.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.gold.withOpacity(0.35), width: 0.8),
            ),
            child: Column(
              children: [
                Text(
                  '$totalNights',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _T.gold,
                    height: 1,
                  ),
                ),
                Text(
                  totalNights == 1 ? 'NT' : 'NTS',
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.2,
                    color: _T.goldDim,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date tile ───────────────────────────────────────────────────────────────
  Widget _buildDateTile(String label, DateTime date, bool isCheckIn) {
    return GestureDetector(
      onTap: () => _pickDate(context, isCheckIn),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: AppColor.secondary,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.8,
                    color: AppColor.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${date.day}'.padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _T.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mon(date.month),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _T.gold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${date.year}',
                          style: TextStyle(
                            fontSize: 9,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Guest panel ─────────────────────────────────────────────────────────────
  Widget _buildGuestPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.panelDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCounter(
            'ROOMS',
            rooms,
            Icons.meeting_room_outlined,
            () => updateRooms(rooms > 1 ? rooms - 1 : 1),
            () => updateRooms(rooms < 10 ? rooms + 1 : rooms),
            minusEnabled: rooms > 1,
            addEnabled: rooms < 10,
          ),

          _panelDivider(),

          if (rooms == 1) ...[
            _buildGuestConfiguration(0),
          ] else
            ...List.generate(
              rooms,
              (idx) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 13,
                        decoration: BoxDecoration(
                          color: _T.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ROOM ${idx + 1}',
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          color: _T.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildGuestConfiguration(idx),
                  if (idx < rooms - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Container(height: 0.8, color: _T.border),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: _T.goldDim),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Maximum 4 guests per room · Children ages 0-15',
                  style: TextStyle(
                    fontSize: 10,
                    color: _T.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: _T.goldDim),
              const SizedBox(width: 7),
              Text(
                '$remainingSlots slot${remainingSlots == 1 ? '' : 's'} available',
                style: TextStyle(
                  fontSize: 10,
                  color: _T.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Guest configuration for a single room ──────────────────────────────────
  Widget _buildGuestConfiguration(int roomIndex) {
    final room = roomGuests[roomIndex];
    final adults = room['adults'] as int;
    final children = room['children'] as int;
    final childAges = List<int>.from(room['childAges'] ?? []);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCounter(
          'ADULTS',
          adults,
          Icons.person_outline_rounded,
          () => updateAdults(roomIndex, adults - 1),
          () => updateAdults(roomIndex, adults + 1),
          minusEnabled: adults > 1,
          addEnabled: adults + children < 4,
        ),
        _panelDivider(),
        _buildCounter(
          'CHILDREN (0-15)',
          children,
          Icons.child_care_rounded,
          () => updateChildren(roomIndex, children - 1),
          () => updateChildren(roomIndex, children + 1),
          minusEnabled: children > 0,
          addEnabled: adults + children < 4,
        ),

        // Child age selectors
        if (children > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.border.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cake_outlined, size: 14, color: _T.goldDim),
                    const SizedBox(width: 6),
                    Text(
                      'CHILD AGES',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: _T.goldDim,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(children, (childIndex) {
                  final age = childIndex < childAges.length
                      ? childAges[childIndex]
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _T.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${childIndex + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _T.goldDim,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Child ${childIndex + 1} age',
                            style: TextStyle(fontSize: 11, color: _T.textSub),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _T.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: age,
                              isDense: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: _T.goldDim,
                              ),
                              items:
                                  List.generate(16, (i) => i).map((age) {
                                return DropdownMenuItem<int>(
                                  value: age,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      age == 0 ? '0 (Infant)' : '$age years',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _T.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newAge) {
                                if (newAge != null) {
                                  updateChildAge(roomIndex, childIndex, newAge);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Search button ───────────────────────────────────────────────────────────
  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _performSearch,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A84C), Color(0xFFE0C26E), Color(0xFFC9A84C)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _T.gold.withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              widget.showEditText ? 'UPDATE SEARCH' : 'SEARCH ROOMS',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Counter row ─────────────────────────────────────────────────────────────
  Widget _buildCounter(
    String label,
    int value,
    IconData icon,
    VoidCallback onDec,
    VoidCallback onInc, {
    required bool minusEnabled,
    required bool addEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: _T.goldDim),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: _T.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _ctrBtn(Icons.remove_rounded, onDec, minusEnabled),
              SizedBox(
                width: 42,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                  ),
                ),
              ),
              _ctrBtn(Icons.add_rounded, onInc, addEnabled),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctrBtn(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColor.secondary : _T.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppColor.secondary : _T.border,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled ? Colors.white : _T.textMuted,
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _goldDivider() => Container(
        height: 0.8,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, _T.goldDim, Colors.transparent],
          ),
        ),
      );

  Widget _panelDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(height: 0.6, color: _T.divider),
      );

  Widget _editDoneButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_T.goldDim, _T.gold])
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _T.gold : _T.border, width: 1),
          boxShadow: active
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColor.secondary,
          ),
        ),
      ),
    );
  }
}