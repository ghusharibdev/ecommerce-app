import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class ProductCard extends StatelessWidget {
  final String imgUrl;
  final String productName;
  final double productPrice;
  final double rating;
  final num noOfReviews;

  const ProductCard({
    super.key,
    required this.imgUrl,
    required this.productName,
    required this.productPrice,
    required this.rating,
    required this.noOfReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 50,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Center(
                child: Image.asset(
                  imgUrl,
                  fit: BoxFit.contain,
                  height: 110,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),

            const SizedBox(height: 7),

            Expanded(
              flex: 3,
              child: Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'PKR ${productPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 4),

            RatingStars(
              value: rating,
              starCount: 5,
              starSize: 16,
              starColor: const Color.fromRGBO(255, 184, 0, 1),
              starSpacing: 2,
              valueLabelVisibility: true,
              maxValue: 5,
              animationDuration: const Duration(milliseconds: 600),
            ),

            const SizedBox(height: 2),

            Text(
              '(${noOfReviews.toInt()} reviews)',
              style: const TextStyle(
                fontSize: 11,
                color: Color.fromARGB(255, 105, 105, 105),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
