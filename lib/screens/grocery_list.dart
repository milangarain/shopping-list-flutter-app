import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  List<GroceryItem> _allGroceries = [];
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadGroceries();
  }

  void _loadGroceries() async {
    print("API triggered");
    final Uri url = Uri.https(
      'flutter-prep-925fb-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    http.Response response;
    try {
      response = await http.get(url);
    } catch (error) {
      _error = "Something went wrong.";
      return;
    }
    print(response.statusCode);
    if (response.statusCode >= 400) {
      setState(() {
        _isLoading = false;
        _error =
            "Error occured while retriving shopping list.\nTry again later.";
      });
      return;
    }
    if (response.body == 'null') {
      return;
    }
    final Map<String, dynamic> respData = jsonDecode(response.body);
    print(respData);

    final retrievedGroceries = [
      for (final groceryItem in respData.entries)
        GroceryItem(
          id: groceryItem.key,
          name: groceryItem.value['name'],
          quantity: groceryItem.value['quantity'],
          category: categories.entries
              .firstWhere(
                (cat) => cat.value.name == groceryItem.value['category'],
              )
              .value,
        )
    ];
    setState(() {
      _allGroceries = retrievedGroceries;
      _isLoading = false;
    });
  }

  void _addGroceryItem() async {
    GroceryItem? newGrocery = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewGroceryItem(),
      ),
    );
    if (newGrocery == null) {
      return;
    }
    //_loadGroceries();
    setState(() {
      _allGroceries.add(newGrocery);
    });
  }

  void _addRemovedItem(String error, int index, GroceryItem removedGrocery) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("failed to remove the item"),
      duration: Duration(seconds: 2),
    ));
    setState(() {
      _allGroceries.insert(index, removedGrocery);
    });
  }

  void _onDismissed(index) async {
    GroceryItem removedGrocery = _allGroceries[index];
    setState(() {
      _allGroceries.remove(removedGrocery);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("grocery removed"),
        duration: Duration(seconds: 2),
        // action: SnackBarAction(
        //   label: "undo",
        //   onPressed: () => {
        //     setState(() {
        //       _allGroceries.insert(index, removedGrocery);
        //     })
        //   },
        // ),
      ),
    );
    final Uri url = Uri.https(
      'flutter-prep-925fb-default-rtdb.firebaseio.com',
      'shopping-list/${removedGrocery.id}.json',
    );
    http.Response response;
    try {
      response = await http.delete(url);
    } catch (error) {
      _addRemovedItem("Something went wrong", index, removedGrocery);
      return;
    }
    if (response.statusCode >= 400) {
      _addRemovedItem("Unable to remove the item", index, removedGrocery);
    }

    // var subscription = Future.delayed(const Duration(seconds: 2), () async {
    //   final response = await http.delete(url);
    //   if (response.statusCode >= 400) {
    //     _allGroceries.insert(index, removedGrocery);
    //   }
    // });
    // subscription.ignore();
    // subscription;
    // final response = await http.delete(url);
    // if (response.statusCode >= 400) {
    //   _allGroceries.insert(index, removedGrocery);
    // }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("You have not selected any shipping list."),
    );
    if (_allGroceries.isNotEmpty) {
      content = ListView.builder(
        itemCount: _allGroceries.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(_allGroceries[index]),
            onDismissed: (direction) {
              _onDismissed(index);
            },
            child: ListTile(
              title: Text(_allGroceries[index].name),
              leading: ColoredBox(
                color: _allGroceries[index].category.color,
                child: const SizedBox(
                  height: 24,
                  width: 24,
                ),
              ),
              trailing: Text(_allGroceries[index].quantity.toString()),
            ),
          );
          //Grocery(groceryItem: _allGroceries[index]);
        },
      );
    }
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
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
      body: content,
    );
  }
}
