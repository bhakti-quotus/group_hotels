import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Color _kPrimary = Color(0xFFE8334A);
const Color _kNavy = Color(0xFF1A2E6C);
const Color _kBg = Color(0xFFF4F6FA);

// ═══════════════════════════════════════════════════════════════════════════════
// PERSONAL INFO PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _OccasionItem {
  String type;
  DateTime date;
  _OccasionItem({required this.type, required this.date});
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // Personal info fields
  String _firstName = 'Alex';
  String _lastName = 'XYZ';
  String _email = 'alex@appnosticworx.com';

  // Special occasions
  final List<_OccasionItem> _occasions = [
    _OccasionItem(
        type: 'Anniversary', date: DateTime(2020, 4, 18)),
    _OccasionItem(
        type: 'Birthday', date: DateTime(1980, 4, 28)),
  ];

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  // ── Edit personal field bottom sheet ───────────────────────────────────────
  void _editField(String label, String current, ValueChanged<String> onSave) {
    final ctrl = TextEditingController(text: current);
    Get.bottomSheet(
      _FieldSheet(label: label, controller: ctrl, onConfirm: onSave),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Add / edit occasion bottom sheet ───────────────────────────────────────
  void _openOccasionSheet({_OccasionItem? existing, int? index}) {
    Get.bottomSheet(
      _OccasionSheet(
        existing: existing,
        onConfirm: (item) {
          setState(() {
            if (index != null) {
              _occasions[index] = item;
            } else {
              _occasions.add(item);
            }
          });
        },
        onDelete: index != null
            ? () => setState(() => _occasions.removeAt(index))
            : null,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kNavy),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Personal info',
            style: TextStyle(
                color: _kNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Personal Information card ─────────────────────────
              const Text('Personal information',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _kNavy)),
              const SizedBox(height: 8),
              _InfoCard(children: [
                _InfoRow(
                  label: 'First Name:',
                  value: _firstName,
                  onTap: () => _editField(
                      'First Name', _firstName,
                      (v) => setState(() => _firstName = v)),
                ),
                _Divider(),
                _InfoRow(
                  label: 'Last Name:',
                  value: _lastName,
                  onTap: () => _editField(
                      'Last Name', _lastName,
                      (v) => setState(() => _lastName = v)),
                ),
                _Divider(),
                _InfoRow(
                  label: 'Email:',
                  value: _email,
                  onTap: () => _editField(
                      'Email', _email,
                      (v) => setState(() => _email = v)),
                ),
              ]),

              const SizedBox(height: 20),

              // ── Special Occasion card ─────────────────────────────
              const Text('Special Occasion',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _kNavy)),
              const SizedBox(height: 8),
              _InfoCard(
                children: [
                  ...List.generate(_occasions.length, (i) {
                    final occ = _occasions[i];
                    return Column(
                      children: [
                        _InfoRow(
                          label: '${occ.type}:',
                          value: _fmt(occ.date),
                          onTap: () => _openOccasionSheet(
                              existing: occ, index: i),
                        ),
                        if (i < _occasions.length - 1) _Divider(),
                      ],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // ── Add New Date button ───────────────────────────────
              GestureDetector(
                onTap: () => _openOccasionSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ADD NEW DATE',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8),
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

// ─── Info card container ──────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

// ─── Single info row ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _InfoRow(
      {required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF333333))),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
      height: 1, thickness: 1, color: Colors.grey.shade100,
      indent: 16, endIndent: 16);
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET — edit a text field (email / name)
// ═══════════════════════════════════════════════════════════════════════════════
class _FieldSheet extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onConfirm;
  const _FieldSheet(
      {required this.label,
      required this.controller,
      required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle + title row
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: _kNavy, size: 22),
              ),
              const Spacer(),
              Text('Add $label',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _kNavy)),
              const Spacer(),
              const SizedBox(width: 22),
            ],
          ),
          const SizedBox(height: 28),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          _OutlineField(controller: controller),
          const SizedBox(height: 32),
          _ConfirmButton(
            onTap: () {
              onConfirm(controller.text.trim());
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET — add / edit occasion
// ═══════════════════════════════════════════════════════════════════════════════
class _OccasionSheet extends StatefulWidget {
  final _OccasionItem? existing;
  final ValueChanged<_OccasionItem> onConfirm;
  final VoidCallback? onDelete;
  const _OccasionSheet(
      {this.existing, required this.onConfirm, this.onDelete});

  @override
  State<_OccasionSheet> createState() => _OccasionSheetState();
}

class _OccasionSheetState extends State<_OccasionSheet> {
  static const _types = [
    'Birthday',
    'Anniversary',
    'Wedding',
    'Graduation',
    'Other',
  ];

  late String _selectedType;
  late DateTime _selectedDate;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existing?.type ?? 'Birthday';
    _selectedDate = widget.existing?.date ?? DateTime.now();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kPrimary,
            onPrimary: Colors.white,
            onSurface: _kNavy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: _kNavy, size: 22),
              ),
              const Spacer(),
              Text(
                widget.existing != null
                    ? 'Edit ${widget.existing!.type}'
                    : 'Add Birthday Date',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _kNavy),
              ),
              const Spacer(),
              const SizedBox(width: 22),
            ],
          ),
          const SizedBox(height: 28),

          // ── Special Occasion dropdown ─────────────────────────────
          Text('Special Occasion',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () =>
                setState(() => _showDropdown = !_showDropdown),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_selectedType,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF333333))),
                  ),
                  Icon(
                    _showDropdown
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Dropdown options
          if (_showDropdown)
            Container(
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: _types.map((t) {
                  final sel = t == _selectedType;
                  return InkWell(
                    onTap: () => setState(() {
                      _selectedType = t;
                      _showDropdown = false;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(t,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: sel
                                        ? _kPrimary
                                        : const Color(0xFF333333),
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                          if (sel)
                            const Icon(Icons.check,
                                size: 16, color: _kPrimary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // ── Date picker ───────────────────────────────────────────
          Text('Date',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_fmt(_selectedDate),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF333333))),
                  ),
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Confirm button ────────────────────────────────────────
          _ConfirmButton(
            onTap: () {
              widget.onConfirm(
                  _OccasionItem(type: _selectedType, date: _selectedDate));
              Get.back();
            },
          ),

          // ── Delete (only on edit) ─────────────────────────────────
          if (widget.onDelete != null) ...[
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  widget.onDelete!();
                  Get.back();
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                      letterSpacing: 0.5),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Reusable outline text field ──────────────────────────────────────────────
class _OutlineField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  const _OutlineField({required this.controller, this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kNavy, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ─── Confirm button ───────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: const Text(
          'CONFIRM',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.4),
        ),
      ),
    );
  }
}