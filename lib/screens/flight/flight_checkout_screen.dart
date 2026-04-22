import 'dart:convert';
import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:moonbnd/widgets/country_code.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/screens/hotel/stripe_checkout_webview_screen.dart';
import 'package:moonbnd/screens/flight/payment_complete_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/services/session_manager.dart';

enum StepStatus { completed, active, future }

class FlightCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> flightData;

  const FlightCheckoutScreen({
    Key? key,
    required this.flightData,
  }) : super(key: key);

  @override
  State<FlightCheckoutScreen> createState() => _FlightCheckoutScreenState();
}

/// Model for passenger form data
class PassengerFormData {
  final String passengerNumber;
  final String passengerType; // Adult, Child, Infant
  String title = 'Mr';
  String firstName = '';
  String lastName = '';
  String dateOfBirth = '';
  String nationality = '';
  String gender = 'Male';
  String passportNumber = '';
  String passportExpiry = '';

  PassengerFormData({
    required this.passengerNumber,
    required this.passengerType,
  });
}

class _FlightCheckoutScreenState extends State<FlightCheckoutScreen> {
  // Form controls
  bool _agreedToTerms = false;
  String _selectedPaymentMethod = 'card'; // card or alternative
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late Country selectedCountry;

  // Passenger forms tracking
  late List<PassengerFormData> _passengerForms;
  final Map<String, List<TextEditingController>> _passengerFormControllers = {};

  // Processing guard — prevents duplicate taps
  bool _isProcessing = false;

  // Form validation
  final _formKey = GlobalKey<FormState>();
  String? _termsError;

  // Inline field errors from server 422 response
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    log('[FlightCheckout] ========== CHECKOUT SCREEN INIT ==========');
    log('[FlightCheckout] flightData keys  : ${widget.flightData.keys.toList()}');
    log('[FlightCheckout] token value       : ${widget.flightData['token']}');
    log('[FlightCheckout] checkout_url value: ${widget.flightData['checkout_url']}');
    log('[FlightCheckout] resolved token    : ${_extractToken()}');
    _initializePassengerForms();
    // Initialize with default country (US)
    selectedCountry = _getDefaultCountry();
  }

  Country _getDefaultCountry() {
    return Country.parse('AE');
  }

  /// Get max phone number length based on country code
  int _getPhoneMaxLength() {
    final phoneCode = selectedCountry.phoneCode;
    // Phone number length limits by country code
    final phoneLengthMap = {
      // Americas
      '1': 10, // US, Canada - 10 digits
      // Europe
      '44': 11, // UK - 10 digits + formatting
      '33': 9, // France - 9 digits
      '49': 11, // Germany - 10 digits
      '39': 10, // Italy - 10 digits
      '34': 9, // Spain - 9 digits
      // Asia
      '91': 10, // India - 10 digits
      '92': 10, // Pakistan - 10 digits
      '880': 10, // Bangladesh - 10 digits
      '81': 11, // Japan - 10 digits
      '82': 10, // South Korea - 9-10 digits
      '86': 11, // China - 11 digits
      '60': 10, // Malaysia - 9-10 digits
      '62': 12, // Indonesia - 9-12 digits
      '63': 10, // Philippines - 10 digits
      '66': 9, // Thailand - 9 digits
      '84': 10, // Vietnam - 9-10 digits
      '65': 8, // Singapore - 8 digits
      '852': 8, // Hong Kong - 8 digits
      // Middle East
      '971': 9, // UAE - 9 digits
      '966': 9, // Saudi Arabia - 9 digits
      '974': 8, // Qatar - 8 digits
      '20': 10, // Egypt - 10 digits
      // Africa
      '27': 9, // South Africa - 9 digits
      '234': 10, // Nigeria - 10 digits
    };
    // Use specific limit if available, otherwise use 15 as default
    return (phoneLengthMap[phoneCode] ?? 15);
  }

  /// Initialize passenger form data based on adult/children/infants count
  void _initializePassengerForms() {
    _passengerForms = [];
    int passengerNumber = 1;

    int adults = _parsePassengerCount(widget.flightData['adults']);
    int children = _parsePassengerCount(widget.flightData['children']);
    int infants = _parsePassengerCount(widget.flightData['infants']);

    log('[FlightCheckout] Initializing passenger forms - Adults: $adults, Children: $children, Infants: $infants');

    // Adults
    for (int i = 0; i < adults; i++) {
      _passengerForms.add(PassengerFormData(
        passengerNumber: passengerNumber.toString(),
        passengerType: 'Adult',
      ));
      _initControllers(passengerNumber.toString());
      passengerNumber++;
    }

    // Children
    for (int i = 0; i < children; i++) {
      _passengerForms.add(PassengerFormData(
        passengerNumber: passengerNumber.toString(),
        passengerType: 'Child',
      ));
      _initControllers(passengerNumber.toString());
      passengerNumber++;
    }

    // Infants
    for (int i = 0; i < infants; i++) {
      _passengerForms.add(PassengerFormData(
        passengerNumber: passengerNumber.toString(),
        passengerType: 'Infant',
      ));
      _initControllers(passengerNumber.toString());
      passengerNumber++;
    }

    log('[FlightCheckout] Total passenger forms generated: ${_passengerForms.length}');
  }

  void _initControllers(String id) {
    _passengerFormControllers[id] = [
      TextEditingController(), // First Name
      TextEditingController(), // Last Name
      TextEditingController(), // Passport Number
    ];
  }

  /// Parse passenger count from various data types (int, String, or null)
  int _parsePassengerCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passengerFormControllers.values.forEach((controllers) {
      controllers.forEach((c) => c.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Complete Your Booking'.tr,
          style: GoogleFonts.spaceGrotesk(
            color: kPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProgressSteps(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFlightSummarySection(),
                    const SizedBox(height: 20),
                    _buildPassengerDetailsSection(),
                    const SizedBox(height: 20),
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 20),
                    _buildPriceSummarySection(),
                    const SizedBox(height: 24),
                    _buildTermsAndCheckout(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kSecondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressStep(1, 'Search'.tr, StepStatus.completed),
          _buildProgressConnector(true),
          _buildProgressStep(2, 'Select Flight'.tr, StepStatus.completed),
          _buildProgressConnector(true),
          _buildProgressStep(3, 'Passenger'.tr, StepStatus.active),
          _buildProgressConnector(false),
          _buildProgressStep(4, 'Payment'.tr, StepStatus.future),
          _buildProgressConnector(false),
          _buildProgressStep(5, 'Confirm'.tr, StepStatus.future),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int number, String label, StepStatus status) {
    bool isActive = status == StepStatus.active;
    bool isCompleted = status == StepStatus.completed;

    IconData getIcon(int n) {
      switch (n) {
        case 1:
          return Icons.search;
        case 2:
          return Icons.airplanemode_active_rounded;
        case 3:
          return Icons.person_add_rounded;
        case 4:
          return Icons.credit_card_rounded;
        case 5:
          return Icons.check_circle_outline_rounded;
        default:
          return Icons.info;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : (isCompleted
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.15)),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Icon(
                    getIcon(number),
                    size: 16,
                    color: isActive
                        ? kPrimaryColor
                        : Colors.white.withOpacity(0.6),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.split(' ').join('\n'),
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            height: 1.1,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector(bool isDone) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 26),
        color: Colors.white.withOpacity(isDone ? 0.6 : 0.2),
      ),
    );
  }

  Widget _buildFlightSummarySection() {
    final data = widget.flightData;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kPrimaryTintColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded,
                      color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['dep_iata']} → ${data['arr_iata']}',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kPrimaryColor,
                        ),
                      ),
                      Text(
                        '${data['airline_name']} | ${data['flight_number']}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: kSubtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(Icons.calendar_today_outlined, 'Departure'.tr,
                    '${data['dep_date']} | ${data['dep_time']}'),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow(Icons.calendar_today_outlined, 'Arrival'.tr,
                    '${data['arr_date']} | ${data['arr_time']}'),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow(Icons.timer_outlined, 'Duration'.tr,
                    '${data['duration']} | ${data['stops']} stops'),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow(
                    Icons.airline_seat_recline_extra_outlined,
                    'Seats / Cabin'.tr,
                    '${_totalPax()} Pax | ${data['cabin_class']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _totalPax() {
    return _parsePassengerCount(widget.flightData['adults']) +
        _parsePassengerCount(widget.flightData['children']) +
        _parsePassengerCount(widget.flightData['infants']);
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kSubtitleColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: kSubtitleColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInformationSection() {
    return const SizedBox.shrink();
  }

  Widget _buildPassengerDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _passengerForms.length,
          itemBuilder: (context, index) {
            final form = _passengerForms[index];
            return _buildPassengerForm(form, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildPassengerForm(PassengerFormData form, int displayNum) {
    final controllers = _passengerFormControllers[form.passengerNumber]!;
    final isFirstPassenger = displayNum == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header matching image style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: kPrimaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFirstPassenger
                          ? 'Guest Details'.tr
                          : 'PASSENGER $displayNum — ${form.passengerType.toUpperCase()}'
                              .tr,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                    ),
                    Text(
                      isFirstPassenger
                          ? 'Primary guest information for this booking'.tr
                          : '${form.passengerType} passenger'.tr,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12, color: kSubtitleColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Title *'.tr),
                _buildDropdown(['Mr', 'Ms', 'Mrs'],
                    (v) => setState(() => form.title = v!)),
                const SizedBox(height: 16),
                _buildLabel('First Name *'.tr),
                _buildTextField(controllers[0], 'First name'.tr, maxLength: 20,
                    validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'First name is required'.tr;
                  if (v.trim().length < 2) return 'At least 2 characters'.tr;
                  return null;
                }),
                const SizedBox(height: 16),
                _buildLabel('Last Name *'.tr),
                _buildTextField(controllers[1], 'Last name'.tr, maxLength: 20,
                    validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Last name is required'.tr;
                  if (v.trim().length < 2) return 'At least 2 characters'.tr;
                  return null;
                }),
                if (isFirstPassenger) ...[
                  const SizedBox(height: 16),
                  _buildLabel('Email Address *'.tr),
                  _buildTextField(
                      _emailController, 'Enter Your Email Address'.tr,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 30, validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required'.tr;
                    if (!_isValidEmail(v.trim()))
                      return 'Enter a valid email address'.tr;
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number *'.tr),
                  _buildPhoneField(),
                  const SizedBox(height: 4),
                  if (_phoneError != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 2, bottom: 2, left: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _phoneError!,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text('Include country code'.tr,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 11, color: kPrimaryColor)),
                ],
                const SizedBox(height: 16),
                _buildLabel('Date of Birth *'.tr),
                _buildDateField(
                    form, (v) => setState(() => form.dateOfBirth = v)),
                const SizedBox(height: 16),
                _buildLabel('Gender *'.tr),
                _buildDropdown(['Male', 'Female'],
                    (v) => setState(() => form.gender = v!)),
                const SizedBox(height: 16),
                _buildLabel('Nationality *'.tr),
                _buildNationalityDropdown(
                    form, (v) => setState(() => form.nationality = v)),
                const SizedBox(height: 16),
                _buildLabel('Passport Number *'.tr),
                _buildTextField(controllers[2], 'e.g. AA1234567',
                    validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Passport number is required'.tr;
                  return null;
                }),
                const SizedBox(height: 16),
                _buildLabel('Passport Expiry Date *'.tr),
                _buildPassportExpiryField(
                    form, (v) => setState(() => form.passportExpiry = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.credit_card_outlined,
                      color: kPrimaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method'.tr,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                      Text(
                        'All transactions are secured and encrypted'.tr,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, color: kSubtitleColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPaymentOption(
                    'card',
                    'Credit / Debit Card',
                    'Visa, Mastercard, Amex — powered by Stripe',
                    Icons.credit_card_rounded,
                    null),
                const SizedBox(height: 12),
                _buildPaymentOption(
                    'ngenius',
                    'N-Genius',
                    'Secure hosted checkout by Network International',
                    null,
                    'N-G'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle,
      IconData? icon, String? badge) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryColor : kBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? kPrimaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryColor : kSubtitleColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: kPrimaryColor, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon / badge
            Container(
              width: 38,
              height: 28,
              decoration: BoxDecoration(
                color: kSheetHeadingColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 16)
                    : Text(
                        badge ?? '',
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                  ),
                  Text(
                    subtitle.tr,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: kSubtitleColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummarySection() {
    final data = widget.flightData;
    double price = 0.0;
    if (data['price'] != null) {
      if (data['price'] is int) {
        price = (data['price'] as int).toDouble();
      } else if (data['price'] is double) {
        price = data['price'];
      } else if (data['price'] is String) {
        price = double.tryParse(data['price']) ?? 0.0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 18, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text('Price Summary'.tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Base fare × ${_totalPax()}',
              '${data['currency']} ${price.toStringAsFixed(2)}'),
          _buildPriceRow('Taxes & fees', 'Included'.tr),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total'.tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                '${data['currency']} ${price.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.tr,
              style: GoogleFonts.spaceGrotesk(
                  color: kSubtitleColor, fontSize: 14)),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTermsAndCheckout() {
    final data = widget.flightData;
    double price = 0.0;
    if (data['price'] != null) {
      if (data['price'] is int) {
        price = (data['price'] as int).toDouble();
      } else if (data['price'] is double) {
        price = data['price'];
      } else if (data['price'] is String) {
        price = double.tryParse(data['price']) ?? 0.0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (v) => setState(() {
                _agreedToTerms = v!;
                if (_agreedToTerms) _termsError = null;
              }),
              activeColor: kPrimaryColor,
            ),
            Expanded(
              child: Text(
                'I have read and agree to the Terms & Conditions and Privacy Policy.'
                    .tr,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12, color: kSubtitleColor),
              ),
            ),
          ],
        ),
        if (_termsError != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              _termsError!,
              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _handleConfirmPay(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Confirm & Pay ${data['currency']} ${price.toStringAsFixed(2)}'
                      .tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Country name → ISO-3166 alpha-2 code map (top used + full list) ──
  static const Map<String, String> _countryCode = {
    'Afghanistan': 'AF',
    'Albania': 'AL',
    'Algeria': 'DZ',
    'Andorra': 'AD',
    'Angola': 'AO',
    'Antigua and Barbuda': 'AG',
    'Argentina': 'AR',
    'Armenia': 'AM',
    'Australia': 'AU',
    'Austria': 'AT',
    'Azerbaijan': 'AZ',
    'Bahamas': 'BS',
    'Bahrain': 'BH',
    'Bangladesh': 'BD',
    'Barbados': 'BB',
    'Belarus': 'BY',
    'Belgium': 'BE',
    'Belize': 'BZ',
    'Benin': 'BJ',
    'Bhutan': 'BT',
    'Bolivia': 'BO',
    'Bosnia and Herzegovina': 'BA',
    'Botswana': 'BW',
    'Brazil': 'BR',
    'Brunei': 'BN',
    'Bulgaria': 'BG',
    'Burkina Faso': 'BF',
    'Burundi': 'BI',
    'Cabo Verde': 'CV',
    'Cambodia': 'KH',
    'Cameroon': 'CM',
    'Canada': 'CA',
    'Central African Republic': 'CF',
    'Chad': 'TD',
    'Chile': 'CL',
    'China': 'CN',
    'Colombia': 'CO',
    'Comoros': 'KM',
    'Congo': 'CG',
    'Costa Rica': 'CR',
    'Croatia': 'HR',
    'Cuba': 'CU',
    'Cyprus': 'CY',
    'Czech Republic': 'CZ',
    'Denmark': 'DK',
    'Djibouti': 'DJ',
    'Dominica': 'DM',
    'Dominican Republic': 'DO',
    'Ecuador': 'EC',
    'Egypt': 'EG',
    'El Salvador': 'SV',
    'Equatorial Guinea': 'GQ',
    'Eritrea': 'ER',
    'Estonia': 'EE',
    'Eswatini': 'SZ',
    'Ethiopia': 'ET',
    'Fiji': 'FJ',
    'Finland': 'FI',
    'France': 'FR',
    'Gabon': 'GA',
    'Gambia': 'GM',
    'Georgia': 'GE',
    'Germany': 'DE',
    'Ghana': 'GH',
    'Greece': 'GR',
    'Grenada': 'GD',
    'Guatemala': 'GT',
    'Guinea': 'GN',
    'Guinea-Bissau': 'GW',
    'Guyana': 'GY',
    'Haiti': 'HT',
    'Honduras': 'HN',
    'Hungary': 'HU',
    'Iceland': 'IS',
    'India': 'IN',
    'Indonesia': 'ID',
    'Iran': 'IR',
    'Iraq': 'IQ',
    'Ireland': 'IE',
    'Israel': 'IL',
    'Italy': 'IT',
    'Jamaica': 'JM',
    'Japan': 'JP',
    'Jordan': 'JO',
    'Kazakhstan': 'KZ',
    'Kenya': 'KE',
    'Kiribati': 'KI',
    'Kuwait': 'KW',
    'Kyrgyzstan': 'KG',
    'Laos': 'LA',
    'Latvia': 'LV',
    'Lebanon': 'LB',
    'Lesotho': 'LS',
    'Liberia': 'LR',
    'Libya': 'LY',
    'Liechtenstein': 'LI',
    'Lithuania': 'LT',
    'Luxembourg': 'LU',
    'Madagascar': 'MG',
    'Malawi': 'MW',
    'Malaysia': 'MY',
    'Maldives': 'MV',
    'Mali': 'ML',
    'Malta': 'MT',
    'Marshall Islands': 'MH',
    'Mauritania': 'MR',
    'Mauritius': 'MU',
    'Mexico': 'MX',
    'Micronesia': 'FM',
    'Moldova': 'MD',
    'Monaco': 'MC',
    'Mongolia': 'MN',
    'Montenegro': 'ME',
    'Morocco': 'MA',
    'Mozambique': 'MZ',
    'Myanmar': 'MM',
    'Namibia': 'NA',
    'Nauru': 'NR',
    'Nepal': 'NP',
    'Netherlands': 'NL',
    'New Zealand': 'NZ',
    'Nicaragua': 'NI',
    'Niger': 'NE',
    'Nigeria': 'NG',
    'North Korea': 'KP',
    'North Macedonia': 'MK',
    'Norway': 'NO',
    'Oman': 'OM',
    'Pakistan': 'PK',
    'Palau': 'PW',
    'Palestine': 'PS',
    'Panama': 'PA',
    'Papua New Guinea': 'PG',
    'Paraguay': 'PY',
    'Peru': 'PE',
    'Philippines': 'PH',
    'Poland': 'PL',
    'Portugal': 'PT',
    'Qatar': 'QA',
    'Romania': 'RO',
    'Russia': 'RU',
    'Rwanda': 'RW',
    'Saint Kitts and Nevis': 'KN',
    'Saint Lucia': 'LC',
    'Saint Vincent and the Grenadines': 'VC',
    'Samoa': 'WS',
    'San Marino': 'SM',
    'Sao Tome and Principe': 'ST',
    'Saudi Arabia': 'SA',
    'Senegal': 'SN',
    'Serbia': 'RS',
    'Seychelles': 'SC',
    'Sierra Leone': 'SL',
    'Singapore': 'SG',
    'Slovakia': 'SK',
    'Slovenia': 'SI',
    'Solomon Islands': 'SB',
    'Somalia': 'SO',
    'South Africa': 'ZA',
    'South Korea': 'KR',
    'South Sudan': 'SS',
    'Spain': 'ES',
    'Sri Lanka': 'LK',
    'Sudan': 'SD',
    'Suriname': 'SR',
    'Sweden': 'SE',
    'Switzerland': 'CH',
    'Syria': 'SY',
    'Taiwan': 'TW',
    'Tajikistan': 'TJ',
    'Tanzania': 'TZ',
    'Thailand': 'TH',
    'Timor-Leste': 'TL',
    'Togo': 'TG',
    'Tonga': 'TO',
    'Trinidad and Tobago': 'TT',
    'Tunisia': 'TN',
    'Turkey': 'TR',
    'Turkmenistan': 'TM',
    'Tuvalu': 'TV',
    'Uganda': 'UG',
    'Ukraine': 'UA',
    'United Arab Emirates': 'AE',
    'United Kingdom': 'GB',
    'United States': 'US',
    'Uruguay': 'UY',
    'Uzbekistan': 'UZ',
    'Vanuatu': 'VU',
    'Vatican City': 'VA',
    'Venezuela': 'VE',
    'Vietnam': 'VN',
    'Yemen': 'YE',
    'Zambia': 'ZM',
    'Zimbabwe': 'ZW',
  };

  /// Returns ISO-3166-1 alpha-2 for a country name, or the first two chars
  /// uppercased as a safe fallback.
  String _toNationalityCode(String countryName) =>
      _countryCode[countryName] ??
      countryName.substring(0, countryName.length.clamp(0, 2)).toUpperCase();

  /// Formats any stored date string to yyyy-MM-dd for the API.
  /// Accepts both "yyyy-MM-dd" and "MM/dd/yyyy".
  String _toApiDate(String raw) {
    if (raw.isEmpty) return '';
    if (raw.contains('-')) return raw; // already yyyy-MM-dd
    try {
      final parts = raw.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
      }
    } catch (_) {}
    return raw;
  }

  /// Extracts the checkout token from flightData.
  /// Priority: flightData['token'] → query param from flightData['checkout_url']
  String _extractToken() {
    final direct = widget.flightData['token']?.toString() ?? '';
    if (direct.isNotEmpty) {
      log('[FlightCheckout] _extractToken: using direct token');
      return direct;
    }
    final checkoutUrl = widget.flightData['checkout_url']?.toString() ?? '';
    log('[FlightCheckout] _extractToken: direct token null, parsing checkout_url: "$checkoutUrl"');
    if (checkoutUrl.isNotEmpty) {
      final uri = Uri.tryParse(checkoutUrl);
      final urlToken = uri?.queryParameters['token'] ?? '';
      log('[FlightCheckout] _extractToken: token from checkout_url = "$urlToken"');
      return urlToken;
    }
    log('[FlightCheckout] _extractToken: ❌ no token found anywhere');
    return '';
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Accept phone numbers with at least 10 digits (can include + - spaces)
    final phoneRegex = RegExp(r'^[\d\s\-\+]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  String? _validateFields() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    log('[Validate] email="${email}" phone="${phone}"');

    if (email.isEmpty) return 'Email address is required'.tr;
    if (email.length > 20)
      return 'Email address cannot exceed 20 characters'.tr;
    if (!_isValidEmail(email)) return 'Please enter a valid email address'.tr;

    if (phone.isEmpty) return 'Phone number is required'.tr;
    if (phone.length > 20) return 'Phone number cannot exceed 20 characters'.tr;
    if (!_isValidPhone(phone)) return 'Please enter a valid phone number'.tr;

    for (int i = 0; i < _passengerForms.length; i++) {
      final form = _passengerForms[i];
      final ctrl = _passengerFormControllers[form.passengerNumber]!;
      final label = 'Passenger ${i + 1}';
      final firstName = ctrl[0].text.trim();
      final lastName = ctrl[1].text.trim();

      log('[Validate] $label firstName="${firstName}" lastName="${lastName}" dob="${form.dateOfBirth}" nationality="${form.nationality}" passport="${ctrl[2].text.trim()}" expiry="${form.passportExpiry}"');

      if (firstName.isEmpty) return '$label: ${'first name is required'.tr}';
      if (firstName.length < 2)
        return '$label: ${'first name must be at least 2 characters'.tr}';
      if (firstName.length > 20)
        return '$label: ${'first name cannot exceed 20 characters'.tr}';

      if (lastName.isEmpty) return '$label: ${'last name is required'.tr}';
      if (lastName.length < 2)
        return '$label: ${'last name must be at least 2 characters'.tr}';
      if (lastName.length > 20)
        return '$label: ${'last name cannot exceed 20 characters'.tr}';

      if (form.dateOfBirth.isEmpty)
        return '$label: ${'date of birth is required'.tr}';
      if (form.nationality.isEmpty)
        return '$label: ${'nationality is required'.tr}';
      if (ctrl[2].text.trim().isEmpty)
        return '$label: ${'passport number is required'.tr}';
      if (form.passportExpiry.isEmpty)
        return '$label: ${'passport expiry is required'.tr}';
    }
    return null;
  }

  Future<void> _handleConfirmPay() async {
    log('[ConfirmPay] button tapped — agreedToTerms=$_agreedToTerms isProcessing=$_isProcessing');
    if (_isProcessing) return;

    // Inline form validation — errors shown under each field
    final formValid = _formKey.currentState!.validate();
    if (!_agreedToTerms) {
      setState(() => _termsError = 'You must accept the terms to continue'.tr);
    }
    if (!formValid || !_agreedToTerms) return;

    log('[ConfirmPay] flightData keys: ${widget.flightData.keys.toList()}');
    log('[ConfirmPay] flightData[token]        = ${widget.flightData['token']}');
    log('[ConfirmPay] flightData[checkout_url] = ${widget.flightData['checkout_url']}');

    final checkoutToken = _extractToken();
    log('[ConfirmPay] checkoutToken resolved: "$checkoutToken"');
    if (checkoutToken.isEmpty) {
      log('[ConfirmPay] ❌ token is empty — showing session expired error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Session expired. Please go back and re-select your flight.',
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isProcessing = true);
    EasyLoading.show(status: 'Processing payment...'.tr);

    try {
      // Load auth token
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('userToken') ?? '';

      // Build passengers list
      final passengers = _passengerForms.map((form) {
        final ctrl = _passengerFormControllers[form.passengerNumber]!;
        return {
          'first_name': ctrl[0].text.trim(),
          'last_name': ctrl[1].text.trim(),
          'title': form.title,
          'dob': _toApiDate(form.dateOfBirth),
          'gender': form.gender == 'Female' ? 'F' : 'M',
          'nationality': _toNationalityCode(form.nationality),
          'passport': ctrl[2].text.trim(),
          'passport_expiry': _toApiDate(form.passportExpiry),
        };
      }).toList();

      final paymentGateway =
          _selectedPaymentMethod == 'card' ? 'stripe' : 'ngenius';

      final body = jsonEncode({
        'checkout_token': checkoutToken,
        'payment_gateway': paymentGateway,
        'contact_email': _emailController.text.trim(),
        'contact_phone': _phoneController.text.trim(),
        'passengers': passengers,
      });

      final url = Uri.parse('${ApiUrls.baseUrl}flights/checkout'
          '?checkout_token=$checkoutToken'
          '&payment_gateway=$paymentGateway'
          '&contact_email=${Uri.encodeComponent(_emailController.text.trim())}'
          '&contact_phone=${Uri.encodeComponent(_phoneController.text.trim())}');

      log('[FlightCheckout] POST $url');
      log('[FlightCheckout] Headers: authToken=${authToken.isNotEmpty ? "present" : "MISSING"}');
      log('[FlightCheckout] Body: $body');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      EasyLoading.dismiss();

      log('[FlightCheckout] Response status : ${response.statusCode}');
      log('[FlightCheckout] Response body   : ${response.body}');

      if (!mounted) return;

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (parseErr) {
        log('[FlightCheckout] ❌ JSON parse failed: $parseErr');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected server response. Please try again.'.tr,
              style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      log('[FlightCheckout] decoded keys: ${decoded.keys.toList()}');
      log('[FlightCheckout] success=${decoded['success']} url=${decoded['url'] ?? decoded['payment_url']}');

      // ── Check for 401 Unauthorized / Session Expired ───────────────────────────────
      if (response.statusCode == 401 ||
          SessionManager.isUnauthorized(
            statusCode: response.statusCode,
            message: decoded['message']?.toString(),
          )) {
        log('[FlightCheckout] ❌ 401 Unauthorized — session expired');
        if (!mounted) return;
        await SessionManager.clearSession();
        if (!mounted) return;
        SessionManager.showSessionExpiredDialog(context);
        return;
      }

      if (decoded['success'] == true) {
        final paymentUrl =
            (decoded['url'] ?? decoded['payment_url'] ?? '').toString();
        log('[FlightCheckout] ✅ paymentUrl: "$paymentUrl"');
        if (paymentUrl.isNotEmpty) {
          // Open Stripe/payment webview — same pattern as hotel checkout
          final outcome =
              await Navigator.of(context).push<StripePaymentOutcome>(
            MaterialPageRoute(
              builder: (_) =>
                  StripeCheckoutWebViewScreen(checkoutUrl: paymentUrl),
            ),
          );

          if (!mounted) return;

          log('[FlightCheckout] WebView closed — result: ${outcome?.result} | bookingCode: ${outcome?.bookingCode}');

          if (outcome?.result == StripePaymentResult.success) {
            final bookingCode = outcome?.bookingCode;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PaymentCompleteScreen(bookingCode: bookingCode),
              ),
            );
          } else if (outcome?.result == StripePaymentResult.cancelled) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Payment cancelled.'.tr,
                  style: GoogleFonts.spaceGrotesk(color: Colors.white)),
              backgroundColor: AppColors.accent,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (outcome?.result == StripePaymentResult.failed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Payment failed. Please try again.'.tr,
                  style: GoogleFonts.spaceGrotesk(color: Colors.white)),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Booking confirmed!'.tr,
                style: GoogleFonts.spaceGrotesk(color: Colors.white)),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        // ── Check status code for 401 before showing error ───────────────────────
        if (response.statusCode == 401) {
          log('[FlightCheckout] ❌ 401 Unauthorized in error response');
          if (!mounted) return;
          await SessionManager.clearSession();
          if (!mounted) return;
          SessionManager.showSessionExpiredDialog(context);
          return;
        }

        // ── Parse field-level validation errors (422) ────────────────────
        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          final phoneErrs = errors['contact_phone'];
          if (phoneErrs is List && phoneErrs.isNotEmpty) {
            setState(() => _phoneError = phoneErrs.first.toString());
            // Scroll is handled naturally since the field is near the top.
            log('[FlightCheckout] 422 phone error: $_phoneError');
          }
        }

        final msg = (decoded['message'] ?? 'Checkout failed. Please try again.')
            .toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(msg, style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      EasyLoading.dismiss();
      log('[FlightCheckout] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Network error. Please try again.'.tr,
              style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildSectionContainer(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: kScaffoldBgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: kPrimaryColor, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 12, color: kSubtitleColor)),
                    ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(text,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kSubtitleColor)));
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text,
      int? maxLength,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.spaceGrotesk(fontSize: 14, color: kHeadingColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.spaceGrotesk(color: kSubtitleColor, fontSize: 14),
        filled: true,
        fillColor: kScaffoldBgColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kSecondaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        errorStyle: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.red),
      ),
    );
  }

  /// Phone field with inline error state — shows red border when [_phoneError]
  /// is set, and clears the error as soon as the user starts typing.
  Widget _buildPhoneField() {
    final hasError = _phoneError != null;
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: _getPhoneMaxLength(),
      style: GoogleFonts.spaceGrotesk(fontSize: 14, color: kHeadingColor),
      onChanged: (_) {
        if (_phoneError != null) setState(() => _phoneError = null);
      },
      decoration: InputDecoration(
        hintText: '501234567',
        hintStyle:
            GoogleFonts.spaceGrotesk(color: kSubtitleColor, fontSize: 14),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : kScaffoldBgColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: hasError ? Colors.red : kBorderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: hasError ? Colors.red : kBorderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: hasError ? Colors.red : kSecondaryColor, width: 1.5)),
        suffixIcon: hasError
            ? const Icon(Icons.error_rounded, color: Colors.red, size: 20)
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 130, maxHeight: 50),
        prefixIcon: GestureDetector(
          onTap: () {
            countryCodeBottomSheet(
              (Country country) {
                setState(() {
                  selectedCountry = country;
                });
              },
              true,
              context,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  '+${selectedCountry.phoneCode}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kHeadingColor,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.arrow_drop_down_outlined,
                    size: 18,
                    color: kMutedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: kScaffoldBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderColor)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.first,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child:
                      Text(e, style: GoogleFonts.spaceGrotesk(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        ),
      ),
    );
  }

  // Full list of countries for nationality dropdown
  static const List<String> _countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestine',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];

  Widget _buildNationalityDropdown(
      PassengerFormData form, ValueChanged<String> onChanged) {
    final selected = form.nationality.isEmpty ? null : form.nationality;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: kScaffoldBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderColor)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text(
            'Select country'.tr,
            style:
                GoogleFonts.spaceGrotesk(fontSize: 14, color: kSubtitleColor),
          ),
          items: _countries
              .map((e) => DropdownMenuItem(
                    value: e,
                    child:
                        Text(e, style: GoogleFonts.spaceGrotesk(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        ),
      ),
    );
  }

  Widget _buildPassportExpiryField(
      PassengerFormData form, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 365)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2060));
        if (date != null) {
          onChanged(DateFormat('MM/dd/yyyy').format(date));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: kScaffoldBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                form.passportExpiry.isEmpty
                    ? 'mm/dd/yyyy'
                    : form.passportExpiry,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: form.passportExpiry.isEmpty
                        ? kSubtitleColor
                        : kHeadingColor)),
            Icon(Icons.calendar_today_outlined,
                size: 16, color: kSubtitleColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
      PassengerFormData form, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
            context: context,
            initialDate: DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now());
        if (date != null) {
          onChanged(DateFormat('yyyy-MM-dd').format(date));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: kScaffoldBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(form.dateOfBirth.isEmpty ? 'mm/dd/yyyy' : form.dateOfBirth,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: form.dateOfBirth.isEmpty
                        ? kSubtitleColor
                        : kHeadingColor)),
            Icon(Icons.calendar_today_outlined,
                size: 16, color: kSubtitleColor),
          ],
        ),
      ),
    );
  }
}
