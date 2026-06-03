// meetings_events_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class MeetingsEventsListPage extends StatelessWidget {
  final List<dynamic> meetingsEvents;
  final String? title;

  const MeetingsEventsListPage({
    super.key,
    required this.meetingsEvents,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        titleSpacing: 5,
        title: Row(
          children: [
            Container(
              width: 3.5,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Meetings & Events",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? 'Our Venues',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: meetingsEvents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 56,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No meetings or events available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conference and meeting spaces for every event',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final meetingEvent =
                          meetingsEvents[index] as Map<String, dynamic>;
                      final name =
                          meetingEvent['name'] as String? ?? 'Untitled Event';
                      final imageUrl = meetingEvent['image'] as String? ?? '';
                      final description =
                          meetingEvent['description'] as String? ?? '';
                      final capacity =
                          meetingEvent['capacity'] as String? ?? '';
                      final area = meetingEvent['area'] as String? ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _MeetingEventCard(
                          name: name,
                          imageUrl: imageUrl,
                          description: description,
                          capacity: capacity,
                          area: area,
                        ),
                      );
                    }, childCount: meetingsEvents.length),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
    );
  }
}

class _MeetingEventCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String description;
  final String capacity;
  final String area;

  const _MeetingEventCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
    this.capacity = '',
    this.area = '',
  });

  @override
  State<_MeetingEventCard> createState() => _MeetingEventCardState();
}

class _MeetingEventCardState extends State<_MeetingEventCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.description.trim().isNotEmpty;
    final hasCapacity = widget.capacity.trim().isNotEmpty;
    final hasArea = widget.area.trim().isNotEmpty;
    final shouldShowToggle = widget.description.trim().length > 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top accent line (NEW) ──
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primary, AppColor.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),

          // ── Content padding ──
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title with icon row (NEW) ──
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        size: 22,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasCapacity || hasArea) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                if (hasCapacity)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 13,
                                        color: AppColor.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.capacity,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (hasArea)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.crop_square_outlined,
                                        size: 13,
                                        color: AppColor.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.area,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Image (smaller, rounded, side-by-side with desc on desktop? no, stacked but elegant) ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Description ──
                if (hasDescription)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description,
                        maxLines: _expanded ? null : 3,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.5,
                          height: 1.6,
                        ),
                      ),
                      if (shouldShowToggle)
                        GestureDetector(
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _expanded ? 'Read less' : 'Read more',
                              style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 14),

                // ── Footer motif (-·- design) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Row(
                    children: [
                      const Spacer(),
                       // ← Pushes everything to the right
                       Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 32,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(2),
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

  Widget _placeholder() {
    return Container(
      height: 180,
      color: AppColor.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.meeting_room_outlined,
          size: 42,
          color: AppColor.primary.withOpacity(0.35),
        ),
      ),
    );
  }
}
