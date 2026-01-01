import 'package:albaqer_gemstone_flutter/models/product.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [SizedBox(height: 50), Text('Cart Screen')]);
  }
}
