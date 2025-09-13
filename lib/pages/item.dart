import 'package:facesoft/form/item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/model/item_model.dart';
import 'package:facesoft/providers/item_provider.dart';
import 'package:facesoft/style/app_style.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Items'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Item", style: AppTextStyles.primaryButton),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemPage()),
            );
          },
        ),
        body: Consumer<ItemProvider>(
          builder: (context, itemProvider, _) {
            if (itemProvider.isLoading && itemProvider.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (itemProvider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(itemProvider.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => itemProvider.fetchItems(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (itemProvider.items.isEmpty) {
              return const Center(
                child: Text('No items found. Pull down to refresh.'),
              );
            }
            return RefreshIndicator(
              onRefresh: () => itemProvider.fetchItems(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // Added bottom padding of 96 to accommodate the FAB
                itemCount: itemProvider.items.length,
                itemBuilder: (context, index) {
                  final item = itemProvider.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Price: ${item.price != null ? '₹${item.price}' : 'not defined'}'),
                                const SizedBox(height: 4),
                                Text('Quantity: ${item.quantity ?? 'not defined'}'),
                                const SizedBox(height: 4),
                                Text('Unit: ${(item.unit?.isNotEmpty ?? false) ? item.unit : 'not defined'}'),
                                const SizedBox(height: 4),
                                Text('Weight: ${item.weight ?? 'not defined'} ${item.weight != null ? 'kg' : ''}'),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItemPage(item: item),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[300]),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete Item"),
                                        content: const Text("Are you sure you want to delete this item?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              bool success = await Provider.of<ItemProvider>(context, listen: false)
                                                  .deleteItem(item.id.toString());
                                              if (mounted) {
                                                scaffoldMessengerKey.currentState?.showSnackBar(
                                                  SnackBar(
                                                    content: Text(success ? 'Item deleted successfully' : 'Failed to delete item'),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
