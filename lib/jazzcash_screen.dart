import 'package:ecommerce_app/user-info.dart';
import 'package:flutter/material.dart';

class JazzCashScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> orderedItems;

  const JazzCashScreen({
    super.key,
    required this.totalAmount,
    required this.orderedItems,
  });

  @override
  State<JazzCashScreen> createState() => _JazzCashScreenState();
}

class _JazzCashScreenState extends State<JazzCashScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  void _processPayment() {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      _showSnack('Please fill in all fields.');
      return;
    }

    if (phone.length != 11 || !phone.startsWith('03')) {
      _showSnack('Enter a valid JazzCash number.');
      return;
    }

    if (pin.length < 4 || pin.length > 6) {
      _showSnack('PIN must be 4–6 digits.');
      return;
    }

    _showSnack('Payment Successful 🎉');

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserInfoScreen(
            totalAmount: widget.totalAmount,
            orderedItems: widget.orderedItems,
          ),
        ),
      );
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JazzCash Payment'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/jazzcash.png', height: 100),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "JazzCash Mobile Number",
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: "PIN",
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _processPayment,
              child: const Text("Pay Now & Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}
