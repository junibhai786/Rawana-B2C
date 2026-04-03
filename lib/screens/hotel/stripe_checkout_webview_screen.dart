import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';

enum StripePaymentResult { success, cancelled, failed, unknown }

/// Holds the WebView close result plus the extracted booking code and session ID.
class StripePaymentOutcome {
  final StripePaymentResult result;
  final String? bookingCode; // extracted from ?c= query param in return URL
  final String? sessionId; // extracted from ?session_id= query param

  const StripePaymentOutcome({
    required this.result,
    this.bookingCode,
    this.sessionId,
  });
}

class StripeCheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const StripeCheckoutWebViewScreen({
    Key? key,
    required this.checkoutUrl,
  }) : super(key: key);

  @override
  State<StripeCheckoutWebViewScreen> createState() =>
      _StripeCheckoutWebViewScreenState();
}

class _StripeCheckoutWebViewScreenState
    extends State<StripeCheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  /// Prevents duplicate handling of the return URL.
  bool _resultHandled = false;

  String? _bookingCode;
  String? _sessionId;

  // ── Domain / URL helpers ────────────────────────────────────────────────

  bool _isStripeDomain(String url) {
    return url.contains('checkout.stripe.com') ||
        url.contains('js.stripe.com') ||
        url.contains('hooks.stripe.com') ||
        url.contains('about:blank');
  }

  /// Returns true when the URL is the backend's payment return route.
  bool _isReturnUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/payments/stripe/return') ||
        lower.contains('/payments/stripe/success') ||
        lower.contains('payment_return') ||
        lower.contains('payment-return');
  }

  /// Returns true when the URL is a cancel/fail route.
  bool _isCancelOrFailUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/payment/cancel') ||
        lower.contains('/stripe/cancel') ||
        lower.contains('payment_cancel') ||
        lower.contains('payment-cancel') ||
        lower.contains('payment_fail') ||
        lower.contains('payment-fail');
  }

  /// True when this is a non-Stripe URL that carries a session_id param
  /// (i.e. the backend return redirect, even if the path pattern differs).
  bool _hasSessionIdParam(String url) {
    try {
      final target = url.contains('://') ? url : 'https://placeholder$url';
      final uri = Uri.tryParse(target);
      return uri?.queryParameters.containsKey('session_id') ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Param extraction ────────────────────────────────────────────────────

  String? _extractBookingCode(String url) {
    try {
      final target = url.contains('://') ? url : 'https://placeholder$url';
      final uri = Uri.tryParse(target);
      if (uri == null) return null;

      final qParam = uri.queryParameters['c'];
      if (qParam != null && qParam.isNotEmpty) return qParam;

      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final last = segments.last;
        if (last.toUpperCase().startsWith('TRV-')) return last;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractSessionId(String url) {
    try {
      final target = url.contains('://') ? url : 'https://placeholder$url';
      final uri = Uri.tryParse(target);
      if (uri == null) return null;
      final sid = uri.queryParameters['session_id'];
      if (sid != null && sid.isNotEmpty) return sid;
      return null;
    } catch (_) {
      return null;
    }
  }

  void _extractParamsFromUrl(String url) {
    _bookingCode ??= _extractBookingCode(url);
    _sessionId ??= _extractSessionId(url);
    debugPrint(
        '[STRIPE] extracted bookingCode=$_bookingCode  sessionId=$_sessionId  from $url');
  }

  // ── HTTP → HTTPS fix ───────────────────────────────────────────────────

  /// Ngrok/backend may return an `http://` URL. Stripe & Android WebView
  /// require HTTPS. Force the scheme to https if it's http.
  String _ensureHttps(String url) {
    if (url.startsWith('http://')) {
      final fixed = url.replaceFirst('http://', 'https://');
      debugPrint('[STRIPE] Fixed http → https: $fixed');
      return fixed;
    }
    return url;
  }

  // ── Pop helper ─────────────────────────────────────────────────────────

  void _popWithResult(StripePaymentResult result, String reason) {
    if (_resultHandled) return;
    _resultHandled = true;
    final outcome = StripePaymentOutcome(
      result: result,
      bookingCode: _bookingCode,
      sessionId: _sessionId,
    );
    debugPrint(
        '[STRIPE WEBVIEW] $reason — result: $result | bookingCode: $_bookingCode | sessionId: $_sessionId');
    _controller.loadRequest(Uri.parse('about:blank'));
    if (mounted) Navigator.of(context).pop(outcome);
  }

  // ── Core fix: HTTP-call the return URL from Flutter ────────────────────

  /// When the WebView would navigate to the backend return URL, we BLOCK
  /// the WebView (`NavigationDecision.prevent`) and instead invoke it
  /// via `http.get()` with proper auth headers. This is exactly what a
  /// real browser does — hit the server route, let it verify the Stripe
  /// session, and update the order. The WebView alone doesn't carry the
  /// auth context / cookies the backend needs to complete the flow.
  Future<void> _handleReturnUrl(String url) async {
    if (_resultHandled) return;

    _extractParamsFromUrl(url);
    final httpsUrl = _ensureHttps(url);

    debugPrint('[STRIPE] ── handleReturnUrl START ──');
    debugPrint('[STRIPE] Original URL : $url');
    debugPrint('[STRIPE] HTTPS URL    : $httpsUrl');
    debugPrint('[STRIPE] bookingCode  : $_bookingCode');
    debugPrint('[STRIPE] sessionId    : $_sessionId');

    // Show a loading dialog so the user knows we are processing.
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: kPrimaryColor,
                    strokeWidth: 2.5,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Verifying payment…',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // ── Step 1: Call the return URL via HTTP ─────────────────────────────
      // This lets the backend execute its verification route just like a
      // browser would. We send the auth token and ngrok header so the
      // backend doesn't reject the request.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken') ?? '';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': Get.locale?.languageCode == 'en' ? 'en' : 'ar',
        'ngrok-skip-browser-warning': 'true',
      };

      debugPrint('[STRIPE] Calling return URL via http.get …');
      final returnResponse = await http
          .get(Uri.parse(httpsUrl), headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('[STRIPE] Return URL response: ${returnResponse.statusCode}');
      debugPrint('[STRIPE] Return URL body: ${returnResponse.body}');

      // ── Step 2: Parse any booking code / status from the response ──────
      try {
        final data = json.decode(returnResponse.body);
        if (data is Map<String, dynamic>) {
          _bookingCode ??= data['booking_code']?.toString() ??
              data['data']?['booking_code']?.toString() ??
              data['c']?.toString();
          _sessionId ??= data['session_id']?.toString() ??
              data['data']?['session_id']?.toString();

          final status = data['status']?.toString().toLowerCase() ??
              data['data']?['status']?.toString().toLowerCase();
          debugPrint('[STRIPE] Parsed status from return response: $status');
        }
      } catch (_) {
        // Response may be HTML (redirect page) — that's fine.
        debugPrint('[STRIPE] Return response is not JSON — continuing to poll');
      }
    } catch (e) {
      debugPrint('[STRIPE] Error calling return URL: $e');
      // Don't fail hard — the backend may have already processed via webhook.
      // Fall through to polling.
    }

    // Dismiss the loading dialog.
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // ── Step 3: Pop back to caller with success result ────────────────────
    // The calling screen (hotel_checkout_screen) will poll the order
    // endpoint and only navigate to confirmation when status is terminal.
    _popWithResult(
      StripePaymentResult.success,
      'Return URL called via http.get — deferring final status to polling',
    );
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    debugPrint('');
    debugPrint('[STRIPE WEBVIEW]');
    debugPrint('INITIAL URL: ${widget.checkoutUrl}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('[STRIPE WEBVIEW PAGE STARTED] $url');
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('[STRIPE WEBVIEW PAGE FINISHED] $url');
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('[STRIPE WEBVIEW NAVIGATION REQUEST] $url');

            // Always allow Stripe-owned domains.
            if (_isStripeDomain(url)) {
              return NavigationDecision.navigate;
            }

            // ── Return URL detected ──────────────────────────────────────
            // BLOCK the WebView and call the URL via http.get() instead.
            // The WebView doesn't carry the cookies/auth the backend
            // needs; doing an explicit HTTP call fixes the root cause.
            if (_isReturnUrl(url) || _hasSessionIdParam(url)) {
              if (!_resultHandled) {
                debugPrint(
                    '[STRIPE WEBVIEW] INTERCEPTED return URL — calling via http.get');
                _handleReturnUrl(url);
              }
              return NavigationDecision.prevent;
            }

            // ── Cancel / fail URL ────────────────────────────────────────
            if (_isCancelOrFailUrl(url)) {
              debugPrint('[STRIPE WEBVIEW] Cancel/fail URL detected');
              _extractParamsFromUrl(url);
              if (url.toLowerCase().contains('fail')) {
                _popWithResult(
                    StripePaymentResult.failed, 'FAIL redirect detected');
              } else {
                _popWithResult(
                    StripePaymentResult.cancelled, 'CANCEL redirect detected');
              }
              return NavigationDecision.prevent;
            }

            // ── Unknown non-Stripe URL ───────────────────────────────────
            // Could be an intermediate redirect. Allow it.
            debugPrint('[STRIPE WEBVIEW] Unknown non-Stripe URL — allowing');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
                '[STRIPE WEBVIEW ERROR] ${error.description} (code: ${error.errorCode}) url: ${error.url}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Payment',
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
          onPressed: () {
            debugPrint('[STRIPE WEBVIEW] Back pressed — closing WebView');
            if (!_resultHandled) {
              _resultHandled = true;
              Navigator.of(context).pop(
                const StripePaymentOutcome(result: StripePaymentResult.unknown),
              );
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
                strokeWidth: 2.5,
              ),
            ),
        ],
      ),
    );
  }
}
