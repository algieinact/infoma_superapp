// screens/bookmark/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/residence_card.dart';
import '../../widgets/activity_card.dart';
import '../../services/api_service.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
    List<Map<String, dynamic>> bookmarkedResidences = [];
  List<Map<String, dynamic>> bookmarkedActivities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      setState(() {
        isLoading = true;
      });

      final bookmarks = await ApiService.getBookmarks();
      
      final residences = <Map<String, dynamic>>[];
      final activities = <Map<String, dynamic>>[];

      for (var bookmark in bookmarks) {
        final item = bookmark['item'];
        if (item != null) {
          if (bookmark['type'] == 'Residence') {
            residences.add(Map<String, dynamic>.from(item));
          } else if (bookmark['type'] == 'Activity') {
            activities.add(Map<String, dynamic>.from(item));
          }
        }
      }

      setState(() {
        bookmarkedResidences = residences;
        bookmarkedActivities = activities;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Bookmarks'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: 'Residences'),
            Tab(text: 'Activities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Residences Tab
          _buildResidencesList(),
          // Activities Tab
          _buildActivitiesList(),
        ],
      ),
    );
  }

  Widget _buildResidencesList() {
    return bookmarkedResidences.isEmpty
        ? _buildEmptyState('No bookmarked residences', Icons.home_work_outlined)
        : GridView.builder(
            padding: EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            itemCount: bookmarkedResidences.length,
            itemBuilder: (context, index) {
              return ResidenceCard(residence: bookmarkedResidences[index]);
            },
          );
  }

  Widget _buildActivitiesList() {
    return bookmarkedActivities.isEmpty
        ? _buildEmptyState('No bookmarked activities', Icons.event_outlined)
        : ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: bookmarkedActivities.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 15),
                child: ActivityCard(activity: bookmarkedActivities[index]),
              );
            },
          );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start bookmarking to see them here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}