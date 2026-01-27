import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/search_hotel_provider.dart'; // ✅ Updated import
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:moonbnd/screens/hotel/room_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../wishlist/wishlist_screen.dart';
import 'filter_screen.dart';

class HotelSearchResultsScreen extends StatefulWidget {
  final int? city;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;

  const HotelSearchResultsScreen({
    super.key,
    this.city,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
  });

  @override
  State<HotelSearchResultsScreen> createState() =>
      _HotelSearchResultsScreenState();
}

class _HotelSearchResultsScreenState extends State<HotelSearchResultsScreen> {
  late ScrollController _scrollController;
  String selectedSort = 'Recommended'.tr;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchInitialData() async {
    await Provider.of<SearchHotelProvider>(context, listen: false).searchHotels(
      searchParams: {
        'city': widget.city,
        'check_in': widget.checkInDate,
        'check_out': widget.checkOutDate,
        'guests': widget.guests,
      },
    );
  }

  Future<void> _fetchMoreData() async {
    await Provider.of<SearchHotelProvider>(context, listen: false).searchHotels(
      searchParams: {
        'city': widget.city,
        'check_in': widget.checkInDate,
        'check_out': widget.checkOutDate,
        'guests': widget.guests,
      },
      isLoadMore: true,
    );
  }

  Future<void> _onRefresh() async {
    await _fetchInitialData();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'No Hotels Found'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'We couldn\'t find any hotels matching your search criteria.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search parameters.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff05A8C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Modify Search'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return _HotelCardWidget(hotel: hotel, city: widget.city);
  }

  Widget _buildResultsCount(SearchHotelProvider searchProvider) {
    final itemCount = searchProvider.total;
    final locationName = widget.city ?? 'Paris, France'.tr;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$itemCount hotels found in $locationName'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff65758B),
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FilterScreen(),
                  ));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/filters.svg',
                      color: Color(0xff05A8C7),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Filters'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Color(0xff05A8C7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Available Hotels'.tr,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.favorite_border, color: Color(0xff65758B)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WishlistScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<SearchHotelProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final hotels = searchProvider.hotels;

          if (hotels.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultsCount(searchProvider),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 16),
                    itemCount:
                        hotels.length + (searchProvider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == hotels.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildHotelCard(hotels[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HotelCardWidget extends StatefulWidget {
  final Hotel hotel;
  final int? city;

  const _HotelCardWidget({required this.hotel, this.city});

  @override
  State<_HotelCardWidget> createState() => _HotelCardWidgetState();
}

class _HotelCardWidgetState extends State<_HotelCardWidget> {
  bool isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.hotel.translation?.title ?? widget.hotel.title ?? 'Hotel Name';
    final rating = double.tryParse(widget.hotel.reviewScore ?? '4.5') ?? 4.5;
    final location = widget.hotel.location?.name ??
        widget.hotel.address ??
        widget.city ??
        'Paris, France';
    final reviewCount = widget.hotel.reviewCount ?? 100;
    final distance = 2.3;

    final originalPrice = double.tryParse(widget.hotel.price ?? '0');
    final salePrice = widget.hotel.salePrice != null
        ? double.tryParse(widget.hotel.salePrice.toString())
        : null;
    final discountedPrice = salePrice ?? originalPrice;

    final amenities = widget.hotel.policy
            ?.map((p) => p.title ?? '')
            .where((title) => title.isNotEmpty)
            .toList() ??
        ['WiFi', 'Pool', 'Breakfast'];

    final isBestSeller = widget.hotel.isFeatured == 1 || rating >= 4.8;
    final isLuxury =
        widget.hotel.starRate != null && widget.hotel.starRate! >= 4 ||
            rating >= 4.7;
    final isPopular =
        widget.hotel.reviewCount != null && widget.hotel.reviewCount! > 500;

    final hasPrice = originalPrice != null && originalPrice > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[100]!, Colors.blue[50]!],
              ),
            ),
            child: Stack(
              children: [
                if (widget.hotel.bannerImgUrl != null &&
                    widget.hotel.bannerImgUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      widget.hotel.bannerImgUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular)
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xff4CAF50),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Popular',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isBestSeller)
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xffF3C85B),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            'Best Seller',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (isLuxury)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xffF3C85B),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            'Luxury',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Color(0xff65758B),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Color(0xffF3C85B), size: 17),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1D2025),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/location.svg',
                      color: Color(0xff65758B),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location.toString(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$reviewCount reviews'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      '${distance.toStringAsFixed(1)} km to city center'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: amenities.take(4).map((amenity) {
                    return Chip(
                      label: Text(
                        amenity,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Color(0xffF1F5F9),
                      labelPadding: EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasPrice &&
                            discountedPrice != null &&
                            originalPrice != null &&
                            originalPrice > discountedPrice)
                          Text(
                            '\$${originalPrice.toInt()}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '\$${(discountedPrice ?? originalPrice)?.toInt() ?? 0}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff05A8C7),
                                ),
                              ),
                              TextSpan(
                                text: ' /night'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff65758B),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomDetailScreen(
                              hotelId: widget.hotel.id!,
                              // Pass hotel data here
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff05A8C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 2,
                      ),
                      child: Text(
                        hasPrice ? 'View Deal'.tr : 'View Details',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
