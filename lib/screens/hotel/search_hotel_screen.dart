// Create a new file: hotel_search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../home/home_screen.dart';
import 'filter_screen.dart';
import 'map_screen.dart';

// Add this class at the end of your current file (after the last class)

class HotelSearchResultsScreen extends StatefulWidget {
  final String? city;
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
  State<HotelSearchResultsScreen> createState() => _HotelSearchResultsScreenState();
}

class _HotelSearchResultsScreenState extends State<HotelSearchResultsScreen> {
  bool isLoading = false;
  String selectedSort = 'Recommended'.tr;

  @override
  void initState() {
    super.initState();
    _fetchHotelData();
  }

  Future<void> _fetchHotelData() async {
    setState(() {
      isLoading = true;
    });

    await Provider.of<HomeProvider>(context, listen: false)
        .hotellistapi(1, searchParams: {
      'city': widget.city,
      'check_in': widget.checkInDate?.toIso8601String(),
      'check_out': widget.checkOutDate?.toIso8601String(),
      'guests': widget.guests,
    }).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget _buildResultsCount(HomeProvider homeProvider) {
    final hotelList = homeProvider.hotelListPerCategory[1];
    final itemCount = hotelList?.data?.length ?? 0;
    final startId = hotelList?.startId ?? 1;
    final endId = hotelList?.endId ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$itemCount ${'items found'.tr}'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                  fontFamily: 'Inter'.tr,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '${'Showing'.tr} $startId - $endId ${'of'.tr} $itemCount ${'items'.tr}',
              style: TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _showSortingOptions();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Row(
                  children: [
                    Text(selectedSort),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(width: 6),
            InkWell(
              onTap: () {
                final homeProvider = Provider.of<HomeProvider>(context, listen: false);
                final hotelList = homeProvider.hotelListPerCategory[1];
                if (hotelList != null && hotelList.data != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(),
                    ),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Row(
                  children: [
                    Text('Show on the map'.tr),
                    SizedBox(width: 5),
                    Icon(Icons.map, size: 16),
                  ],
                ),
              ),
            ),
            SizedBox(width: 6),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FilterScreen(),
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Row(
                  children: [
                    Text('Filter'.tr),
                    Icon(Icons.filter_alt, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortingOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort By'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            _buildSortOption('Price (High to Low)'.tr, 'price_high_low'),
            Divider(),
            _buildSortOption('Price (Low to High)'.tr, 'price_low_high'),
            Divider(),
            _buildSortOption('Rating (High to Low)'.tr, 'rate_high_low'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String sortBy) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() => selectedSort = title);
        Navigator.pop(context);
        _fetchSortedData(sortBy);
      },
    );
  }

  void _fetchSortedData(String sortBy) {
    setState(() {
      isLoading = true;
    });

    Provider.of<HomeProvider>(context, listen: false)
        .hotellistapi(1, sortBy: sortBy, searchParams: {
      'city': widget.city,
      'check_in': widget.checkInDate?.toIso8601String(),
      'check_out': widget.checkOutDate?.toIso8601String(),
      'guests': widget.guests,
    }).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Search Results'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final hotelList = homeProvider.hotelListPerCategory[1] ?? HotelList();

          return Column(
            children: [
              // Display search parameters summary
              if (widget.city != null && widget.city!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Search: ${widget.city}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              _buildResultsCount(homeProvider),
              _buildFilterTabs(),
              Expanded(
                child: PropertyList(hotelList: hotelList),
              ),
            ],
          );
        },
      ),
    );
  }
}