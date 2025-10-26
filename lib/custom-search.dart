import 'package:ecommerce_app/product-detail.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<dynamic> products;
  CustomSearchDelegate({required this.products});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> match = [];
    for (var product in products) {
      if (product['title'].toLowerCase().contains(query.toLowerCase())) {
        match.add(product);
      }
    }

    return ListView.builder(
      itemCount: match.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            close(context, null);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetail(item: match[index]),
              ),
            );
          },
          title: Text(match[index]['title']),
          style: ListTileStyle.list,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> match = [];
    for (var product in products) {
      if (product['title'].toLowerCase().contains(query.toLowerCase())) {
        match.add(product);
      }
    }

    return ListView.builder(
      itemCount: match.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(match[index]['title']),
          onTap: () {
            close(context, null);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetail(item: match[index]),
              ),
            );
          },
        );
      },
    );
  }
}
