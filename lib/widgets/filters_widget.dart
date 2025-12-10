import 'package:moonbnd/data_models/all_space_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../constants.dart';

class ResultsCount extends StatelessWidget {
  final int totalResults;
  final int startRange;
  final int endRange;
  final String itemType;

  const ResultsCount({
    Key? key,
    required this.totalResults,
    required this.startRange,
    required this.endRange,
    required this.itemType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$totalResults $itemType found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          Text(
            'Showing $startRange - $endRange of $totalResults $itemType',
            style: TextStyle(
              color: grey,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class FilterTabs extends StatelessWidget {
  final String selectedSort;
  final VoidCallback onSortTap;
  final VoidCallback onMapTap;
  final VoidCallback onFilterTap;

  const FilterTabs({
    Key? key,
    required this.selectedSort,
    required this.onSortTap,
    required this.onMapTap,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          _buildSortButton(),
          SizedBox(width: 8),
          _buildMapButton(context),
          SizedBox(width: 8),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return InkWell(
      onTap: onSortTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Row(
          children: [
            Text(selectedSort),
            SizedBox(width: 5),
            SvgPicture.asset('assets/icons/arrow_down.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(BuildContext context) {
    return InkWell(
      onTap: onMapTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Row(
          children: [
            Text('Show on the map'.tr),
            SizedBox(width: 5),
            SvgPicture.asset('assets/icons/map_icon.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return InkWell(
      onTap: onFilterTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Row(
          children: [
            Text('Filter'),
            SvgPicture.asset('assets/icons/filter_icon.svg'),
          ],
        ),
      ),
    );
  }
}
