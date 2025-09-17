import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../../widgets/activity_card.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<dynamic> activities = [];
  List<dynamic> filteredActivities = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedStatus = 'All';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final data = await ApiService.getActivities();
      setState(() {
        activities = data;
        filteredActivities = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading activities: $e');
    }
  }

  void _filterActivities() {
    setState(() {
      filteredActivities = activities.where((activity) {
        bool matchesSearch = searchQuery.isEmpty ||
            activity['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            activity['description'].toString().toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesCategory = selectedCategory == 'All' ||
            activity['category']['name'].toString().toLowerCase().contains(selectedCategory.toLowerCase());

        bool matchesStatus = selectedStatus == 'All' ||
            activity['registration_status'].toString() == selectedStatus.toLowerCase();

        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        searchQuery = value;
                        _filterActivities();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search activities...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),

                // Category Chips
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip('All'),
                      SizedBox(width: 10),
                      _buildCategoryChip('Aktivitas Kampus'),
                      SizedBox(width: 10),
                      _buildCategoryChip('Aktivitas non-kampus'),
                      SizedBox(width: 10),
                      _buildCategoryChip('Seminar'),
                      SizedBox(width: 10),
                      _buildCategoryChip('Workshop'),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Results
                Expanded(
                  child: filteredActivities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'No activities found',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredActivities.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 15),
                              child: ActivityCard(activity: filteredActivities[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
        _filterActivities();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          category,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Registration Status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildFilterChip('All', selectedStatus == 'All'),
                _buildFilterChip('Open', selectedStatus == 'open'),
                _buildFilterChip('Closed', selectedStatus == 'closed'),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedStatus = 'All';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Reset'),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _filterActivities();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text('Apply', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedStatus = selected ? (label == 'All' ? 'All' : label.toLowerCase()) : 'All';
        });
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }
}