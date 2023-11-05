import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:groceries/models/category.dart';
import 'package:groceries/models/grocery_item.dart';
import 'package:groceries/screens/new_item_screen.dart';
import 'package:http/http.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> _data = [];

  bool _isLoading = true;
  String? _error = null;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItemScreen()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _data.add(newItem);
    });
  }

  void _fetchData() async {
    final url = Uri.https(
      "flutter-backend-training-default-rtdb.europe-west1.firebasedatabase.app",
      "shopping-list.json",
    );
    try {
      final response = await get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to load data";
          _isLoading = false;
        });
        return;
      }
      if (response.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = jsonDecode(response.body);
      final List<GroceryItem> loadedItems = [];
      listData.forEach((key, value) {
        final categoryName = value["category"]!;
        final category = categories.values
            .firstWhere((element) => element.name == categoryName);
        final item = GroceryItem(
          id: key,
          name: value["name"] as String,
          quantity: value["quantity"] as int,
          category: category,
        );
        loadedItems.add(item);
      });
      setState(() {
        _data = loadedItems;
        _isLoading = false;
        _error = null;
      });
    }catch(error){
      setState(() {
        _isLoading = false;
        _error = "Something went wrong";
      });
    }
  }

  void _removeItem(GroceryItem item) async {
    final index = _data.indexOf(item);
    final url = Uri.https(
      "flutter-backend-training-default-rtdb.europe-west1.firebasedatabase.app",
      "shopping-list/${item.id}.json",
    );
    setState(() {
      _data.remove(item);
    });
    final response = await delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _data.insert(index, item);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No Items added yet"));
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
    if (_data.isNotEmpty) {
      content = ListView.builder(
          itemCount: _data.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(_data[index]),
              onDismissed: (item) {
                _removeItem(_data[index]);
              },
              child: ListTile(
                title: Text(_data[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _data[index].category.color,
                ),
                trailing: Text(_data[index].quantity.toString()),
              ),
            );
          });
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your groceries"),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
