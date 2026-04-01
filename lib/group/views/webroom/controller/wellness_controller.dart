// wellness_controller.dart
import 'package:get/get.dart';
import 'package:sunswept/group/views/webroom/common/wellness_data.dart';

class WellnessController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Ensure reactive vars are properly initialized
    activeChip.value = 'All';
  }

  // ── Search ────────────────────────────────────────────────────────────────
  final searchQuery = ''.obs;

  // ── Active chip (quick filter bar) ────────────────────────────────────────
  final activeChip = 'All'.obs;

  // ── Filter sheet state ────────────────────────────────────────────────────
  final filterCategory = Rxn<String>(); // selected category in filter sheet
  final filterSubcategory =
      Rxn<String>(); // selected subcategory in filter sheet

  // ── Applied filter (committed when user taps APPLY) ───────────────────────
  final appliedCategory = Rxn<String>();
  final appliedSubcategory = Rxn<String>();

  // ── Derived ───────────────────────────────────────────────────────────────
  List<String> get chipCategories => ['All', ...wellnessCategories];

  List<String> get filterSubcategories => filterCategory.value != null
      ? subcategoriesFor(filterCategory.value!)
      : [];

  List<Map<String, dynamic>> get filteredItems {
    var list = wellnessItems.toList();

    // Quick chip filter
    if (activeChip.value != 'All') {
      list = list.where((e) => e['category'] == activeChip.value).toList();
    }

    // Applied filter (category + subcategory)
    if (appliedCategory.value != null) {
      list = list.where((e) => e['category'] == appliedCategory.value).toList();
      if (appliedSubcategory.value != null) {
        list = list
            .where((e) => e['subcategory'] == appliedSubcategory.value)
            .toList();
      }
    }

    // Search
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (e) =>
                (e['title'] as String).toLowerCase().contains(q) ||
                (e['category'] as String).toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  bool get hasActiveFilter =>
      appliedCategory.value != null || appliedSubcategory.value != null;

  // ── Actions ───────────────────────────────────────────────────────────────

  void selectChipCategory(String category) {
    activeChip.value = category;
    appliedCategory.value = null;
    appliedSubcategory.value = null;
    filterCategory.value = null;
    filterSubcategory.value = null;
    update();
  }

  void applyFilter() {
    appliedCategory.value = filterCategory.value;
    appliedSubcategory.value = filterSubcategory.value;
    if (appliedCategory.value != null) {
      activeChip.value = appliedCategory.value!;
    } else {
      activeChip.value = 'All';
    }
    update();
  }

  void clearFilter() {
    filterCategory.value = null;
    filterSubcategory.value = null;
    appliedCategory.value = null;
    appliedSubcategory.value = null;
    activeChip.value = 'All';
    update();
  }

  void openFilterSheet() {
    // Pre-fill sheet with current applied values
    filterCategory.value = appliedCategory.value;
    filterSubcategory.value = appliedSubcategory.value;
  }
}
