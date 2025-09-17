import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/residence/residence_detail_screen.dart';

class ResidenceCard extends StatelessWidget {
  final Map<String, dynamic> residence;
  final bool isGridView;

  const ResidenceCard({
    Key? key,
    required this.residence,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isGridView ? null : 200,
      margin: EdgeInsets.only(right: isGridView ? 0 : 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ResidenceDetailScreen(residenceId: residence['id']),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Residence Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: residence['image_url'] ?? '',
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.error),
                  ),
                ),
              ),

              // Residence Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        residence['category']['name'] ?? 'Uncategorized',
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Title
                    Text(
                      residence['name'] ?? 'Untitled Residence',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            residence['address'] ?? 'No address',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Price
                    Text(
                      'Rp ${_formatPrice(residence['price'] ?? 0)}',
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    // Convert string to double if needed
    double numericPrice;
    if (price is String) {
      numericPrice = double.tryParse(price.replaceAll(',', '')) ?? 0.0;
    } else if (price is int) {
      numericPrice = price.toDouble();
    } else if (price is double) {
      numericPrice = price;
    } else {
      numericPrice = 0.0;
    }

    if (numericPrice >= 1000000) {
      double millions = numericPrice / 1000000;
      return '${millions.toStringAsFixed(1)}M';
    } else if (numericPrice >= 1000) {
      double thousands = numericPrice / 1000;
      return '${thousands.toStringAsFixed(1)}K';
    }
    return numericPrice.toStringAsFixed(0);
  }
}
