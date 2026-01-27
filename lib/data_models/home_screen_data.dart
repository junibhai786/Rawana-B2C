import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/boat_list_model.dart';
import 'package:moonbnd/modals/car_list_model.dart';
import 'package:moonbnd/modals/event_list_model.dart';
import 'package:moonbnd/modals/flight_list_model.dart';
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:moonbnd/modals/space_list_model.dart';
import 'package:moonbnd/modals/tour_list_model.dart';

//data model for CategorySelector

class CategoryData {
  final String category;
  final String kIcon;
  final int id;

  CategoryData({required this.kIcon, required this.category, required this.id});
}

List<CategoryData> categoryDatas = [
  CategoryData(
    kIcon: 'assets/icons/home.svg',
    category: "Home".tr,
    id: 0,
  ),
  if (enableHotel)
    CategoryData(
      kIcon: 'assets/icons/hotel.svg',
      category: "Hotels".tr,
      id: 1,
    ),
  if (enableFlight)
    CategoryData(
      kIcon: 'assets/icons/flights.svg',
      category: "Flight".tr,
      id: 6,
    ),
  if (enableEvent)
    CategoryData(
      kIcon: 'assets/icons/event.svg',
      category: "Event".tr,
      id: 5,
    ),
  if (enableTour)
    CategoryData(
      kIcon: 'assets/icons/homestay.svg',
      category: "Tours".tr,
      id: 2,
    ),
  if (enableSpace)
    CategoryData(
      kIcon: 'assets/icons/demand.svg',
      category: "Space".tr,
      id: 3,
    ),
  if (enableCar)
    CategoryData(
      kIcon: 'assets/icons/carnew.svg',
      category: "Car".tr,
      id: 4,
    ),
  if (enableBoat)
    CategoryData(
      kIcon: 'assets/icons/boat.svg',
      category: "Boat".tr,
      id: 7,
    ),
];

//property data model

class PropertyData {
  final String propertyName, slug, date, address, reviewtext, reviewscore;
  final int rating, id;
  final int reviewcount;
  bool isWishlist;

  final String price;
  final List<String> images;

  String tag;

  PropertyData({
    required this.propertyName,
    required this.images,
    required this.slug,
    required this.id,
    required this.isWishlist,
    required this.rating,
    required this.tag,
    required this.date,
    required this.price,
    required this.address,
    required this.reviewcount,
    required this.reviewtext,
    required this.reviewscore,
  });

  factory PropertyData.fromHotel(Hotel hotel) {
    final reviewScoreMap =
        hotel.reviewScore is Map ? hotel.reviewScore as Map : null;

    return PropertyData(
      propertyName: hotel.title ?? '',
      images: hotel.gallery ?? [],
      id: hotel.id ?? 0,
      isWishlist: hotel.isInWishlist ?? false,
      slug: hotel.slug ?? '',
      rating: hotel.starRate ?? 0,
      tag: hotel.checkOutTime ?? '',
      date: hotel.checkInTime ?? '',
      price: hotel.price ?? '',
      address: hotel.address ?? '',

      // ✅ FIXED REVIEW FIELDS
      reviewscore: reviewScoreMap?['score_total']?.toString() ?? '0',
      reviewcount: reviewScoreMap?['total_review'] ?? 0,
      reviewtext: reviewScoreMap?['review_text'] ?? '',
    );
  }
}

class CarData {
  final String? title;
  final int? id;
  bool isWishlist;
  final String? status;
  final String? updatedat;

  final List<String>? images;
  final String? slug;
  final String? reviewText;
  final int? price;
  final String? address;
  final String? availability_url;
  final int? baggage;
  final int? saleprice;

  final int? door, isfeatured;
  final int? passenger;
  final int? reviewcount;
  final String? gear;
  final dynamic reviewScore;
  final String? detailsurl;

  CarData({
    required this.title,
    required this.id,
    required this.images,
    required this.updatedat,
    required this.slug,
    required this.availability_url,
    required this.reviewText,
    required this.reviewScore,
    required this.reviewcount,
    required this.isWishlist,
    required this.price,
    required this.saleprice,
    required this.status,
    required this.address,
    required this.baggage,
    required this.door,
    required this.gear,
    required this.passenger,
    required this.isfeatured,
    required this.detailsurl,
  });

  factory CarData.fromCar(Car carlist) {
    return CarData(
        title: carlist.title,
        images: carlist.gallery,
        reviewcount: carlist.reviewCount,
        updatedat: carlist.updatedAt,
        availability_url: carlist.availability_url,
        reviewText: carlist.reviewText,
        reviewScore: carlist.reviewScore,
        id: carlist.id,
        isWishlist: carlist.isInWishlist ?? false,
        slug: carlist.slug ?? "",
        saleprice: carlist.salePrice,
        status: carlist.status,
        price: carlist.price,
        address: carlist.address,
        baggage: carlist.baggage,
        door: carlist.door,
        passenger: carlist.passenger,
        gear: carlist.gear,
        isfeatured: carlist.isFeatured,
        detailsurl: carlist.detailsurl);
  }
}

class EvenData {
  final String propertyName, slug, time, address, reviewtext;
  final dynamic rating;
  final int reviewcount;
  final dynamic reviewscore;
  final int price, discount, isfeatured;
  String? duration;
  final List<String> images;
  final int? id;
  bool isWishlist;

  EvenData({
    required this.propertyName,
    required this.images,
    required this.slug,
    required this.rating,
    required this.id,
    required this.isWishlist,
    required this.time,
    required this.price,
    required this.address,
    required this.reviewcount,
    required this.reviewtext,
    required this.reviewscore,
    required this.duration,
    required this.discount,
    required this.isfeatured,
  });

  factory EvenData.fromEvent(Event event) {
    final reviewScoreMap =
        event.reviewScore is Map ? event.reviewScore as Map : null;

    return EvenData(
      propertyName: event.title ?? '',
      id: event.id ?? 0,
      isWishlist: event.isInWishlist ?? false,
      images: event.gallery ?? [],
      slug: event.slug ?? '',
      rating: reviewScoreMap?['score_total'] ?? 0, // dynamic is ok
      time: event.startTime ?? '',
      price: event.price ?? 0,
      address: event.address ?? '',
      reviewcount: reviewScoreMap?['total_review'] ?? 0,
      reviewtext: reviewScoreMap?['review_text']?.toString() ?? '',
      reviewscore: reviewScoreMap?['score_total']?.toString() ?? '0',
      duration: event.duration ?? '',
      discount: event.discount ?? 0,
      isfeatured: event.isFeatured ?? 0,
    );
  }
}

class TourData {
  final String propertyName, slug, date, address, reviewtext, reviewscore;
  // final String rating;
  final String reviewcount;
  final String price, salePrice;
  final int? id;
  bool isWishlist;
  final int isfeatured, discount;
  final List<String> images;

  TourData({
    required this.propertyName,
    required this.images,
    required this.id,
    required this.isWishlist,
    required this.slug,
    // required this.rating,
    required this.date,
    required this.price,
    required this.salePrice,
    required this.address,
    required this.reviewcount,
    required this.reviewtext,
    required this.reviewscore,
    required this.isfeatured,
    required this.discount,
  });

  factory TourData.fromTour(Tour tour) {
    final reviewScoreMap =
        tour.reviewScore is Map ? tour.reviewScore as Map : null;

    return TourData(
      propertyName: tour.title ?? '',
      images: tour.gallery ?? [],
      slug: tour.slug ?? '',
      id: tour.id ?? 0,
      isWishlist: tour.isInWishlist ?? false,
      date: tour.startDate ?? '',
      price: tour.price ?? '',
      salePrice: tour.salePrice ?? '',
      address: tour.address ?? '',

      // ✅ FIX REVIEW FIELDS
      reviewcount: reviewScoreMap?['total_review']?.toString() ?? '0',
      reviewtext: reviewScoreMap?['review_text']?.toString() ?? '',
      reviewscore: reviewScoreMap?['score_total']?.toString() ?? '0',

      isfeatured: tour.isFeatured ?? 0,
      discount: tour.discount ?? 0,
    );
  }
}

class SpaceData {
  final String propertyName, date, address, reviewtext, reviewscore;
  final String rating;
  final String reviewcount;
  final String price, salePrice;
  final int? id;
  bool isWishlist;
  final List<String> images;
  final int passenger, bed, bathroom, squarefeet, isfeatured, discount;

  SpaceData({
    required this.propertyName,
    required this.images,
    required this.id,
    required this.isWishlist,
    required this.rating,
    required this.date,
    required this.price,
    required this.salePrice,
    required this.address,
    required this.reviewcount,
    required this.reviewtext,
    required this.reviewscore,
    required this.passenger,
    required this.bed,
    required this.bathroom,
    required this.squarefeet,
    required this.isfeatured,
    required this.discount,
  });

  factory SpaceData.fromSpace(Space space) {
    return SpaceData(
      propertyName: space.title ?? '',
      images: space.gallery ?? [],
      rating: space.reviewScore.toString(),
      date: space.salePrice ?? '',
      price: space.price ?? '',
      id: space.id ?? 0,
      isWishlist: space.isInWishlist ?? false,
      salePrice: space.salePrice ?? '',
      address: space.address ?? '',
      reviewcount: space.reviewScore.toString(),
      reviewtext: space.reviewText ?? '',
      reviewscore: space.reviewScore.toString(),
      passenger: space.maxGuests ?? 0,
      bed: space.bed ?? 0,
      bathroom: space.bathroom ?? 0,
      squarefeet: space.square ?? 0,
      isfeatured: space.isFeatured ?? 0,
      discount: space.discount ?? 0,
    );
  }
}

class BoatData {
  final String propertyName, slug, time, address, reviewtext;
  final dynamic rating;
  final dynamic reviewscore;
  final int reviewcount;
  final String price;
  final List<String> images;
  final dynamic maxpassenger;
  final int? id;
  final int? cabin;
  bool isWishlist;

  BoatData({
    required this.propertyName,
    required this.images,
    required this.slug,
    required this.reviewscore,
    required this.rating,
    required this.id,
    required this.isWishlist,
    required this.time,
    required this.price,
    required this.address,
    required this.reviewcount,
    required this.reviewtext,
    required this.maxpassenger,
    required this.cabin,
  });

  factory BoatData.fromBoat(Boat boat) {
    return BoatData(
      propertyName: boat.title ?? '',
      images: boat.gallery ?? [],
      slug: boat.slug ?? '',
      id: boat.id ?? 0,
      isWishlist: boat.isInWishlist ?? false,
      rating: boat.reviewScore,
      time: boat.content ?? '',
      price: boat.minPrice ?? '',
      address: boat.address ?? '',
      reviewcount: boat.reviewCount ?? 0,
      reviewtext: boat.reviewText ?? '',
      reviewscore: boat.reviewScore ?? '',
      maxpassenger: boat.maxGuest ?? 0,
      cabin: boat.cabin ?? 0,
    );
  }
}

class FlightData {
  final String propertyName, slug, date, address, arrival, departure;
  final String rating;
  final String reviewcount;
  final String price;
  final String images;
  final String? id;

  FlightData({
    required this.propertyName,
    required this.images,
    required this.slug,
    required this.rating,
    required this.id,
    required this.date,
    required this.price,
    required this.address,
    required this.reviewcount,
    required this.arrival,
    required this.departure,
  });

  factory FlightData.fromFlight(Flight flight) {
    // Get first flight detail for basic info
    final firstDetail = flight.flightDetails?.isNotEmpty == true
        ? flight.flightDetails!.first
        : null;

    return FlightData(
      propertyName:
          '${firstDetail?.depIata ?? ''} to ${firstDetail?.arrIata ?? ''}',
      images: firstDetail?.airlineLogo ?? '',
      slug: flight.id ?? '',
      id: flight.id,
      rating: '0',
      date: firstDetail?.depDate ?? '',
      price: flight.totalPrice ?? '0',
      address:
          '${firstDetail?.airlineCode ?? ''} ${firstDetail?.flightNumber ?? ''}',
      reviewcount: '0',
      arrival: firstDetail?.arrTime ?? '',
      departure: firstDetail?.depTime ?? '',
    );
  }
}
