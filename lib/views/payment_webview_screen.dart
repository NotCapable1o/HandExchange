import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

import 'card_payment_screen.dart';
import 'mobile_banking_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final double amount;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.amount,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() => _loading = false);
          if (message.message == 'card_clicked') {
            _redirectToCustom('card');
          } else if (message.message == 'mfs_clicked') {
            _redirectToCustom('mfs');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url.contains("payment_page.php") ||
                url.contains("process.php")) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (url) {
            setState(() => _loading = false);
            _controller.runJavaScript("""
              document.addEventListener('click', function(e) {
                var target = e.target.closest('a, button, div');
                if(!target) return;
                var text = (target.innerText || "").toLowerCase();
                var html = (target.innerHTML || "").toLowerCase();
                if(html.includes('visa') || html.includes('master') || text.includes('card')) {
                  FlutterPayment.postMessage('card_clicked');
                } else if(html.includes('bkash') || html.includes('nagad') || html.includes('rocket')) {
                  FlutterPayment.postMessage('mfs_clicked');
                }
              });
            """);
          },
          onWebResourceError: (error) {
            setState(() => _loading = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url.toLowerCase();

            if (url.contains('visa') ||
                url.contains('master') ||
                url.contains('paynow.php')) {
              setState(() => _loading = false);
              _redirectToCustom('card');
              return NavigationDecision.prevent;
            }

            if (url.contains('bkash') ||
                url.contains('nagad') ||
                url.contains('rocket')) {
              setState(() => _loading = false);
              _redirectToCustom('mfs');
              return NavigationDecision.prevent;
            }

            if (url.contains('success')) {
              Get.back(result: 'success');
              return NavigationDecision.prevent;
            }

            if (url.contains('fail') || url.contains('cancel')) {
              Get.back(result: 'cancel');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _redirectToCustom(String type) async {
    dynamic result;
    if (type == 'card') {
      result = await Get.to(() => CardPaymentScreen(amount: widget.amount));
    } else {
      result = await Get.to(
        () => MobileBankingScreen(
          method: "Mobile Banking",
          amount: widget.amount,
        ),
      );
    }

    if (result == 'success') {
      Get.back(result: 'success');
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AamarPay Gateway"), centerTitle: true),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
