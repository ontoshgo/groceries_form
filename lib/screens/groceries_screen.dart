import 'package:flutter/material.dart';
import 'package:groceries/models/grocery_item.dart';
import 'package:groceries/screens/new_item_screen.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  final List<GroceryItem> _data = [];

  void _addItem() async {
    final item = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItemScreen()));
    if (item != null) {
      setState(() {
        _data.add(item);
      });
    }
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _data.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No Items added yet"));
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
