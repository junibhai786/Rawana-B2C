import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TourDetailWebView extends StatefulWidget {
  final String url;

  TourDetailWebView({required this.url});

  @override
  State<TourDetailWebView> createState() => _TourDetailWebViewState();
}

class _TourDetailWebViewState extends State<TourDetailWebView> {
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
        title: Text("Tour Details"),
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
