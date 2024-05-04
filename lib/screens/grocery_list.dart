import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_grocery_item.dart';

final List<GroceryItem> allGroceries = groceryItems;

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  void _addGroceryItem() async {
    GroceryItem newGrocery = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewGroceryItem(),
      ),
    );
    if (newGrocery == null) {
      return;
    }
    setState(() {
      allGroceries.add(newGrocery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
              onPressed: _addGroceryItem,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: ListView.builder(
          itemCount: allGroceries.length,
          itemBuilder: (ctx, index) {
            return Dismissible(
              key: ValueKey(allGroceries[index]),
              onDismissed: (direction) {
                GroceryItem removedGrocery = allGroceries[index];
                setState(() {
                  allGroceries.remove(allGroceries[index]);
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("grocery removed"),
                    action: SnackBarAction(
                      label: "undo",
                      onPressed: () => {
                        setState(() {
                          allGroceries.insert(index, removedGrocery);
                        })
                      },
                    ),
                  ),
                );
              },
              child: ListTile(
                title: Text(allGroceries[index].name),
                leading: ColoredBox(
                  color: allGroceries[index].category.color,
                  child: const SizedBox(
                    height: 24,
                    width: 24,
                  ),
                ),
                trailing: Text(allGroceries[index].quantity.toString()),
              ),
            );

            //Grocery(groceryItem: allGroceries[index]);
          },
        ));
  }
}
