import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewGroceryItem extends StatefulWidget {
  const NewGroceryItem({super.key});

  @override
  State<NewGroceryItem> createState() => _NewGroceryItemState();
}

class _NewGroceryItemState extends State<NewGroceryItem> {
  String? enteredGroceryName;
  int? enteredQuantity;
  Category selectedCategory = categories[Categories.vegetables]!;
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  void _addNewItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      // GroceryItem newGrocery = GroceryItem(
      //   id: DateTime.now().toString(),
      //   name: enteredGroceryName!,
      //   quantity: enteredQuantity!,
      //   category: selectedCategory,
      // );
      final Uri url = Uri.https(
          'flutter-prep-925fb-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'name': enteredGroceryName,
        'quantity': enteredQuantity,
        'category': selectedCategory.name,
      });
      http.Response response;
      try {
        response = await http.post(url, headers: headers, body: body);
      } catch (error) {
        //show snackbar
        print("error occered while adding item");
        print(error);
        return;
      } finally {
        setState(() {
          _isSending = false;
        });
      }
      if(response.statusCode >= 400) {
        //show snackbar
        print("API failed with status code ${response.statusCode}");
        return;
      }
      print(response.body);
      if (response.body == 'null') {
        return;
      }
      GroceryItem newGrocery = GroceryItem(
        id: jsonDecode(response.body)['name'],
        name: enteredGroceryName!,
        quantity: enteredQuantity!,
        category: selectedCategory,
      );
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(newGrocery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Grocery")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  // icon: Icon(Icons.local_grocery_store),
                  hintText: 'your grocery name?',
                  labelText: 'Name',
                ),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                  enteredGroceryName = value;
                },
                validator: (String? value) {
                  return (value == null ||
                          value.trim().length <= 1 ||
                          value.length > 50)
                      ? 'must be between 1 and 50 charecters.'
                      : null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return " must be valid, positive number.";
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.name)
                              ],
                            ),
                          ),
                      ],
                      onChanged: (Category? value) {
                        selectedCategory = value!;
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _addNewItem,
                    child: _isSending
                        ? const CircularProgressIndicator()
                        : const Text("Add Item"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
