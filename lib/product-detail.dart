import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<dynamic> cartItems = [];

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> item;
  const ProductDetail({super.key, required this.item});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Future<void> addToCart() async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cartRef = FirebaseFirestore.instance.collection('cart').doc(userId);

    final userDoc = await cartRef.get();

    List items = [];

    if (userDoc.exists && userDoc.data()!.containsKey('items')) {
      items = List.from(userDoc['items']);
    }

    bool itemExists = items.any((item) => item['id'] == widget.item['id']);

    if (itemExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item already in cart')),
      );
      return;
    }

    items.add({
      'id': widget.item['id'],
      'title': widget.item['title'],
      'price': widget.item['price'],
      'image': widget.item['image'],
      'quantity': 1,
    });

    await cartRef.set({'items': items}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item added to cart'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {});
  } catch (e) {
    print('Error adding to cart: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (builder) => ProductCart()));
              },
              icon: Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
        foregroundColor: Colors.white,
        title: Text('Product Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                widget.item['image'],
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.item['title'],
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "PKR ${widget.item['price']}",
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.category_outlined, size: 20),
                const SizedBox(width: 6),
                Text(
                  widget.item['category'].toString().toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 5),
                Text(
                  "${widget.item['rating']['rate']}  ",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                Text(
                  "(${widget.item['rating']['count']} reviews)",
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "Description",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item['description'],
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Add to Cart",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
