import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/cash-on-delivery.dart';
import 'package:ecommerce_app/jazzcash_screen.dart';
import 'package:flutter/material.dart';

class ProductCart extends StatefulWidget {
  const ProductCart({super.key});

  @override
  State<ProductCart> createState() => _ProductCartState();
}

class _ProductCartState extends State<ProductCart> {
  List<Map<String, dynamic>> cart = [];
  double _subTotal = 0.0;
  late Future<void> _cartFuture;

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final cartRef = FirebaseFirestore.instance.collection('cart');

  Future<void> fetchItems() async {
    final doc = await cartRef.doc(userId).get();

    if (doc.exists) {
      cart = List<Map<String, dynamic>>.from(doc['items']);
    } else {
      cart = [];
    }
    _calcSubtotal();
  }

  void _calcSubtotal() {
    double total = 0.0;
    for (var item in cart) {
      total += (item['price'] * item['quantity']);
    }
    setState(() => _subTotal = total);
  }

  @override
  void initState() {
    super.initState();
    _cartFuture = fetchItems();
  }

  Future<void> _updateQuantity(int index, int newQty) async {
    if (newQty > 0) {
      cart[index]['quantity'] = newQty;
    } else {
      cart.removeAt(index);
    }

    await cartRef.doc(userId).set({'items': cart}, SetOptions(merge: true));
    _calcSubtotal();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const shippingFee = 150.0;
    final total = _subTotal + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (cart.isEmpty) {
            return const Center(child: Text("Your cart is empty 🛒"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, i) {
                    final item = cart[i];
                    return ListTile(
                      leading: Image.asset(item['image'], width: 60),
                      title: Text(item['title'], maxLines: 2),
                      subtitle: Text(
                        'Rs ${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              item['quantity'] == 1
                                  ? Icons.delete_outline
                                  : Icons.remove,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _updateQuantity(i, item['quantity'] - 1),
                          ),
                          Text('${item['quantity']}'),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () =>
                                _updateQuantity(i, item['quantity'] + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    _summaryRow("Subtotal:", "Rs ${_subTotal.toStringAsFixed(0)}"),
                    _summaryRow("Shipping:", "Rs ${shippingFee.toStringAsFixed(0)}"),
                    const Divider(),
                    _summaryRow(
                      "Total:",
                      "Rs ${total.toStringAsFixed(0)}",
                      bold: true,
                    ),

                    const SizedBox(height: 15),

                    // JazzCash Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JazzCashScreen(
                              totalAmount: total,
                              orderedItems: cart,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text("Checkout with JazzCash", style: TextStyle(
                        color: Colors.white
                      ),),
                    ),

                    const SizedBox(height: 10),

                    // Cash on Delivery Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CashOnDelivery(
                              totalAmount: total,
                              orderedItems: cart,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text("Cash On Delivery", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
