import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String weburl;

  const PaymentScreen({super.key, this.weburl = ""});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController webViewController;
  String urlGo = "";

  @override
  void initState() {
    super.initState();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            log('Page started loading: $url');
          },
          onPageFinished: (url) {
            setState(() {
              urlGo = url;
              log('Page finished loading: $url');
            });
            if (url.contains("api/booking/confirm/")) {
              log('✅ Payment successful, navigating back to booking screen...');
              Navigator.of(context).pop(urlGo);
            }
          },
          onProgress: (progress) {
            log('Loading progress: $progress%');
          },

        ),
      )
      ..loadRequest(Uri.parse(widget.weburl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        log("Will pop called");
        Navigator.of(context).pop(urlGo);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop(urlGo);
            },
          ),
          title: const Text("Payment"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: WebViewWidget(controller: webViewController),
        ),
      ),
    );
  }
}
