import 'package:flutter/material.dart';

class SearchIndividualsPage extends StatelessWidget {
  const SearchIndividualsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Individuals')),
      body: const Center(child: Text('Search Individuals Page')),
    );
  }
}