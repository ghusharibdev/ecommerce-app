import 'package:ecommerce_app/user-info.dart';
import 'package:flutter/material.dart';

class CashOnDelivery extends StatelessWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> orderedItems;

  const CashOnDelivery({
    super.key,
    required this.totalAmount,
    required this.orderedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash on Delivery"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text("Order Summary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: orderedItems.length,
                itemBuilder: (context, index) {
                  final item = orderedItems[index];
                  return ListTile(
                    title: Text(item['title']),
                    subtitle: Text('Qty: ${item['quantity']}'),
                    trailing: Text(
                        'PKR ${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Text('Total: PKR ${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserInfoScreen(
                      totalAmount: totalAmount,
                      orderedItems: orderedItems,
                    ),
                  ),
                );
              },
              child: const Text("Proceed to Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}
