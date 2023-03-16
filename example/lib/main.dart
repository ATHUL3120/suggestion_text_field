import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suggestion_input_field/suggestion_input_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suggestion Input Field',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Suggestion Input Field'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Customer? selectedCustomer;
  FutureOr<List<Customer>> fetchCustomerData(String filterText) async {
    ///list fetch from async task or non async task
    final List<Customer> customers = List.generate(20, (index) {
      final random = Random();
      final id = 'C${random.nextInt(10000)}';
      final name = 'Customer ${index + 1}';
      final mobile = '555-555-${random.nextInt(10000)}';
      return Customer(id: id, name: name, mobile: mobile);
    });

    /// return data with filter
    return customers
        .where((element) =>
            element.name.toLowerCase().contains(filterText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () => setState(() {
                        selectedCustomer = null;
                      }),
                  child: const Text('clear customer from out side')),
              TextButton(
                  onPressed: () => setState(() {
                        selectedCustomer = Customer(
                            id: "100",
                            name: "OutSide Customer",
                            mobile: "555-555-5555");
                      }),
                  child: const Text('set customer from out side')),
              SuggestionTextField<Customer>(
                value: selectedCustomer,
                suggestionFetch: (textEditingValue) =>
                    fetchCustomerData(textEditingValue.text),
                textFieldContent: TextFieldContent(label: 'Select Customer'),
                displayStringForOption: (option) => option.name,
                onSelected: (option) {
                  setState(() {
                    selectedCustomer = option;
                  });
                },
                onClose: () {
                  setState(() {
                    selectedCustomer = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String mobile;
  Customer({required this.id, required this.name, required this.mobile});
}
