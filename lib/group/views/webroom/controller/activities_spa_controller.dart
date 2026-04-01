// activities_spa_controller.dart
import 'package:get/get.dart';
import 'package:sunswept/group/views/webroom/common/activities_spa_data.dart';

class ActivitiesSpaController extends GetxController {
  // ── Observables ────────────────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final activeChip = 'All'.obs;
  final filterCategory = Rxn<String>();
  final filterSubcategory = Rxn<String>();

  // Committed filter state (applied on "Apply Filters")
  final _appliedCategory = Rxn<String>();
  final _appliedSubcategory = Rxn<String>();

  // ── Chip categories (All + each category) ─────────────────────────────────
  List<String> get chipCategories =>
      ['All', ...activitiesCategories];

  // ── Subcategories available for the currently selected filter category ─────
  List<String> get filterSubcategories {
    final cat = filterCategory.value;
    if (cat == null) return [];
    return activitiesSubcategories[cat] ?? [];
  }

  // ── Whether any filter is active ──────────────────────────────────────────
  bool get hasActiveFilter =>
      _appliedCategory.value != null || _appliedSubcategory.value != null;

  // ── Filtered & searched list ──────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredItems {
    final query = searchQuery.value.toLowerCase().trim();
    final chip = activeChip.value;
    final cat = _appliedCategory.value;
    final sub = _appliedSubcategory.value;

    return activitiesSpaItems.where((item) {
      // Chip filter
      if (chip != 'All' && item['category'] != chip) return false;

      // Applied category filter (from filter sheet)
      if (cat != null && item['category'] != cat) return false;

      // Applied subcategory filter
      if (sub != null && item['subcategory'] != sub) return false;

      // Text search
      if (query.isNotEmpty) {
        final title = (item['title'] as String).toLowerCase();
        final subtitle = (item['subtitle'] as String).toLowerCase();
        if (!title.contains(query) && !subtitle.contains(query)) return false;
      }

      return true;
    }).toList();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void selectChipCategory(String cat) {
    activeChip.value = cat;
    // Sync filter sheet category to match chip (UX convenience)
    if (cat == 'All') {
      filterCategory.value = null;
      filterSubcategory.value = null;
      _appliedCategory.value = null;
      _appliedSubcategory.value = null;
    } else {
      filterCategory.value = cat;
      filterSubcategory.value = null;
      _appliedCategory.value = cat;
      _appliedSubcategory.value = null;
    }
  }

  void openFilterSheet() {
    // Sync pending filter state with currently applied state
    filterCategory.value = _appliedCategory.value;
    filterSubcategory.value = _appliedSubcategory.value;
  }

  void applyFilter() {
    _appliedCategory.value = filterCategory.value;
    _appliedSubcategory.value = filterSubcategory.value;

    // Sync chip to match applied category
    if (_appliedCategory.value == null) {
      activeChip.value = 'All';
    } else {
      activeChip.value = _appliedCategory.value!;
    }
  }

  void clearFilter() {
    filterCategory.value = null;
    filterSubcategory.value = null;
    _appliedCategory.value = null;
    _appliedSubcategory.value = null;
    activeChip.value = 'All';
  }
}