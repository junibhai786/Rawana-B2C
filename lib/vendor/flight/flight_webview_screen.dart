import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FlightWebViewScreen extends StatefulWidget {
  final String url;
  final String appbartitle;

  FlightWebViewScreen({required this.url, required this.appbartitle});

  @override
  State<FlightWebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<FlightWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..loadRequest(Uri.parse(widget.url)); // Load the URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appbartitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller), // Use WebViewWidget
    );
  }
}
