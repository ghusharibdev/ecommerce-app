import 'package:ecommerce_app/cart.dart';
import 'package:ecommerce_app/custom-search.dart';
import 'package:ecommerce_app/order-history.dart';
import 'package:ecommerce_app/product-card.dart';
import 'package:ecommerce_app/product-detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recase/recase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> categories = [];
  List<dynamic> products = [];
  String selectedCategory = 'All';

  Future<void> getDataFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('id')
          .get();

      setState(() {
        products.clear();

        for (var doc in snapshot.docs) {
          var data = doc.data();

          // Convert price to PKR and double
          if (data['price'] != null && data['price'] is num) {
            data['price'] = (data['price'] * 280).toDouble();
          }

          // Convert rating fields to double
          if (data['rating'] != null) {
            if (data['rating']['rate'] != null) {
              data['rating']['rate'] =
                  (data['rating']['rate'] as num).toDouble();
            }
            if (data['rating']['count'] != null) {
              data['rating']['count'] =
                  (data['rating']['count'] as num).toDouble();
            }
          }

          products.add(data);
        }

        categories = [
          'All',
          ...products.map((product) {
            return ReCase(product['category'].toString()).titleCase;
          }).toSet(),
        ];
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final categorizeProducts = selectedCategory == 'All'
        ? products
        : products
            .where(
              (item) =>
                  item['category'].toString().toLowerCase() ==
                  selectedCategory.toLowerCase(),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopify", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cart')
                .where(
                  'userId',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              int cartCount = 0;
              if (snapshot.hasData) {
                cartCount = snapshot.data!.docs.length;
              }

              return IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductCart()),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(products: products),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Home',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logout Successful"),
                    duration: Duration(milliseconds: 1100),
                    backgroundColor: Color.fromARGB(255, 0, 82, 3),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      "Products",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 3.0,
                            right: 3,
                            bottom: 5,
                          ),
                          child: ChoiceChip(
                            label: Text(
                              category,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(fontSize: 13),
                            ),
                            selected: selectedCategory == category,
                            onSelected: (v) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor:
                                const Color.fromARGB(255, 105, 105, 105),
                            showCheckmark: false,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Expanded(
                    child: GridView.builder(
                      itemCount: categorizeProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 0.83,
                      ),
                      itemBuilder: (context, index) {
                        final item = categorizeProducts[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) =>
                                    ProductDetail(item: item),
                              ),
                            );
                          },
                          child: ProductCard(
                            imgUrl: item["image"],
                            productName: item['title'],
                            productPrice: item['price'],
                            rating: item['rating']['rate'],
                            noOfReviews: item['rating']['count'],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
