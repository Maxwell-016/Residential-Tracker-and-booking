import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/Bar_graph.dart';

class GraphHome extends StatefulWidget {
  const GraphHome({super.key});

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SizedBox(
          height: 300,
          child: NewbarGraph(),
        ),
      ),
    );
  }
}
