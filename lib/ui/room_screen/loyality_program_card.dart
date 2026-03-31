import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart' as theme;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoyaltyProgramCard extends StatefulWidget {
  final int discountValue;
  final String termsText;
  final String benefitsTitle;
  final String benefitsSubtitle;
  final String? videoUrl;
  final String? videoThumbnail;
  final String? logoUrl;
  final String? propertyName;
  final String? propertyId;

  final void Function(String email, int percentage)? onJoinSuccess;
  final VoidCallback? onLogout;
  final bool isJoined;
  final int joinedDiscountPercentage;

  const LoyaltyProgramCard({
    Key? key,
    required this.discountValue,
    required this.termsText,
    required this.benefitsTitle,
    required this.benefitsSubtitle,
    this.videoUrl,
    this.videoThumbnail,
    this.logoUrl,
    this.propertyName,
    this.propertyId,
    this.onJoinSuccess,
    this.onLogout,
    this.isJoined = false,
    this.joinedDiscountPercentage = 0,
  }) : super(key: key);

  @override
  State<LoyaltyProgramCard> createState() => _LoyaltyProgramCardState();
}

class _LoyaltyProgramCardState extends State<LoyaltyProgramCard> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _videoInitialized = false;
  bool _videoInitializing = false;
  bool _videoError = false;

  /// True once the user taps the play button — hides the custom overlay
  bool _videoStarted = false;

  bool _isLoading = false;
  bool get _isProgramJoined => widget.isJoined;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Pre-initialise so the player is ready when the user taps play
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // ─── Video init ────────────────────────────────────────────────────────────
  Future<void> _initVideo() async {
    if (_videoInitializing || _videoInitialized) return;
    final url = widget.videoUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _videoInitializing = true;
      _videoError = false;
    });

    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        autoInitialize: false,
        showControlsOnInitialize: false,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: theme.AppColor.primary,
          handleColor: theme.AppColor.primary,
          backgroundColor: Colors.white24,
          bufferedColor: theme.AppColor.primary.withOpacity(0.4),
        ),
        errorBuilder: (ctx, msg) {
          debugPrint('Chewie error: $msg');
          return _buildVideoError();
        },
      );

      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _videoInitialized = true;
        _videoInitializing = false;
      });
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) {
        setState(() {
          _videoInitializing = false;
          _videoError = true;
        });
      }
    }
  }

  /// Called when user taps the custom play overlay
  void _onPlayTapped() {
    if (!_videoInitialized || _chewieController == null) return;
    setState(() => _videoStarted = true);
    _videoController!.play();
    _chewieController!.play();
  }

  // ─── Retry after error ─────────────────────────────────────────────────────
  void _retryVideo() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    setState(() {
      _videoInitialized = false;
      _videoInitializing = false;
      _videoError = false;
      _videoStarted = false;
    });
    _initVideo();
  }

  // ─── Join flow ─────────────────────────────────────────────────────────────
  void _openJoinFlow() {
    if (_isProgramJoined) return;

    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (_, setDlg) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              theme.AppColor.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.card_membership_rounded,
                            color: theme.AppColor.secondary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Join Loyalty Program',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: theme.AppColor.text)),
                            Text(
                                'Unlock ${widget.discountValue}% member discount!',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    hint: 'Enter your name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    controller: emailCtrl,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!GetUtils.isEmail(v)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    controller: mobileCtrl,
                    label: 'Mobile Number',
                    hint: 'Enter mobile',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 10) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dlgCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            side:
                                BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!
                                      .validate()) return;
                                  setDlg(
                                      () => _isLoading = true);

                                  final email =
                                      emailCtrl.text.trim();
                                  final name = nameCtrl.text.trim();
                                  final mobile =
                                      mobileCtrl.text.trim();
                                  final propertyId =
                                      widget.propertyId ?? '';

                                  final checkResult =
                                      await _callCheckDiscount(
                                    email: email,
                                    propertyId: propertyId,
                                  );

                                  if (checkResult['eligible'] ==
                                      true) {
                                    setDlg(
                                        () => _isLoading = false);
                                    if (!mounted) return;
                                    Navigator.pop(dlgCtx);
                                    _handleSuccess(
                                      email: email,
                                      percentage: checkResult[
                                              'percentage'] as int,
                                    );
                                    return;
                                  }

                                  final regResult =
                                      await _callRegister(
                                    email: email,
                                    propertyId: propertyId,
                                    guestName: name,
                                    mobileNumber: mobile,
                                  );

                                  setDlg(() => _isLoading = false);
                                  if (!mounted) return;
                                  Navigator.pop(dlgCtx);

                                  if (regResult['eligible'] ==
                                      true) {
                                    _handleSuccess(
                                      email: email,
                                      percentage: regResult[
                                              'percentage'] as int,
                                    );
                                  } else {
                                    _showErrorSnack(
                                      regResult['message']
                                              as String? ??
                                          'Something went wrong.',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.AppColor.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Join & Get Discount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSuccess(
      {required String email, required int percentage}) {
    widget.onJoinSuccess?.call(email, percentage);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text('$percentage% member discount applied!',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white)),
      ]),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(message,
                style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<Map<String, dynamic>> _callCheckDiscount({
    required String email,
    required String propertyId,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(
                'https://bookings.revchilltech.com/api/v1/loyalty/guest/check-discount'),
            headers: {'Content-Type': 'application/json'},
            body: json
                .encode({'email': email, 'propertyId': propertyId}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final msg = (data['message'] as String? ?? '').toLowerCase();
        if (msg.contains('already registered')) {
          final pct =
              (data['data']?['discount']?['value'] as num?)?.toInt() ??
                  10;
          return {'eligible': true, 'percentage': pct};
        }
        if (data['success'] == true && data['data'] != null) {
          final d = data['data'];
          if (d['isLoyaltyMember'] == true) {
            final pct =
                (d['discount']?['value'] as num?)?.toInt() ?? 10;
            return {'eligible': true, 'percentage': pct};
          }
        }
      }
    } catch (_) {}
    return {'eligible': false};
  }

  Future<Map<String, dynamic>> _callRegister({
    required String email,
    required String propertyId,
    required String guestName,
    required String mobileNumber,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(
                'https://bookings.revchilltech.com/api/v1/loyalty/guest/check-discount'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'propertyId': propertyId,
              'metadata': {
                'Guest Name': guestName,
                'Mobile Number': mobileNumber,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final msg = (data['message'] as String? ?? '').toLowerCase();
        if (msg.contains('already registered')) {
          final pct =
              (data['data']?['discount']?['value'] as num?)?.toInt() ??
                  10;
          return {'eligible': true, 'percentage': pct};
        }
        if (data['success'] == true) {
          final d = data['data'];
          final pct =
              (d?['discount']?['value'] as num?)?.toInt() ?? 10;
          return {'eligible': true, 'percentage': pct};
        }
        return {
          'eligible': false,
          'message': data['message'] ?? 'Not eligible',
        };
      }
      return {'eligible': false, 'message': 'Server error'};
    } catch (_) {
      return {'eligible': false, 'message': 'Network error. Try again.'};
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVideoSection(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 6),
                Divider(color: Colors.grey[200], thickness: 1),
                const SizedBox(height: 5),
                if (widget.termsText.isNotEmpty) ...[
                  _sectionLabel(Icons.verified_outlined,
                      'Program Terms', const Color(0xFF2E7D32)),
                  const SizedBox(height: 8),
                  _termsRow(widget.termsText),
                  const SizedBox(height: 8),
                  _oneTermLabel(
                      icon: Icons.local_offer_outlined,
                      discountValue: widget.discountValue.toDouble()),
                  const SizedBox(height: 14),
                ],
                if (widget.benefitsTitle.isNotEmpty) ...[
                  _sectionLabel(Icons.star_outline_rounded,
                      'Special Benefits', const Color(0xFFB8860B)),
                  const SizedBox(height: 8),
                  _benefitsList(
                      widget.benefitsTitle, widget.benefitsSubtitle),
                  const SizedBox(height: 14),
                ],
                Divider(color: Colors.grey[200], thickness: 1),
                _buildBottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Video section ─────────────────────────────────────────────────────────
  Widget _buildVideoSection() {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(15)),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Always show Chewie when initialized ──────────────────
            if (_videoInitialized && _chewieController != null)
              Chewie(controller: _chewieController!)
            else if (_videoError)
              _buildVideoError()
            else
              _buildThumbnail(),

            // ── Custom play overlay (shown until user taps play) ─────
            if (!_videoStarted && !_videoError)
              GestureDetector(
                onTap: _videoInitialized
                    ? _onPlayTapped
                    : null, // do nothing while still loading
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail behind overlay when not yet initialized
                      if (!_videoInitialized) _buildThumbnail(),

                      // Semi-dark gradient at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Play button circle
                      Center(
                        child: AnimatedOpacity(
                          opacity: _videoInitializing ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 2,
                              ),
                            ),
                            child: _videoInitializing
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),

                      // Property name label
                      Positioned(
                        bottom: 14,
                        left: 14,
                        child: Text(
                          '${widget.propertyName ?? ''} – Property Tour',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (widget.videoThumbnail != null &&
        widget.videoThumbnail!.isNotEmpty) {
      return Image.network(
        widget.videoThumbnail!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholderBox(),
      );
    }
    return _placeholderBox();
  }

  Widget _placeholderBox() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.videocam_outlined,
            size: 48, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildVideoError() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.grey[500]),
          const SizedBox(height: 8),
          Text('Video unavailable',
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _retryVideo,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: theme.AppColor.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 16, color: theme.AppColor.primary),
                  const SizedBox(width: 6),
                  Text('Retry',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.AppColor.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Other UI helpers (unchanged) ─────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty)
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.grey[200]!, width: 1.5),
              image: DecorationImage(
                image: NetworkImage(widget.logoUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.propertyName ?? 'Loyalty Program',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.AppColor.text)),
              Text('Loyalty Program',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isProgramJoined
                ? Colors.green
                : theme.AppColor.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isProgramJoined
                ? '${widget.joinedDiscountPercentage}% OFF ✓'
                : '${widget.discountValue}% OFF',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.AppColor.text)),
      ],
    );
  }

  Widget _oneTermLabel(
      {required IconData icon,
      String? discountText,
      double? discountValue}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.AppColor.secondary),
        const SizedBox(width: 6),
        if (discountText != null)
          Text(discountText,
              style: TextStyle(
                  fontSize: 12,
                  color: theme.AppColor.secondary,
                  fontWeight: FontWeight.w600))
        else if (discountValue != null)
          Text('${discountValue.toInt()}% members only discount',
              style: TextStyle(
                  fontSize: 12,
                  color: theme.AppColor.secondary,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _termsRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline,
            size: 15, color: Color(0xFF2E7D32)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5)),
        ),
      ],
    );
  }

  Widget _benefitsList(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.star_outline_rounded,
                size: 15, color: Color(0xFFB8860B)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.5)),
            ),
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.AppColor.secondary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color:
                      theme.AppColor.secondary.withOpacity(0.25)),
            ),
            child: Text(subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.AppColor.secondary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomRow() {
    return Column(
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _isProgramJoined,
                onChanged: (value) {
                  if (value && !_isProgramJoined) _openJoinFlow();
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.green.withOpacity(0.5),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!_isProgramJoined) _openJoinFlow();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isProgramJoined
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isProgramJoined
                        ? Colors.green
                        : theme.AppColor.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isProgramJoined
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      size: 16,
                      color: _isProgramJoined
                          ? Colors.green
                          : theme.AppColor.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isProgramJoined ? 'Joined ✓' : 'Join Program',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isProgramJoined
                              ? Colors.green
                              : theme.AppColor.secondary),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_isProgramJoined)
              GestureDetector(
                onTap: widget.onLogout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout_rounded,
                          size: 15, color: Colors.orange),
                      SizedBox(width: 5),
                      Text('Logout',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange)),
                    ],
                  ),
                ),
              )
            else if (widget.logoUrl != null &&
                widget.logoUrl!.isNotEmpty)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.grey[200]!, width: 1.5),
                  image: DecorationImage(
                    image: NetworkImage(widget.logoUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        if (!_isProgramJoined)
          Row(
            children: [
              GestureDetector(
                onTap: _openJoinFlow,
                child: RichText(
                  text: TextSpan(
                    text: 'Are you registered? ',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600]),
                    children: [
                      TextSpan(
                        text: 'Identify yourself',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.AppColor.secondary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        if (_isProgramJoined) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Colors.green.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 14, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.joinedDiscountPercentage}% discount is active on all rate plans',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
            color: theme.AppColor.primary, fontSize: 13),
        hintStyle:
            TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon,
            color: theme.AppColor.secondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: theme.AppColor.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
      ),
      validator: validator,
    );
  }
}