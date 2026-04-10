import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:moonbnd/screens/hotel/stripe_checkout_webview_screen.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_confirmed_screen.dart';
import 'package:moonbnd/Provider/hotel_checkout_provider.dart';
import 'package:moonbnd/modals/hotel_detail_model.dart';
import 'package:moonbnd/modals/hotel_room_model.dart';
import 'package:moonbnd/modals/hotel_prebook_response_model.dart';
import 'package:moonbnd/modals/hotel_booking_confirmation_model.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/services/session_manager.dart';

enum StepStatus { completed, active, future }

class HotelCheckoutScreen extends StatefulWidget {
  final HotelDetail hotel;
  final HotelRoomModel room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final HotelPreBookResponse prebookResponse;
  final String? city;
  final String? country;

  const HotelCheckoutScreen({
    Key? key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.prebookResponse,
    this.city,
    this.country,
  }) : super(key: key);

  @override
  State<HotelCheckoutScreen> createState() => _HotelCheckoutScreenState();
}

class GuestFormData {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';

  GuestFormData();
}

class _HotelCheckoutScreenState extends State<HotelCheckoutScreen> {
  bool _agreedToTerms = false;
  String _selectedPaymentMethod = 'card';
  bool _isConfirmingBooking =
      false; // shows full-screen overlay while fetching order details
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late List<GuestFormData> _guestForms;

  @override
  void initState() {
    super.initState();
    _initializeGuestForms();
  }

  void _initializeGuestForms() {
    _guestForms =
        List.generate(widget.adults + widget.children, (_) => GuestFormData());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kScaffoldBgColor,
          appBar: AppBar(
            title: Text(
              'Checkout'.tr,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHotelSummarySection(),
                      const SizedBox(height: 20),
                      _buildGuestDetailsSection(),
                      const SizedBox(height: 20),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 20),
                      _buildBookingSummarySection(),
                      const SizedBox(height: 20),
                      _buildTermsSection(),
                      const SizedBox(height: 30),
                      _buildCheckoutButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ), // Scaffold
        if (_isConfirmingBooking) _buildBookingLoadingOverlay(),
      ],
    );
  }

  Widget _buildBookingLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: kScaffoldBgColor,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: kPrimaryColor, strokeWidth: 2.5),
                const SizedBox(height: 24),
                Text(
                  'Confirming your booking...'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait a moment'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: kSubtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor,
            kSecondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
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
          _buildProgressStep(2, 'Select Room'.tr, StepStatus.completed),
          _buildProgressConnector(true),
          _buildProgressStep(3, 'Guest Details'.tr, StepStatus.active),
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
          return Icons.hotel_rounded;
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
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
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
          label.split(' ').join('\n'), // Multi-line for tight space
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
        margin: const EdgeInsets.only(
            bottom: 26), // Adjusted to align with circle centers
        color: Colors.white.withOpacity(isDone ? 0.6 : 0.2),
      ),
    );
  }

  Widget _buildHotelSummarySection() {
    final nights = widget.checkOut.difference(widget.checkIn).inDays;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Teal Header matching web version
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.data?.title ?? '',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      widget.city != null && widget.country != null
                          ? "${widget.city}, ${widget.country}"
                          : (widget.hotel.data?.address ?? ''),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Data Rows matching web columns
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryItem(
                  icon: Icons.meeting_room_outlined,
                  label: 'Check-in'.tr,
                  value: DateFormat('yyyy-MM-dd').format(widget.checkIn),
                ),
                _buildDivider(),
                _buildSummaryItem(
                  icon: Icons.meeting_room_outlined,
                  label: 'Check-out'.tr,
                  value: DateFormat('yyyy-MM-dd').format(widget.checkOut),
                ),
                _buildDivider(),
                _buildSummaryItem(
                  icon: Icons.nightlight_outlined,
                  label: '${'Duration'.tr} - ${'Room'.tr}',
                  value: "$nights ${'nights'.tr} • ${widget.room.name ?? ''}",
                ),
                _buildDivider(),
                _buildSummaryItem(
                  icon: Icons.group_outlined,
                  label: 'Guests'.tr,
                  value:
                      "${widget.adults} ${'Adults'.tr}${widget.children > 0 ? ', ${widget.children} ${'Children'.tr}' : ''}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: kPrimaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: kSubtitleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kHeadingColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 50), // Align with text start
      child: Divider(color: kBorderColor, height: 1),
    );
  }

  Widget _buildContactInformationSection() {
    return const SizedBox.shrink();
  }

  Widget _buildGuestDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_guestForms.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildGuestCard(index),
          );
        }),
      ],
    );
  }

  Widget _buildGuestCard(int index) {
    final isFirstGuest = index == 0;
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header matching the image style
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
                    color: kPrimaryTintColor,
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
                      isFirstGuest
                          ? 'Guest Details'.tr
                          : '${'Guest'.tr} ${index + 1}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    Text(
                      isFirstGuest
                          ? 'Primary guest information for this booking'.tr
                          : 'Additional guest'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: kSubtitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'First Name *',
                  hint: 'Customer',
                  maxLength: 20,
                  onChanged: (val) => _guestForms[index].firstName = val,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Last Name *',
                  hint: 'Last name',
                  maxLength: 20,
                  onChanged: (val) => _guestForms[index].lastName = val,
                ),
                if (isFirstGuest) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email Address *',
                    hint: 'abc@travolyo.com',
                    maxLength: 30,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) => _guestForms[index].email = val,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Phone Number *',
                    hint: '+971501234567',
                    maxLength: 20,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => _guestForms[index].phone = val,
                    helperText: 'Include country code',
                  ),
                ],
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

  Widget _buildPaymentOption(
      String id, String title, String subtitle, IconData? icon, String? badge) {
    bool isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
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
                  color: isSelected ? kPrimaryColor : kBorderColor,
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
                          fontWeight: FontWeight.bold,
                        ),
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
                      fontSize: 11,
                      color: kSubtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummarySection() {
    final currency = widget.prebookResponse.currency ?? 'USD';
    final total = widget.prebookResponse.totalPrice ?? 0.0;

    return _buildSectionContainer(
      title: 'Booking Summary'.tr,
      child: Column(
        children: [
          _buildPriceRow(
              'Room Subtotal'.tr, "$currency ${total.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _buildPriceRow('Taxes & Fees'.tr, "$currency 0.00"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: kBorderColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price'.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              Text(
                "$currency ${total.toStringAsFixed(2)}",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: kSubtitleColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
            activeColor: kSecondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: kSubtitleColor,
                height: 1.4,
              ),
              children: [
                TextSpan(text: "${'By proceeding, I agree to the'.tr} "),
                TextSpan(
                  text: 'Terms & Conditions'.tr,
                  style: const TextStyle(
                      color: kSecondaryColor, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: " ${'and'.tr} "),
                TextSpan(
                  text: 'Privacy Policy'.tr,
                  style: const TextStyle(
                      color: kSecondaryColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Validates inputs and calls the checkout API via [HotelCheckoutProvider].
  Future<void> _handleCheckout() async {
    // --- Validation ---
    final firstName =
        _guestForms.isNotEmpty ? _guestForms[0].firstName.trim() : '';
    final lastName =
        _guestForms.isNotEmpty ? _guestForms[0].lastName.trim() : '';
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty) {
      _showError('Please enter first name');
      return;
    }
    if (firstName.length < 2) {
      _showError('First name must be at least 2 characters');
      return;
    }
    if (firstName.length > 20) {
      _showError('First name cannot exceed 20 characters');
      return;
    }
    if (lastName.isEmpty) {
      _showError('Please enter last name');
      return;
    }
    if (lastName.length < 2) {
      _showError('Last name must be at least 2 characters');
      return;
    }
    if (lastName.length > 20) {
      _showError('Last name cannot exceed 20 characters');
      return;
    }
    if (email.isEmpty) {
      _showError('Please enter email address');
      return;
    }
    if (email.length > 30) {
      _showError('Email address cannot exceed 30 characters');
      return;
    }
    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }
    if (phone.isEmpty) {
      _showError('Please enter phone number');
      return;
    }
    if (phone.length > 20) {
      _showError('Phone number cannot exceed 20 characters');
      return;
    }
    if (!_isValidPhone(phone)) {
      _showError('Please enter a valid phone number');
      return;
    }
    if (!_agreedToTerms) {
      _showError('Please agree to Terms & Conditions');
      return;
    }

    // --- Checkout token: must come from a fresh prebook response ---
    final checkoutToken = widget.prebookResponse.checkoutToken;

    log('');
    log('[HOTEL CHECKOUT TOKEN DEBUG]');
    log('TOKEN PASSED TO CHECKOUT SCREEN: $checkoutToken');
    log('CHECKOUT TOKEN VALUE  : $checkoutToken');
    log('CHECKOUT TOKEN IS NULL: ${checkoutToken == null || checkoutToken.isEmpty}');
    log('CHECKOUT TOKEN LENGTH : ${checkoutToken?.length ?? 0}');

    // If token is missing the session has already expired — block checkout and
    // send the user back to re-select their room.
    if (checkoutToken == null || checkoutToken.isEmpty) {
      log('[HOTEL CHECKOUT TOKEN DEBUG] ERROR: checkout_token is null or empty — navigating back');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Your hotel session has expired. Please go back and select your room again.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    // --- Payment gateway mapping ---
    final paymentGateway =
        _selectedPaymentMethod == 'card' ? 'stripe' : 'ngenius';

    log('[HOTEL CHECKOUT TOKEN DEBUG] CHECKOUT TOKEN USED IN REQUEST: $checkoutToken');
    log('[HOTEL CHECKOUT] Initiating checkout for $email | gateway: $paymentGateway');

    log('');
    log('[PAYMENT FLOW STATE]');
    log('STEP: pay_clicked');

    final provider = context.read<HotelCheckoutProvider>();
    final success = await provider.checkoutHotel(
      checkoutToken: checkoutToken,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      paymentGateway: paymentGateway,
    );

    if (!mounted) return;

    if (success) {
      final response = provider.checkoutResponse;
      final paymentUrl = response?.paymentUrl;

      log('');
      log('[HOTEL CHECKOUT SUCCESS]');
      log('SUCCESS: true');
      log('STRIPE URL: $paymentUrl');

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        log('');
        log('[PAYMENT FLOW STATE]');
        log('STEP: stripe_webview_opened');
        log('');
        log('[NAVIGATION]');
        log('ACTION: push');
        log('TARGET: StripeCheckoutWebViewScreen');

        final outcome = await Navigator.of(context).push<StripePaymentOutcome>(
          MaterialPageRoute(
            builder: (_) =>
                StripeCheckoutWebViewScreen(checkoutUrl: paymentUrl),
          ),
        );

        if (!mounted) return;

        log('');
        log('[PAYMENT FLOW STATE]');
        log('STEP: stripe_success_detected');
        log('RESULT     : ${outcome?.result}');
        log('BOOKING CODE: ${outcome?.bookingCode}');

        if (outcome?.result == StripePaymentResult.success) {
          final bookingCode = outcome?.bookingCode;

          if (bookingCode != null && bookingCode.isNotEmpty) {
            // ── Show full-screen overlay IMMEDIATELY ──
            setState(() => _isConfirmingBooking = true);

            log('');
            log('[PAYMENT FLOW STATE]');
            log('STEP: polling_for_confirmed_status');
            log('BOOKING CODE: $bookingCode');
            log('SESSION ID: ${outcome?.sessionId}');

            // ── Poll until order reaches a terminal status ──
            // The WebView has already let the backend return URL execute,
            // so the order should transition from pending → paid shortly.
            // We poll to confirm before navigating.
            final confirmed = await provider.pollForConfirmedStatus(
              bookingCode,
              maxAttempts: 10,
              interval: const Duration(seconds: 2),
            );

            if (!mounted) return;

            if (confirmed && provider.orderData != null) {
              log('');
              log('[PAYMENT FLOW STATE]');
              log('STEP: navigating_to_confirmation');
              log('FINAL STATUS: ${provider.orderData!.status}');

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => HotelBookingConfirmedScreen(
                    data: provider.orderData!,
                    city: widget.city,
                  ),
                ),
              );
            } else {
              // Payment still processing after all poll attempts
              setState(() => _isConfirmingBooking = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.orderError ??
                        'Payment is being processed. Please check your bookings shortly.',
                    style: GoogleFonts.spaceGrotesk(),
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 6),
                ),
              );
            }
          } else {
            // No booking code extracted — show fallback message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Payment successful! Check your bookings for details.',
                    style: GoogleFonts.spaceGrotesk()),
                backgroundColor: kPrimaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (outcome?.result == StripePaymentResult.cancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Payment cancelled.', style: GoogleFonts.spaceGrotesk()),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (outcome?.result == StripePaymentResult.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed. Please try again.',
                  style: GoogleFonts.spaceGrotesk()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Fallback: show success message when no URL returned
      final msg = response?.message ?? 'Booking confirmed successfully!';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.spaceGrotesk()),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // ── Check for session expiration (401) before showing generic error ──
      if (provider.isSessionExpired) {
        if (!mounted) return;
        await SessionManager.clearSession();
        if (!mounted) return;
        SessionManager.showSessionExpiredDialog(context);
        return;
      }

      // ── Show generic error for other failures ──
      _showError(provider.error ?? 'Checkout failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.spaceGrotesk()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Consumer<HotelCheckoutProvider>(
      builder: (context, checkoutProvider, _) {
        final isLoading = checkoutProvider.isLoading;
        final canSubmit = _agreedToTerms && !isLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canSubmit ? _handleCheckout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              disabledBackgroundColor: kBorderColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Confirm & Pay Now'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContainer(
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? helperText,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kHeadingColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: kHeadingColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.spaceGrotesk(color: kSubtitleColor, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: kScaffoldBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kSecondaryColor, width: 1.5),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: kSecondaryColor,
            ),
          ),
        ],
      ],
    );
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
}
