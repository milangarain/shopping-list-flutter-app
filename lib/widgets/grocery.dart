import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class Grocery extends StatelessWidget {
  const Grocery({super.key, required this.groceryItem});
  final GroceryItem groceryItem;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.all(16),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        // main
        children: [
          ColoredBox(
            color: groceryItem.category.color,
            child: const SizedBox(width: 24, height: 24),
          ),
          const SizedBox(
            width: 36,
          ),
          Text(groceryItem.name),
          const Spacer(),
          Text(groceryItem.quantity.toString()),
        ],
      ),
    );

    // Text(groceryItem.name);
  }
}
