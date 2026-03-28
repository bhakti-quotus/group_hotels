import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ─── Color constants ──────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFFE8334A);
const Color _kNavy = Color(0xFF1A2E6C);
const Color _kBg = Color(0xFFF4F6FA);

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════════════════════════════
class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  static const _tabs = [
    _TabMeta(icon: Icons.people_outline, label: 'Interests'),
    _TabMeta(icon: Icons.bed_outlined, label: 'Room'),
    _TabMeta(icon: Icons.restaurant_outlined, label: 'Diet'),
    _TabMeta(icon: Icons.favorite_border, label: 'Favourites'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kNavy),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Preference',
            style: TextStyle(
              color: _kNavy,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(76),
            child: _RectTabBar(
              tabs: _tabs,
              selectedIndex: _selectedIndex,
              onTap: (i) {
                setState(() => _selectedIndex = i);
                _tabController.animateTo(i);
              },
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _InterestsTab(),
            _RoomTab(),
            _DietTab(),
            _FavouritesTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RECTANGULAR TAB BAR  — each tab is a bordered rectangle with icon + label
// ═══════════════════════════════════════════════════════════════════════════════
class _TabMeta {
  final IconData icon;
  final String label;
  const _TabMeta({required this.icon, required this.label});
}

class _RectTabBar extends StatelessWidget {
  final List<_TabMeta> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _RectTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final t = tabs[i];
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _kPrimary.withOpacity(0.07)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected ? _kPrimary : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.icon,
                      size: 22,
                      color: isSelected
                          ? _kPrimary
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? _kPrimary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckRow(
      {required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: _kPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF333333))),
        ),
      ],
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SegmentRow(
      {required this.options,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final sel = opt == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: sel ? _kPrimary : Colors.grey.shade300),
              ),
              child: Text(opt,
                  style: TextStyle(
                      fontSize: 13,
                      color: sel ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SizeRow extends StatelessWidget {
  final List<String> sizes;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SizeRow(
      {required this.sizes,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: sizes.map((s) {
        final sel = s == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(s),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: sel ? _kPrimary : Colors.grey.shade300),
              ),
              child: Text(s,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.black54)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

Widget _sectionLabel(String text) => Text(text,
    style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: _kNavy));

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — Interests
// ═══════════════════════════════════════════════════════════════════════════════
class _InterestsTab extends StatefulWidget {
  const _InterestsTab();
  @override
  State<_InterestsTab> createState() => _InterestsTabState();
}

class _InterestsTabState extends State<_InterestsTab> {
  final Map<String, bool> _sport = {
    'Improve Fitness Level': true,
    'Have Soft Adventure Experiences': false,
    'Yoga': false,
    'Learning Scuba Diving': false,
    'Learn to Sail': false,
    'Water Sports': false,
    'Private Tennis Coaching': false,
  };
  final Map<String, bool> _health = {
    'Personalised Wellness Programme': true,
    'Achive Mental Relaxation': false,
    'Sleep Well Programme': false,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When you have a moment, please tell us what is important to you during your stay. Based on the information you provide, we will be able to suggest a personalised schedule of activities for you.',
            style: TextStyle(
                fontSize: 13, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Sport'),
          const SizedBox(height: 6),
          ..._sport.keys.map((key) => _CheckRow(
                label: key,
                value: _sport[key]!,
                onChanged: (v) => setState(() => _sport[key] = v!),
              )),
          const SizedBox(height: 16),
          _sectionLabel('Health'),
          const SizedBox(height: 6),
          ..._health.keys.map((key) => _CheckRow(
                label: key,
                value: _health[key]!,
                onChanged: (v) => setState(() => _health[key] = v!),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — Room
// ═══════════════════════════════════════════════════════════════════════════════
class _RoomTab extends StatefulWidget {
  const _RoomTab();
  @override
  State<_RoomTab> createState() => _RoomTabState();
}

class _RoomTabState extends State<_RoomTab> {
  bool _extraPillows = true;
  bool _extraTowels = false;
  String _blanket = 'Large Blanket';
  String _bathroom = 'Shower Cabin';
  String _slipper = 'S';
  String _bathrobe = 'M';
  final _specialCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Treat yourself to a relaxing night to sleep. Select the right pillow for your from our complimentary Pillow Menu.',
            style: TextStyle(
                fontSize: 13, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Pillow Menu'),
          const SizedBox(height: 6),
          _CheckRow(
              label: 'Extra Pillows',
              value: _extraPillows,
              onChanged: (v) => setState(() => _extraPillows = v!)),
          _CheckRow(
              label: 'Extra Towels',
              value: _extraTowels,
              onChanged: (v) => setState(() => _extraTowels = v!)),
          const SizedBox(height: 16),
          _sectionLabel('Blankets'),
          const SizedBox(height: 8),
          _SegmentRow(
              options: const ['Single Blanket', 'Large Blanket'],
              selected: _blanket,
              onSelect: (v) => setState(() => _blanket = v)),
          const SizedBox(height: 16),
          _sectionLabel('Bathroom Fitting'),
          const SizedBox(height: 8),
          _SegmentRow(
              options: const ['Shower Cabin', 'Option 2'],
              selected: _bathroom,
              onSelect: (v) => setState(() => _bathroom = v)),
          const SizedBox(height: 16),
          _sectionLabel('Slipper Size'),
          const SizedBox(height: 8),
          _SizeRow(
              sizes: const ['L', 'M', 'S'],
              selected: _slipper,
              onSelect: (v) => setState(() => _slipper = v)),
          const SizedBox(height: 16),
          _sectionLabel('Bathrobe Size'),
          const SizedBox(height: 8),
          _SizeRow(
              sizes: const ['L', 'M', 'S'],
              selected: _bathrobe,
              onSelect: (v) => setState(() => _bathrobe = v)),
          const SizedBox(height: 16),
          _sectionLabel('Special Room Request'),
          const SizedBox(height: 8),
          TextField(
            controller: _specialCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'I need a big big room',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () =>
                  Get.snackbar('Saved', 'Room preferences saved!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SAVE',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3 — Diet  (rich data)
// ═══════════════════════════════════════════════════════════════════════════════
class _DietTab extends StatefulWidget {
  const _DietTab();
  @override
  State<_DietTab> createState() => _DietTabState();
}

class _DietTabState extends State<_DietTab> {
  String _dietType = 'Balanced';
  final _dietTypes = [
    'Balanced',
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Keto',
    'Gluten-Free',
  ];

  final Map<String, bool> _allergies = {
    'Nuts': false,
    'Shellfish': false,
    'Dairy': false,
    'Gluten': false,
    'Eggs': false,
    'Soy': false,
    'Sesame': false,
  };

  final Map<String, bool> _mealPrefs = {
    'Low Calorie Meals': false,
    'High Protein Meals': true,
    'Low Sodium Options': false,
    'Sugar-Free Desserts': false,
    'Organic / Farm-to-Table': true,
    'Ayurvedic Cuisine': false,
    'Raw Food Options': false,
  };

  final Map<String, bool> _cuisines = {
    'Asian': true,
    'Mediterranean': false,
    'Indian': true,
    'Continental': false,
    'Middle Eastern': false,
    'Japanese': false,
    'Mexican': false,
  };

  String _breakfastTime = '07:30';
  String _lunchTime = '13:00';
  String _dinnerTime = '19:30';

  final _notesCtrl = TextEditingController(
      text: 'Please avoid very spicy food. I prefer smaller portions.');

  Future<String?> _pickTime(BuildContext ctx, String current) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked =
        await showTimePicker(context: ctx, initialTime: initial);
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Help us personalise your dining experience. Let us know your dietary requirements and preferences so our chefs can prepare meals you will love.',
            style: TextStyle(
                fontSize: 13, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),

          // ── Dietary Type ────────────────────────────────────────────
          _sectionLabel('Dietary Type'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietTypes.map((d) {
              final sel = d == _dietType;
              return GestureDetector(
                onTap: () => setState(() => _dietType = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            sel ? _kPrimary : Colors.grey.shade300),
                  ),
                  child: Text(d,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              sel ? Colors.white : Colors.black54)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Allergies ───────────────────────────────────────────────
          _sectionLabel('Allergies & Intolerances'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies.keys.map((a) {
              final sel = _allergies[a]!;
              return GestureDetector(
                onTap: () =>
                    setState(() => _allergies[a] = !sel),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFFFFECEE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel
                            ? _kPrimary
                            : Colors.grey.shade300,
                        width: sel ? 1.5 : 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: _kPrimary),
                        ),
                      Text(a,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel
                                  ? _kPrimary
                                  : Colors.black54)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Meal Preferences ────────────────────────────────────────
          _sectionLabel('Meal Preferences'),
          const SizedBox(height: 6),
          ..._mealPrefs.keys.map((key) => _CheckRow(
                label: key,
                value: _mealPrefs[key]!,
                onChanged: (v) =>
                    setState(() => _mealPrefs[key] = v!),
              )),
          const SizedBox(height: 20),

          // ── Cuisine ─────────────────────────────────────────────────
          _sectionLabel('Favourite Cuisines'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cuisines.keys.map((c) {
              final sel = _cuisines[c]!;
              return GestureDetector(
                onTap: () =>
                    setState(() => _cuisines[c] = !sel),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            sel ? _kPrimary : Colors.grey.shade300),
                  ),
                  child: Text(c,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              sel ? Colors.white : Colors.black54)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Meal Times ──────────────────────────────────────────────
          _sectionLabel('Preferred Meal Times'),
          const SizedBox(height: 10),
          _MealTimeRow(
            icon: Icons.wb_sunny_outlined,
            meal: 'Breakfast',
            time: _breakfastTime,
            onTap: () async {
              final t =
                  await _pickTime(context, _breakfastTime);
              if (t != null) setState(() => _breakfastTime = t);
            },
          ),
          const SizedBox(height: 8),
          _MealTimeRow(
            icon: Icons.wb_cloudy_outlined,
            meal: 'Lunch',
            time: _lunchTime,
            onTap: () async {
              final t = await _pickTime(context, _lunchTime);
              if (t != null) setState(() => _lunchTime = t);
            },
          ),
          const SizedBox(height: 8),
          _MealTimeRow(
            icon: Icons.nights_stay_outlined,
            meal: 'Dinner',
            time: _dinnerTime,
            onTap: () async {
              final t = await _pickTime(context, _dinnerTime);
              if (t != null) setState(() => _dinnerTime = t);
            },
          ),
          const SizedBox(height: 20),

          // ── Notes ───────────────────────────────────────────────────
          _sectionLabel('Additional Dietary Notes'),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any other dietary requests for our chefs…',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () =>
                  Get.snackbar('Saved', 'Diet preferences saved!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SAVE',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Meal time row widget
class _MealTimeRow extends StatelessWidget {
  final IconData icon;
  final String meal;
  final String time;
  final VoidCallback onTap;
  const _MealTimeRow(
      {required this.icon,
      required this.meal,
      required this.time,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _kNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(meal,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333))),
            ),
            Text(time,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary)),
            const SizedBox(width: 6),
            Icon(Icons.access_time,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 4 — Favourites
// ═══════════════════════════════════════════════════════════════════════════════
class _FavouriteItem {
  String text;
  String category;
  bool editing;
  _FavouriteItem(
      {required this.text,
      required this.category,
      this.editing = false});
}

class _FavouritesTab extends StatefulWidget {
  const _FavouritesTab();
  @override
  State<_FavouritesTab> createState() => _FavouritesTabState();
}

class _FavouritesTabState extends State<_FavouritesTab> {
  final List<_FavouriteItem> _items = [
    _FavouriteItem(text: 'Ayurvedic massage', category: 'Wellness'),
    _FavouriteItem(text: 'Deep sea diving', category: 'Activity'),
    _FavouriteItem(
        text: 'Three course meal with Hirsha', category: 'Dining'),
  ];

  void _addItem() => setState(() => _items
      .add(_FavouriteItem(text: '', category: 'Wellness', editing: true)));
  void _deleteItem(int i) => setState(() => _items.removeAt(i));
  void _toggleEdit(int i) =>
      setState(() => _items[i].editing = !_items[i].editing);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Let us know if you have any personal preferences or favourite things whilst visiting BodyHoliday to help us provide you with a delightful experience. Requests are not guaranteed and subject to availability.',
                style: TextStyle(
                    fontSize: 13, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 20),
              ...List.generate(
                _items.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FavCard(
                    item: _items[i],
                    onEdit: () => _toggleEdit(i),
                    onDelete: () => _deleteItem(i),
                    onSave: () => _toggleEdit(i),
                    onTextChanged: (v) =>
                        setState(() => _items[i].text = v),
                    onCatChanged: (v) =>
                        setState(() => _items[i].category = v),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 20,
          child: FloatingActionButton(
            onPressed: _addItem,
            backgroundColor: _kPrimary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _FavCard extends StatelessWidget {
  final _FavouriteItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onCatChanged;
  const _FavCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
    required this.onTextChanged,
    required this.onCatChanged,
  });

  static const _cats = ['Wellness', 'Activity', 'Dining'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: item.editing
                ? TextField(
                    autofocus: true,
                    controller:
                        TextEditingController(text: item.text),
                    onChanged: onTextChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Enter preference…',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        item.text.isEmpty ? '—' : item.text,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333333))),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12)),
              border: Border(
                  top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                ..._cats.map((cat) {
                  final sel = cat == item.category;
                  return GestureDetector(
                    onTap: () => onCatChanged(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? _kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: sel
                                ? _kPrimary
                                : Colors.grey.shade300),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : Colors.black45)),
                    ),
                  );
                }),
                const Spacer(),
                if (item.editing) ...[
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('CANCEL',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _kNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('SAVE',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit_outlined,
                        size: 18, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline,
                        size: 18, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}