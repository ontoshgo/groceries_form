import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:groceries/models/category.dart';
import 'package:groceries/models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() {
    return _NewItemScreenState();
  }
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isSending = false;

  String _enteredName = "";
  int _enteredQuantity = 0;
  Category _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
        "flutter-backend-training-default-rtdb.europe-west1.firebasedatabase.app",
        "shopping-list.json",
      );
      try {
        final response = await http.post(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: json.encode({
              "name": _enteredName,
              "quantity": _enteredQuantity,
              "category": _selectedCategory.name
            }));
        if (!context.mounted) {
          return;
        }
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);

        final newItem = GroceryItem(
            id: decodedResponse["name"],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory);
        Navigator.of(context).pop(newItem);
      } catch (error) {
        //retry or handle an error somehow
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add new item")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1) {
                    return "Must be between 2 and 50 characters long";
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value == null) {
                    return;
                  }
                  _enteredName = value;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(label: Text("Quantity")),
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be between a valid, positive number";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value == null) {
                          return;
                        }
                        _enteredQuantity = int.tryParse(value)!;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.name),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending ? null : _reset,
                      child: const Text("Reset")),
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Add item"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
