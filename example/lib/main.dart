import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:accessible_grouped_list/accessible_grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/product.dart';

const loadingSliver = [
  SliverFillRemaining(
    child: CircularProgressIndicator.adaptive(),
  ),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessible Grouped List Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Accessible Grouped List Demo Home Page'),
    );
  }
}

final productsProvider =
    FutureProvider.family<List<Product>, BuildContext>((ref, context) async {
  String data =
      await DefaultAssetBundle.of(context).loadString("assets/products.json");
  final List<dynamic> jsonList = jsonDecode(data)['products'];
  return jsonList.map((json) => Product.fromJson(json)).toList();
});

extension StringExtension on String {
  String titleize() => split(' ')
      .map((section) => section[0].toUpperCase() + section.substring(1))
      .join(' ');
}

class MyHomePage extends ConsumerWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final _scrollController = ScrollController();
  final _scrollKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: AccessibleGroupedList(
        scrollController: _scrollController,
        scrollKey: _scrollKey,
        slivers: productsAsync.when(
          data: (products) {
            return groupBy(products, (product) => product.category)
                .entries
                .mapIndexed((index, entry) => AccessibleListGroup(
                      groupIndex: index,
                      group: entry.key,
                      items: entry.value,
                      groupTitle: (category) => category.titleize(),
                      itemTitle: (product) => product.title,
                      scrollController: _scrollController,
                      scrollKey: _scrollKey,
                    ))
                .toList();
          },
          error: (err, stack) => [Text(err.toString()), Text(stack.toString())],
          loading: () => loadingSliver,
        ),
      ),
    );
  }
}
