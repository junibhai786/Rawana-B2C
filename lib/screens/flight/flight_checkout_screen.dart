import 'dart:convert';
import 'dart:developer';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/screens/hotel/stripe_checkout_webview_screen.dart';
import 'package:moonbnd/screens/flight/payment_complete_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Passenger forms tracking
  late List<PassengerFormData> _passengerForms;
  final Map<String, List<TextEditingController>> _passengerFormControllers = {};

  // Processing guard — prevents duplicate taps
  bool _isProcessing = false;

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
      backgroundColor: const Color(0xffF8FAFC),
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
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF05A8C7), Color(0xFF0489A1)],
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
              color: Color(0xFFF0FDFD),
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
                          color: Colors.blueGrey,
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
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: Colors.blueGrey,
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
              border: Border(bottom: BorderSide(color: Color(0xffF1F5F9))),
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
                          fontSize: 12, color: Colors.blueGrey),
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
                _buildTextField(controllers[0], 'First name'.tr),
                const SizedBox(height: 16),
                _buildLabel('Last Name *'.tr),
                _buildTextField(controllers[1], 'Last name'.tr),
                if (isFirstPassenger) ...[
                  const SizedBox(height: 16),
                  _buildLabel('Email Address *'.tr),
                  _buildTextField(_emailController, 'customer@travolyo.com',
                      keyboardType: TextInputType.emailAddress),
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
                    Text('Include country code',
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
                _buildTextField(controllers[2], 'e.g. AA1234567'),
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
              border: Border(bottom: BorderSide(color: Color(0xffF1F5F9))),
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
                Column(
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
                          fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
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
            color: isSelected ? kPrimaryColor : Colors.grey.shade200,
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
                  color: isSelected ? kPrimaryColor : Colors.grey.shade400,
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
                color: const Color(0xff1E293B),
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
                        fontSize: 11, color: Colors.blueGrey),
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
                  color: Colors.blueGrey, fontSize: 14)),
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
      children: [
        Row(
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v!),
              activeColor: kPrimaryColor,
            ),
            Expanded(
              child: Text(
                'I have read and agree to the Terms & Conditions and Privacy Policy.'
                    .tr,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_agreedToTerms && !_isProcessing)
                ? () => _handleConfirmPay()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF05A8C7),
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

  String? _validateFields() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    log('[Validate] email="${email}" phone="${phone}"');
    if (email.isEmpty) return 'Email address is required';
    if (!email.contains('@')) return 'Enter a valid email address';
    if (phone.isEmpty) return 'Phone number is required';

    for (int i = 0; i < _passengerForms.length; i++) {
      final form = _passengerForms[i];
      final ctrl = _passengerFormControllers[form.passengerNumber]!;
      final label = 'Passenger ${i + 1}';
      log('[Validate] $label firstName="${ctrl[0].text.trim()}" lastName="${ctrl[1].text.trim()}" dob="${form.dateOfBirth}" nationality="${form.nationality}" passport="${ctrl[2].text.trim()}" expiry="${form.passportExpiry}"');
      if (ctrl[0].text.trim().isEmpty) return '$label: first name is required';
      if (ctrl[1].text.trim().isEmpty) return '$label: last name is required';
      if (form.dateOfBirth.isEmpty) return '$label: date of birth is required';
      if (form.nationality.isEmpty) return '$label: nationality is required';
      if (ctrl[2].text.trim().isEmpty)
        return '$label: passport number is required';
      if (form.passportExpiry.isEmpty)
        return '$label: passport expiry is required';
    }
    return null;
  }

  Future<void> _handleConfirmPay() async {
    log('[ConfirmPay] button tapped — agreedToTerms=$_agreedToTerms isProcessing=$_isProcessing');
    if (_isProcessing) return;

    // Validate all fields before hitting API
    final error = _validateFields();
    log('[ConfirmPay] validation result: ${error ?? "OK"}');
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(error, style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

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
    EasyLoading.show(status: 'Processing payment...');

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
          content: Text('Unexpected server response. Please try again.',
              style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      log('[FlightCheckout] decoded keys: ${decoded.keys.toList()}');
      log('[FlightCheckout] success=${decoded['success']} url=${decoded['url'] ?? decoded['payment_url']}');

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
              content: Text('Payment cancelled.',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white)),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (outcome?.result == StripePaymentResult.failed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Payment failed. Please try again.',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white)),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Booking confirmed!',
                style: GoogleFonts.spaceGrotesk(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
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
          content: Text('Network error. Please try again.',
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
                      color: Colors.grey.shade50, shape: BoxShape.circle),
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
                              fontSize: 12, color: Colors.blueGrey)),
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
                color: Colors.blueGrey)));
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.spaceGrotesk(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.spaceGrotesk(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
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
      style: GoogleFonts.spaceGrotesk(fontSize: 14),
      onChanged: (_) {
        if (_phoneError != null) setState(() => _phoneError = null);
      },
      decoration: InputDecoration(
        hintText: '+971501234567',
        hintStyle:
            GoogleFonts.spaceGrotesk(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: hasError ? Colors.red : kPrimaryColor, width: 1.5)),
        suffixIcon: hasError
            ? const Icon(Icons.error_rounded, color: Colors.red, size: 20)
            : null,
      ),
    );
  }

  Widget _buildDropdown(List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
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
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text(
            'Select country'.tr,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 14, color: Colors.grey.shade400),
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
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200)),
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
                        ? Colors.grey.shade400
                        : Colors.black87)),
            Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.grey.shade400),
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
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(form.dateOfBirth.isEmpty ? 'mm/dd/yyyy' : form.dateOfBirth,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: form.dateOfBirth.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black87)),
            Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
