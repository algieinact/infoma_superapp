import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class ActivityDetailScreen extends StatefulWidget {
  final int activityId;

  const ActivityDetailScreen({Key? key, required this.activityId})
    : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool isLoading = true;
  bool isBookmarking = false;
  bool isBookmarked = false;
  Map<String, dynamic>? activityData;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadActivityDetail();
  }

  Future<void> _refreshBookmarkStatus() async {
    try {
      final bookmarks = await ApiService.getBookmarks();
      final isBookmarkedActivity = bookmarks.any(
        (bookmark) =>
            bookmark['type'] == 'Activity' &&
            bookmark['item']?['id'] == widget.activityId,
      );

      if (mounted) {
        setState(() {
          isBookmarked = isBookmarkedActivity;
        });
      }
    } catch (e) {
      print('Error refreshing bookmark status: $e');
    }
  }

  Future<void> _loadActivityDetail() async {
    try {
      final data = await ApiService.getActivityDetail(widget.activityId);
      final bookmarks = await ApiService.getBookmarks();

      final isBookmarkedActivity = bookmarks.any(
        (bookmark) =>
            bookmark['type'] == 'Activity' &&
            bookmark['item']?['id'] == widget.activityId,
      );

      if (mounted) {
        setState(() {
          activityData = data;
          isBookmarked = isBookmarkedActivity;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading activity detail: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (isBookmarking) return;

    try {
      setState(() {
        isBookmarking = true;
      });

      final previousState = isBookmarked;
      bool success;

      if (previousState) {
        success = await ApiService.removeBookmark(
          'activity',
          widget.activityId,
        );
      } else {
        success = await ApiService.addBookmark('activity', widget.activityId);
      }

      if (success) {
        await _refreshBookmarkStatus(); // Refresh status after toggle
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (previousState ? 'Bookmark removed' : 'Bookmark added')
                : 'Failed to update bookmark',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update bookmark'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isBookmarking = false;
        });
      }
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(double.parse(price.toString()));
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'No date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return 'No time';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      print('Error parsing time: $e');
      return 'Invalid time';
    }
  }

  bool _isRegistrationOpen(String? deadlineString) {
    if (deadlineString == null) return false;
    try {
      final deadline = DateTime.parse(deadlineString);
      return deadline.isAfter(DateTime.now());
    } catch (e) {
      print('Error parsing registration deadline: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activity = activityData?['data'] ?? {};
    final List<String> images = List<String>.from(activity['images'] ?? []);
    final bool isOpen = _isRegistrationOpen(
      activity['registration_deadline']?.toString(),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return images.isEmpty
                          ? Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported, size: 64),
                            )
                          : CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            );
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images
                            .asMap()
                            .entries
                            .map(
                              (entry) => Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentImageIndex == entry.key
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['name'] ?? 'Untitled Activity',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatPrice(activity['price']),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Location',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity['address'] ?? 'No address provided',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    activity['description'] ?? 'No description provided',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBookmarking ? null : _toggleBookmark,
                icon: isBookmarking
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      )
                    : Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isOpen && activity['available_slots'] > 0
                    ? () {
                        // TODO: Implement registration functionality
                      }
                    : null,
                icon: Icon(Icons.app_registration),
                label: Text('Register'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
