// screens/residence/residence_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../../widgets/residence_card.dart';

class ResidenceScreen extends StatefulWidget {
  @override
  _ResidenceScreenState createState() => _ResidenceScreenState();
}

class _ResidenceScreenState extends State<ResidenceScreen> {
  List<dynamic> residences = [];
  List<dynamic> filteredResidences = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedPriceRange = 'All';
  String selectedLocation = 'All';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadResidences();
  }

  Future<void> _loadResidences() async {
    try {
      final data = await ApiService.getResidences();
      setState(() {
        residences = data;
        filteredResidences = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading residences: $e');
    }
  }

  void _filterResidences() {
    setState(() {
      filteredResidences = residences.where((residence) {
        bool matchesSearch = searchQuery.isEmpty ||
            residence['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            residence['address'].toString().toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesCategory = selectedCategory == 'All' ||
            residence['category']['name'].toString().toLowerCase().contains(selectedCategory.toLowerCase());

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Residence'),
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
                        _filterResidences();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search residence...',
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
                      _buildCategoryChip('Kost Putra'),
                      SizedBox(width: 10),
                      _buildCategoryChip('Kost Putri'),
                      SizedBox(width: 10),
                      _buildCategoryChip('Kontrakan'),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Results
                Expanded(
                  child: filteredResidences.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'No residences found',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredResidences.length,
                          itemBuilder: (context, index) {
                            return ResidenceCard(residence: filteredResidences[index]);
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
        _filterResidences();
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
              'Price Range',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildFilterChip('All', selectedPriceRange == 'All'),
                _buildFilterChip('< 1M', selectedPriceRange == '< 1M'),
                _buildFilterChip('1M - 2M', selectedPriceRange == '1M - 2M'),
                _buildFilterChip('> 2M', selectedPriceRange == '> 2M'),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedPriceRange = 'All';
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
                      _filterResidences();
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
          selectedPriceRange = selected ? label : 'All';
        });
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }
}