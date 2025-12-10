import 'package:moonbnd/data_models/all_space_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpaceDetailWebView extends StatefulWidget {
  final String url;

  SpaceDetailWebView({required this.url});

  @override
  State<SpaceDetailWebView> createState() => _SpaceDetailWebViewState();
}

class _SpaceDetailWebViewState extends State<SpaceDetailWebView> {
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
        title: Text("Space Details".tr),
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
