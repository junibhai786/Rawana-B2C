import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/search_hotel_provider.dart';
import 'package:moonbnd/Provider/currency_provider.dart';
import 'package:moonbnd/modals/hotel_search_model.dart';

class HotelListScreen extends StatelessWidget {
  final String city;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final int rooms;

  const HotelListScreen({
    Key? key,
    required this.city,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.rooms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger search when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchHotelProvider>().searchHotels(
            city: city,
            checkIn: checkIn,
            checkOut: checkOut,
            adults: adults,
            children: children,
            rooms: rooms,
            currency: context.read<CurrencyProvider>().selectedCurrency,
          );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hotels in $city'),
        elevation: 0,
      ),
      body: Consumer<SearchHotelProvider>(
        builder: (context, provider, _) {
          // Loading state
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Searching hotels...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<SearchHotelProvider>().resetSearch(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.hotels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hotel, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No hotels found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search dates or location',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          // Hotels list
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.hotels.length,
            itemBuilder: (context, index) {
              final hotel = provider.hotels[index];
              return HotelCard(hotel: hotel);
            },
          );
        },
      ),
    );
  }
}

/// Hotel card widget
class HotelCard extends StatelessWidget {
  final HotelModel hotel;

  const HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final imageUrl = hotel.images.isNotEmpty
        ? hotel.images.first
        : 'https://via.placeholder.com/300x200?text=No+Image';

    final priceToShow = hotel.lowestPrice ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('No image',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Hotel details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star rating and provider badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Star rating
                    if (hotel.starRating != null)
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (_toInt(hotel.starRating) ?? 0)
                                ? Icons.star
                                : Icons.star_outline,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    // Provider badge
                    if (hotel.provider != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hotel.provider == 'local'
                              ? Colors.blue[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hotel.provider!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: hotel.provider == 'local'
                                ? Colors.blue[700]
                                : Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Hotel name
                Text(
                  hotel.name ?? 'Unknown Hotel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Address
                if (hotel.address != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.address!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                // Price and button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        Text(
                          '${_toDouble(priceToShow).toStringAsFixed(0)} ${hotel.currency ?? 'USD'}/night',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to room selection or hotel details
                        // Navigator.push(context, MaterialPageRoute(...))
                      },
                      child: Text(
                          '${hotel.rooms.length} Room${hotel.rooms.length != 1 ? 's' : ''}'),
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

  /// Safe conversion to int
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safe conversion to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
