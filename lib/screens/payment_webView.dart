import 'package:flutter/material.dart';
import 'package:parking_system/services/payment_poller.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/auth_provider.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  final int id;

  const PaymentWebView({super.key, required this.paymentUrl, required this.id});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => _isLoading = true),
              onPageFinished: (_) {
                setState(() => _isLoading = false);
              },
              onNavigationRequest: (nav) {
                final url = nav.url;
                if (url.contains("status=successful") ||
                    url.contains("success=true")) {
                  Navigator.pop(context, true);
                  return NavigationDecision.prevent;
                } else if (url.contains("status=cancelled")) {
                  Navigator.pop(context, false);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Payment")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
