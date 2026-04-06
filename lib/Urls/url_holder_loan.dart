class ApiUrls {
  //// production
  ///
  ///habib bhai
  static const baseUrl = "https://travolyo.com/api/";
  // "https://hebdomadally-bidirectional-marylyn.ngrok-free.dev/api/";
  // " https://hebdomadally-bidirectional-marylyn.ngrok-free.dev";
  //"https://travolyo.com/api/"; //"https://dentirostral-pseudoindependently-michell.ngrok-free.dev/api/";    // "https://travolyo.com/api/";
  static const webUrl = "https://travolyo.com/admin/";

  static const login = "auth/login";
  static const signup = "auth/register";
  static const verifyOtp = "auth/verify_otp";
  static const getMe = "auth/me";
  static const vendordeletecar = 'vendor/DeleteCars';
  static const vendorallcar = 'vendor/getAllCars';
  static const vendorallhotel = "vendor/hotel/all";
  static const vendorallflight = "vendor/flight/all";
  static const vendorhoteldetails = "vendor/hotel/details";
  static const vendorflightdetails = "vendor/flight/details";
  static const vendordeletehotel = "vendor/hotel/delete";
  static const vendorpublishhotel = "vendor/hotel/publish";
  static const vendorpublishflight = "vendor/flight/publish";
  static const vendorhidehotel = "vendor/hotel/hide";
  static const vendorhideflight = "vendor/flight/hide";
  static const becomesvendor = 'become-vendor';
  static const vendorcarhotel = "vendor/car/hide";
  static const getnotificationunreadcount = 'notification/unread-count';
  static const vendorhotelpropertytype = "hotel/property-type";
  static const vendorflighttype = "vendor/flight/categories";
  static const vendorflightairline = "vendor/flight/airline";
  static const vendorflightairport = "vendor/flight/airport";
  static const vendorflightservice = "vendor/flight/inflightExperience";
  static const vendorhotelfacilitytype = "hotel/facilities";
  static const vendorhotelservicetpe = "hotel/service-type";

  // new api
  static const getCountries = "locations/countries";
  static String hotelCitiesByCountry(String countryCode) =>
      'locations/cities/$countryCode';
  static const flightAirports = "locations/airports";
  static const hotelLocationSearch = 'locations/search';

  static const updateProfile = "profile-update";
  static const deleteAccount = "delete-my-account";
  static const updateProfilePicture = "upload-profile-img";
  static const resendOtp = "auth/resend_otp";
  static const homeListEnd = "home-page";
  static const hotelListEnd = "home/hotel";
  static const carListEndPoint = "home/car";
  static const eventListEndPoint = "home/event";
  static const tourListEndPoint = "home/tour";
  static const spaceListEndPoint = "home/space";
  static const boatListEndPoint = "home/boat";
  static const flightListEndPoint = "home/flight";
  static const getaddcarlocation = 'vendor/locationList';
  static const vendorpublishcar = "vendor/car/publish";

  /// details
  static const hotelDetailsEndPoint = "hotels/detail";

  /// Build hotel detail URL with provider query param
  static String hotelDetailUrl(String hotelId,
      {String? provider, String? currency}) {
    final params = <String, String>{};
    if (provider != null && provider.isNotEmpty) {
      params['provider'] = provider;
    }
    if (currency != null && currency.isNotEmpty) {
      params['currency'] = currency;
    }
    final base = '${baseUrl}hotels/detail/$hotelId';
    if (params.isEmpty) return base;
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$base?$query';
  }

  static const carDetailsEndPoint = "car/detail";
  static const vendorcarDetailsEndPoint = "vendor/car/details";

  static const boatDetailsEndPoint = "boat/detail";
  static const eventDetailsEndPoint = "event/detail";
  ////
  static const tourDetailsEndPoint = "tour/detail";
  static const spaceDetailsEndPoint = "space/detail";
  static const changePassword = 'auth/change-password';
  static const resetPassword = 'auth/reset-password';

  static const updateVerificationDataEndpoint = 'verification';
  static const wishlist = 'wishlist';
  static const verificationImage = 'verification-upload';
  static const verificationEndpoint = 'verification';
  static const hotelAvailabilityEndPoint = 'HotelAvailability';
  static const sendEnquiry = 'enquiry/send';
  static const leaveReview = 'review/add';
  static const clonehotelvendor = "vendor/hotel/clone";
  static const deletehotelimagevendor = "image/delete";
  static const cloneflightvendor = "vendor/flight/clone";
  static const addToCart = 'add-to-cart';
  static const vendordeleteflight = 'vendor/flight/delete';
  static const hotelbookingdetails = 'checkout/detail';
  static const countryList = 'countries';
  static const hotelcheckout = 'checkout/me';
  static const bookinghistoryendpoint = 'me/booking-history';
  static const hotelSearch = 'hotels/search';
  static const hotelCheckoutEndpoint = 'hotels/checkout';
  static const hotelBookingConfirmation = 'hotels/booking/confirmation';
  static const hotelOrderDetails = 'hotels/order/';
  static const hotellocations = 'locations';
  static const carSearch = 'car/search';
  static const boatSearch = 'boat/search';
  static const tourSearch = 'tour/search';
  static const eventSearch = 'event/search';
  static const spaceSearch = 'space/search';
  static const flightSearch = 'flights/search';
  static const activitiesSearch = 'activities/search';
  static const downloadInvoice = 'dowanload/invoice';
  static const flightDetailsEndPoint = 'flight/details';
  static const flightBookingDetails = 'checkout/detail';
  static const flightPreBook = 'flights/prebook';
  static const hotelPreBook = 'hotels/prebook';
  static const activitiesPrebook = 'activities/prebook';
  static const activitiesCheckout = 'activities/checkout';
  static const activitiesOrderDetails = 'activities/order/';
  static const getvednorcartypes = 'vendor/car-type';
  static const getnotification = 'notification';
  static const getvednoraddcarfeatures = 'vendor/car-features';
  static const vendorsignup = "vendor/register";
  static const vendoraddcars = 'vendor/AddCars';
  static const vendorupdatecars = 'vendor/UpdateCars';

  static const vendoraddhotels = "vendor/hotel/add";
  static const vendoraddflight = "vendor/flight/add";
  static const vendorupdateflight = "vendor/flight/update";
  static const vendorupdatehotels = "vendor/hotel/update";
  static const vendoralltour = "vendor/tour/all";
  static const vendordetailsbuy = 'vendor/credit/all';
  static const creaditalltransaction = 'vendor/trans/all';
  static const creditbalance = 'vendor/trans/balance';
  static const pendingcredit = 'vendor/trans/pending';

  ///// vendor
  static const spaceVendorForAll = 'vendor/space/all';
  static const spaceVendorDelete = 'vendor/space/delete';
  static const spaceVendorClone = 'vendor/space/clone';

  static const vendordeletetour = "vendor/tour/delete";
  static const clonetourvendor = "vendor/tour/clone";
  static const vendorhidetour = "vendor/tour/hide";
  static const vendorpublishtour = "vendor/tour/publish";
  static const vendortraveltype = "vendor/tour/style";
  static const vendortourfacilitytype = "vendor/tour/facilities";
  static const vendortourcategorytype = "vendor/tour/categories";

  static const getaddtourlocation = 'vendor/locationList';
  static const vendoraddtour = 'vendor/tour/add';
  static const clonecarvendor = "vendor/car/clone";
  static const getnotificationread = 'notification/read';
  static const getnotificationunread = 'notification/unread';
  static const vendorSpaceHide = "vendor/space/hide";
  static const postvendorcreditall = 'vendor/credit/buy';
  static const vendorSpacePublish = "vendor/space/publish";
  static const readednotification = 'notification/read/';
  static const vendorSpaceAdd = "vendor/space/add";
  static const vendorSpaceEdit = "vendor/space/update";
  static const vendorSpaceAmenities = "vendor/space/amenities";
  static const vendorSpaceType = "vendor/space/categories";
  static const vendorSpaceDetailForEdit = "vendor/space/details";
  static const vendorSpaceDetailForDelete = "image/delete";
  static const vendoralltourdetails = "vendor/tour/details";
  static const vendoralltourupdate = "vendor/tour/update";

  static const String uploadImage = 'image/upload';
  static const vendorboattype = "vendor/boat/boattype";
  static const vendorboatamenities = "vendor/boat/amenities";
  static const vendorallboat = "vendor/boat/all";
  static const vendordeleteboat = "vendor/boat/delete";
  static const cloneboatvendor = "vendor/boat/clone";
  static const vendorboathide = "vendor/boat/hide";
  static const vendorboatpublish = "vendor/boat/publish";
  ///// event vendor

  static const vendorEventAdd = "vendor/event/add";
  static const eventVendorForAll = "vendor/event/all";
  static const eventVendorDelete = 'vendor/event/delete';
  static const vendorEventHide = "vendor/event/hide";
  static const vendorEventPublish = "vendor/event/publish";
  static const eventVendorClone = 'vendor/event/clone';
  static const eventVendorCatagories = "vendor/event/categories";
  static const vendorEventDetail = "vendor/event/details";
  static const vendorEventDetailForEdit = "vendor/event/update";
  static const String vendorboatadd = 'vendor/boat/add';
  static const String vendorallboatdetails = 'vendor/boat/details';
  static const String vendorBoatDetailForDelete = 'image/delete';
  static const String vendorboatedit = 'vendor/boat/update';
  static const String applyCoupon = 'coupon/apply';
  static const String removeCoupon = 'coupon/remove';
  static const String usercreditbalance = 'trans/balance';
  static const String getManageCoupon = 'vendor/coupon';
  static const String deleteManageCoupon = 'vendor/coupon/delete';
  static const String vendorService = 'vendor/coupon/services';
  static const String addVendorService = 'vendor/coupon/add';
  static const String editVendorService = 'vendor/coupon/update';
  static const airportSearchEndpoint = 'v1/airports/search';
}
