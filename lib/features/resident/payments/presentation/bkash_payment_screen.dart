import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BkashPaymentScreen extends StatefulWidget {
  final String invoiceId;
  final double amount;

  const BkashPaymentScreen({super.key, required this.invoiceId, required this.amount});

  @override
  State<BkashPaymentScreen> createState() => _BkashPaymentScreenState();
}

class _BkashPaymentScreenState extends State<BkashPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    try {
      // 1. Create Payment
      final result = await FirebaseFunctions.instance.httpsCallable('bkashCreatePayment').call({
        'invoiceId': widget.invoiceId,
        'amount': widget.amount,
      });

      final bkashURL = result.data['bkashURL'] as String;
      // final paymentID = result.data['paymentID'] as String; // Stored in backend, but helpful debugging

      // 2. Load WebView
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              // Check for callbacks
              // bKash usually redirects to: callbackUrl?paymentID=...&status=...
              if (request.url.contains('payment/callback')) {
                _handleCallback(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(bkashURL));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initiate payment: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCallback(String url) async {
    final uri = Uri.parse(url);
    final status = uri.queryParameters['status'];
    final paymentID = uri.queryParameters['paymentID'];

    if (status == 'success' || status == 'completed') {
       _executePayment(paymentID!);
    } else if (status == 'failure') {
      Navigator.pop(context, 'Payment Failed');
    } else if (status == 'cancel') {
      Navigator.pop(context, 'Payment Cancelled');
    } else {
       // Unknown status
       Navigator.pop(context, 'Payment Error: $status');
    }
  }

  Future<void> _executePayment(String paymentID) async {
    setState(() => _isLoading = true);
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('bkashExecutePayment').call({
        'paymentID': paymentID,
      });
      
      if (result.data['success'] == true) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
           Navigator.pop(context, true); // Return true for success
         }
      } else {
         throw 'Execution failed';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: $e')));
        Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bKash Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : WebViewWidget(controller: _controller),
    );
  }
}
