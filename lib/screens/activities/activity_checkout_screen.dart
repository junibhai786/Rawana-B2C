import 'dart:developer';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/Provider/activity_provider.dart';
import 'package:moonbnd/screens/activities/activity_booking_confirmed_screen.dart';
import 'package:moonbnd/screens/hotel/stripe_checkout_webview_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ActivityCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> activityData;

  const ActivityCheckoutScreen({
    Key? key,
    required this.activityData,
  }) : super(key: key);

  @override
  State<ActivityCheckoutScreen> createState() => _ActivityCheckoutScreenState();
}

class _ActivityCheckoutScreenState extends State<ActivityCheckoutScreen> {
  // Form controls
  bool _agreedToTerms = false;
  String _selectedPaymentMethod = 'card';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _passportExpiryController =
      TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  String _selectedTitle = 'Mr';
  String _selectedGender = 'Male';

  // Processing guard
  bool _isProcessing = false;

  // Shows full-screen overlay while polling for order confirmation
  bool _isConfirmingBooking = false;

  // Inline field errors from server 422 response
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    log('[ActivityCheckout] ========== CHECKOUT SCREEN INIT ==========');
    log('[ActivityCheckout] activityData keys  : ${widget.activityData.keys.toList()}');
    log('[ActivityCheckout] token value        : ${widget.activityData['checkout_token']}');
    log('[ActivityCheckout] checkout_url value : ${widget.activityData['checkout_url']}');
  }

  String _extractToken() {
    final token = widget.activityData['checkout_token'];
    log('[ActivityCheckout] Extracting token from: $token (type: ${token.runtimeType})');
    if (token is String) {
      return token.trim();
    } else if (token == null) {
      log('[ActivityCheckout] Token is null');
      return '';
    } else {
      log('[ActivityCheckout] Token is unexpected type: ${token.runtimeType}');
      return token.toString().trim();
    }
  }

  String? _validateFields() {
    if (_emailController.text.trim().isEmpty) {
      return 'Email address is required'.tr;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
        .hasMatch(_emailController.text.trim())) {
      return 'Please enter a valid email address'.tr;
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Phone number is required'.tr;
    }
    if (_firstNameController.text.trim().isEmpty) {
      return 'First name is required'.tr;
    }
    if (_lastNameController.text.trim().isEmpty) {
      return 'Last name is required'.tr;
    }
    if (_dateOfBirthController.text.trim().isEmpty) {
      return 'Date of birth is required'.tr;
    }
    if (_nationalityController.text.trim().isEmpty) {
      return 'Nationality is required'.tr;
    }
    if (_passportNumberController.text.trim().isEmpty) {
      return 'Passport number is required'.tr;
    }
    if (_passportExpiryController.text.trim().isEmpty) {
      return 'Passport expiry date is required'.tr;
    }
    if (!_agreedToTerms) {
      return 'Please accept the Terms & Conditions'.tr;
    }
    return null;
  }

  Future<void> _handleConfirmPay() async {
    log('[ActivityConfirmPay] button tapped — agreedToTerms=$_agreedToTerms isProcessing=$_isProcessing');
    if (_isProcessing) return;

    // Validate fields
    final error = _validateFields();
    log('[ActivityConfirmPay] validation result: ${error ?? "OK"}');
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(error, style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final checkoutToken = _extractToken();
    log('[ActivityConfirmPay] checkoutToken resolved: "$checkoutToken"');
    if (checkoutToken.isEmpty) {
      log('[ActivityConfirmPay] ❌ token is empty — showing session expired error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Session expired. Please go back and try again.'.tr,
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
      final paymentGateway =
          _selectedPaymentMethod == 'card' ? 'stripe' : 'ngenius';

      final provider = context.read<ActivityProvider>();

      final success = await provider.activityCheckout(
        checkoutToken: checkoutToken,
        contactEmail: _emailController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        paymentGateway: paymentGateway,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dob: _dateOfBirthController.text.trim(),
        nationality: _nationalityController.text.trim(),
        gender: _selectedGender,
        passport: _passportNumberController.text.trim(),
        passportExpiry: _passportExpiryController.text.trim(),
        specialRequests: _specialRequestsController.text.trim(),
      );

      EasyLoading.dismiss();
      if (!mounted) return;

      if (success) {
        final paymentUrl = provider.checkoutStripeUrl ?? '';
        final apiBookingCode = provider.checkoutBookingCode;

        log('[ActivityConfirmPay] ✅ paymentUrl="$paymentUrl"  bookingCode="$apiBookingCode"');

        if (paymentUrl.isNotEmpty) {
          final outcome =
              await Navigator.of(context).push<StripePaymentOutcome>(
            MaterialPageRoute(
              builder: (_) =>
                  StripeCheckoutWebViewScreen(checkoutUrl: paymentUrl),
            ),
          );

          if (!mounted) return;

          log('[ActivityConfirmPay] WebView closed — result: ${outcome?.result} | bookingCode: ${outcome?.bookingCode}');

          if (outcome?.result == StripePaymentResult.success) {
            final bookingCode = outcome?.bookingCode ?? apiBookingCode;

            if (bookingCode != null && bookingCode.isNotEmpty) {
              // Show full-screen overlay while polling
              setState(() => _isConfirmingBooking = true);

              log('[ActivityConfirmPay] polling for order — bookingCode="$bookingCode"');

              final confirmed = await provider.pollForActivityConfirmedStatus(
                bookingCode,
                maxAttempts: 10,
                interval: const Duration(seconds: 2),
              );

              if (!mounted) return;

              if (confirmed && provider.orderData != null) {
                log('[ActivityConfirmPay] ✅ order confirmed — navigating to ActivityBookingConfirmedScreen');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ActivityBookingConfirmedScreen(
                        data: provider.orderData!),
                  ),
                );
              } else {
                setState(() => _isConfirmingBooking = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    provider.orderError ??
                        'Payment is being processed. Please check your bookings shortly.'
                            .tr,
                    style: GoogleFonts.spaceGrotesk(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 6),
                ));
              }
            } else {
              // No booking code — show fallback
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Payment successful! Check your bookings for details.'.tr,
                    style: GoogleFonts.spaceGrotesk(color: Colors.white)),
                backgroundColor: kPrimaryColor,
                behavior: SnackBarBehavior.floating,
              ));
            }
          } else if (outcome?.result == StripePaymentResult.cancelled) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Payment cancelled.'.tr,
                  style: GoogleFonts.spaceGrotesk(color: Colors.white)),
              backgroundColor: Colors.orange,
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
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        final msg =
            provider.checkoutError ?? 'Booking failed. Please try again.'.tr;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(msg, style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      EasyLoading.dismiss();
      log('[ActivityConfirmPay] ❌ EXCEPTION: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again.'.tr,
            style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _nationalityController.dispose();
    _passportNumberController.dispose();
    _passportExpiryController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: Color(0xff1D2025)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Activity Booking'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1D2025),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Activity Summary Card ────────────────────────────────
                  _buildActivitySummaryCard(),
                  const SizedBox(height: 20),

                  // ── Booking Details Section ──────────────────────────────
                  _buildBookingDetailsSection(),
                  const SizedBox(height: 20),

                  // ── Guest Details Section ────────────────────────────────
                  _buildGuestDetailsSection(),
                  const SizedBox(height: 20),

                  // ── Payment Method Section ───────────────────────────────
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 20),

                  // ── Special Requests ────────────────────────────────────
                  _buildSpecialRequestsSection(),
                  const SizedBox(height: 20),

                  // ── Price Summary ────────────────────────────────────────
                  _buildPriceSummarySection(),
                  const SizedBox(height: 20),

                  // ── Terms & Checkout ────────────────────────────────────
                  _buildTermsAndCheckout(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        if (_isConfirmingBooking) _buildBookingLoadingOverlay(),
      ],
    );
  }

  Widget _buildBookingLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: const Color(0xffF8FAFC),
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
                    color: const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySummaryCard() {
    final data = widget.activityData;
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
                  child: const Icon(Icons.location_on_rounded,
                      color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data['activity_title'] ?? 'Activity').toString(),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (data['city'] != null &&
                          data['city'].toString().isNotEmpty)
                        Text(
                          '${data['city']}, ${data['country'] ?? ""}',
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
                _buildSummaryRow(
                    Icons.calendar_today_outlined,
                    'Activity Date'.tr,
                    data['activity_date']?.toString() ?? ''),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow(
                    Icons.people_outline,
                    'Participants'.tr,
                    '${data['participants']} ${data['participants'] == 1 ? 'Person' : 'People'}'
                        .tr),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow(Icons.category_outlined, 'Category'.tr,
                    data['category']?.toString() ?? ''),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow(Icons.timer_outlined, 'Duration'.tr,
                    data['duration']?.toString() ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildBookingDetailsSection() {
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
                  child: const Icon(Icons.info_outline_rounded,
                      color: kPrimaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    Text(
                      'Email and phone for the booking'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
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
                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address'.tr,
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email_outlined,
                        size: 18, color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  style: GoogleFonts.spaceGrotesk(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Phone field with error handling
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Phone Number'.tr,
                        hintText: '+971 123 456 7890',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            size: 18, color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _phoneError != null
                                ? Colors.red.shade700
                                : const Color(0xffE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _phoneError != null
                                ? Colors.red.shade700
                                : const Color(0xffE2E8F0),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.red.shade700, width: 2),
                        ),
                        suffixIcon: _phoneError != null
                            ? Icon(Icons.error_outline_rounded,
                                color: Colors.red.shade700, size: 18)
                            : null,
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 14),
                    ),
                    if (_phoneError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _phoneError!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestDetailsSection() {
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
                      'Passenger Details'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    Text(
                      'Passenger information for this booking'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
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
                // Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        value: _selectedTitle,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedTitle = newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // First Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Name'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter first name'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Last Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Name'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter last name'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date of Birth
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _dateOfBirthController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _dateOfBirthController.text =
                              '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'mm/dd/yyyy'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        suffixIcon: const Icon(Icons.calendar_today,
                            size: 18, color: kPrimaryColor),
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nationality
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nationality'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nationalityController,
                      decoration: InputDecoration(
                        hintText: 'PK, AE, US'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: ['Male', 'Female', 'Other'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedGender = newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Passport Number
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passport Number'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passportNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter passport number'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Passport Expiry
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passport Expiry'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passportExpiryController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 180)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          _passportExpiryController.text =
                              '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'mm/dd/yyyy'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        suffixIcon: const Icon(Icons.calendar_today,
                            size: 18, color: kPrimaryColor),
                      ),
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
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

  Widget _buildPaymentMethodSection() {
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
                        color: kPrimaryColor,
                      ),
                    ),
                    Text(
                      'Select your preferred payment option'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
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
                _buildPaymentOption('card', 'Credit / Debit Card'.tr,
                    'Secure card processing with Stripe'),
                const SizedBox(height: 12),
                _buildPaymentOption(
                    'alternative', 'Alternative Payment'.tr, 'Digital wallets'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? kPrimaryColor : const Color(0xffE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color:
              isSelected ? kPrimaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
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
                          shape: BoxShape.circle,
                          color: kPrimaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xff1D2025)
                          : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.blueGrey,
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

  Widget _buildSpecialRequestsSection() {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Requests'.tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1D2025),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialRequestsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any special requests or notes?'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.spaceGrotesk(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummarySection() {
    final data = widget.activityData;
    final unitPrice = data['unit_price'] ?? 0.0;
    final totalPrice = data['total_price'] ?? 0.0;
    final currency = data['currency'] ?? 'AED';

    return Container(
      padding: const EdgeInsets.all(20),
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
          _buildPriceRow('Unit Price × ${data['participants']}',
              '$currency ${unitPrice.toStringAsFixed(2)}'),
          _buildPriceRow('Taxes & fees', 'Included'.tr),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total'.tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                '$currency ${totalPrice.toStringAsFixed(2)}',
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndCheckout() {
    final data = widget.activityData;
    final totalPrice = data['total_price'] ?? 0.0;
    final currency = data['currency'] ?? 'AED';

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
                  'Confirm & Pay $currency ${totalPrice.toStringAsFixed(2)}'.tr,
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
}
