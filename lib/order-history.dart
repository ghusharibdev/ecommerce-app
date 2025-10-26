import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your orders')),
      );
    }

    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots(); // ✅ Fetch only logged-in user orders

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found 🛒'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

              // ✅ Proper timestamp formatting
              String formattedDate = 'Unknown';
              try {
                if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
                  formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
                      .format((data['timestamp'] as Timestamp).toDate());
                }
              } catch (_) {}

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  title: Text(
                    'Order • Rs ${data['totalAmount']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Placed on $formattedDate'),
                  children: [
                    ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return ListTile(
                          leading: Image.asset(
                            item['image'] ?? 'assets/default.png',
                            width: 45,
                            height: 45,
                            fit: BoxFit.contain,
                          ),
                          title: Text(item['title'] ?? ''),
                          subtitle: Text(
                              'Qty: ${item['quantity']}  •  Rs ${item['price']}'),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
