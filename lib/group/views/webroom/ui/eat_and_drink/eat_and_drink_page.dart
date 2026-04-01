import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/group/views/webroom/common/eatanddrink_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EAT & DRINK PAGE  (entry point)
// ─────────────────────────────────────────────────────────────────────────────

class EatAndDrinkPage extends StatefulWidget {
  const EatAndDrinkPage({super.key});

  @override
  State<EatAndDrinkPage> createState() => _EatAndDrinkPageState();
}

class _EatAndDrinkPageState extends State<EatAndDrinkPage> {
  List<Restaurant> _restaurants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _restaurants = EatAndDrinkData.restaurants;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading:  BackButton(color: AppColor.primary),
        title:  Text(
          'Eat & Drink',
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
              itemCount: _restaurants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 32),
              itemBuilder: (context, index) =>
                  _RestaurantCard(restaurant: _restaurants[index]),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESTAURANT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantCard({required this.restaurant});

  static const double _imageWidth = 108.0;
  static const double _overflow = 18.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // White card
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: _imageWidth + 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 16, 14, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003087),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          restaurant.tagline,
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(Icons.access_time_rounded,
                                  size: 14, color: Colors.grey),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                restaurant.timing,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Left: overflowing image + optional REQUEST TABLE button
          Positioned(
            left: 10,
            top: -_overflow,
            bottom: 0,
            width: _imageWidth,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      restaurant.image,
                      width: _imageWidth,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8EAF0),
                        child: const Icon(Icons.restaurant,
                            color: Colors.grey, size: 32),
                      ),
                    ),
                  ),
                ),
                if (restaurant.requestTable) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: _imageWidth,
                    child: ElevatedButton(
                      onPressed: () => _openRequestTable(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8414A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      child: const Text('REQUEST TABLE',
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 1.4)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailPage(restaurant: restaurant),
      ),
    );
  }

  void _openRequestTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailPage(
          restaurant: restaurant,
          openRequestTable: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESTAURANT DETAIL PAGE
// ─────────────────────────────────────────────────────────────────────────────

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final bool openRequestTable;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    this.openRequestTable = false,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  static const double _heroHeight = 240.0;

  @override
  void initState() {
    super.initState();
    if (widget.openRequestTable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pushRequestTable());
    }
  }

  void _pushMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _MenuPage(
          restaurantName: widget.restaurant.name,
          restaurantImage: widget.restaurant.image,
        ),
      ),
    );
  }

  void _pushRequestTable() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _RequestTablePage(restaurantName: widget.restaurant.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final topPadding = MediaQuery.of(context).padding.top;

    // Split openingTimes on '*' to extract reservation note
    final openingParts = r.openingTimes.split('*');
    final openingMain = openingParts[0].trim();
    final reservationNote =
        openingParts.length > 1 ? '*${openingParts[1].trim()}' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _BottomActionBar(
        onViewMenu: _pushMenu,
        onRequestTable: r.requestTable ? _pushRequestTable : null,
      ),
      body: Column(
        children: [
          // ── Hero image ──────────────────────────────────────────────────
          SizedBox(
            height: _heroHeight + topPadding,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  r.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8EAF0),
                    child: const Icon(Icons.restaurant,
                        color: Colors.grey, size: 64),
                  ),
                ),
                // Top gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 90 + topPadding,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom white rounded overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: topPadding + 8,
                  left: 8,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1 — Restaurant name + description + philosophy
                  _SectionHeader(icon: Icons.home_outlined, title: r.name),
                  const SizedBox(height: 8),
                  _bodyText(r.description),
                  if (r.philosophy.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SectionHeader(icon: Icons.lightbulb_outline, title: 'Philosophy'),
                    const SizedBox(height: 8),
                    _bodyText(r.philosophy),
                  ],
                  const SizedBox(height: 20),
                  // Section 2 — Cuisine type (tagline) + meal tags
                  _SectionHeader(
                      icon: Icons.restaurant_outlined, title: r.tagline),
                  const SizedBox(height: 10),
                  _bodyText(r.tagline),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: r.meals
                        .map(
                          (meal) => Chip(
                            label: Text(meal,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF003087))),
                            backgroundColor: const Color(0xFFEEF1F8),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  // Section 3 — Opening Times
                  const _SectionHeader(
                      icon: Icons.access_time_outlined,
                      title: 'Opening Times'),
                  const SizedBox(height: 8),
                  _bodyText(openingMain),
                  if (reservationNote.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reservationNote,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE8414A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyText(String text) => Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF003087)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003087),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM ACTION BAR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onViewMenu;
  final VoidCallback? onRequestTable;
  const _BottomActionBar(
      {required this.onViewMenu, required this.onRequestTable});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: const Color(0xFFE8414A),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onViewMenu,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('VIEW MENU',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5)),
            ),
          ),
          if (onRequestTable != null) ...[
            Container(width: 1, height: 20, color: Colors.white54),
            Expanded(
              child: TextButton(
                onPressed: onRequestTable,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('REQUEST A TABLE',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MENU PAGE
// ─────────────────────────────────────────────────────────────────────────────

class _MenuPage extends StatelessWidget {
  final String restaurantName;
  final String restaurantImage;
  const _MenuPage(
      {required this.restaurantName, required this.restaurantImage});

  static const List<MenuItem> _items = EatAndDrinkData.menuItems;
  static const double _heroHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final categories = _items.map((e) => e.category).toSet().toList();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Hero image ──────────────────────────────────────────────────
          SizedBox(
            height: _heroHeight + topPadding,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  restaurantImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8EAF0),
                    child: const Icon(Icons.restaurant,
                        color: Colors.grey, size: 64),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 90 + topPadding,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: topPadding + 8,
                  left: 8,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // ── Menu items with vertical "Menu Items" text ──────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side - rotated "Menu Items" text with full height
                Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: RotatedBox(
                    quarterTurns: 3, // Rotates 90 degrees counter-clockwise
                    child: Text(
                      'MENU ITEMS',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                // Right side - actual menu list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 20, 32),
                    children: [
                      for (final cat in categories) ...[
                        Text(cat,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003087),
                              letterSpacing: 0.5,
                            )),
                        const SizedBox(height: 8),
                        ..._items
                            .where((e) => e.category == cat)
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Color(0xFFF5F6FA))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.name,
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey[800])),
                                    Text(item.price,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFE8414A),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                        const SizedBox(height: 16),
                      ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST TABLE PAGE  (2 steps: form → clock)
// ─────────────────────────────────────────────────────────────────────────────

class _RequestTablePage extends StatefulWidget {
  final String restaurantName;
  const _RequestTablePage({required this.restaurantName});

  @override
  State<_RequestTablePage> createState() => _RequestTablePageState();
}

class _RequestTablePageState extends State<_RequestTablePage> {
  int _guests = 1;
  DateTime? _date;
  TimeOfDay? _time;
  String _comments = '';
  bool _addDietary = false;

  String get _appBarTitle => 'Request a Table';

  void _goBack() {
    Navigator.pop(context);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFE8414A), width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFFE8414A), size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirmation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003087),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you, your reservation request is waiting to be '
                'confirmed. Updates will be sent to your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[600], height: 1.6),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8414A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('DONE',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
         leading:  BackButton(color: AppColor.primary),
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Color(0xFF003087),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F1F5)),
        ),
      ),
      body: _buildForm(),
    );
  }

  // ── STEP 1: FORM ──────────────────────────────────────────────────────────

  Widget _buildForm() {
    return ListView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _label('No. of Guests'),
        const SizedBox(height: 8),
        _DropdownField<int>(
          value: _guests,
          items: List.generate(10, (i) => i + 1),
          itemLabel: (v) => '$v ${v == 1 ? 'guest' : 'guests'}',
          onChanged: (v) => setState(() => _guests = v!),
        ),
        const SizedBox(height: 16),
        _label('Date'),
        const SizedBox(height: 8),
        _DatePickerField(
          value: _date,
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: 16),
        _label('Time'),
        const SizedBox(height: 8),
        _TimePickerField(
          value: _time,
          onChanged: (t) => setState(() => _time = t),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('Comments / Dietary Requests'),
            Text('200 characters',
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            maxLength: 200,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Your message',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              border: InputBorder.none,
              counterText: '',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => _comments = v,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _addDietary,
              activeColor: const Color(0xFFE8414A),
              onChanged: (v) => setState(() => _addDietary = v!),
            ),
            const Text('Add dietary preferences',
                style: TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _date != null && _time != null ? _showConfirmationDialog : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _date != null && _time != null
                ? const Color(0xFFE8414A)
                : Colors.grey.shade300,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('REQUEST TABLE',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    this.value,
    this.hint,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null
              ? Text(hint!, style: const TextStyle(fontSize: 13))
              : null,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(itemLabel(e),
                      style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;
  const _TimePickerField({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
                    : 'Select time',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _DatePickerField({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? value!.toLocal().toString().split(' ')[0]
                    : 'Select date',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}