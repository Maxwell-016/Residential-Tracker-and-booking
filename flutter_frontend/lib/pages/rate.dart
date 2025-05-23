import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';




class RateUsPage extends ConsumerStatefulWidget {




  @override
  ConsumerState<RateUsPage> createState() => _RateUsPageState();
}

class _RateUsPageState extends ConsumerState<RateUsPage> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();


  void _submitFeedback() async {
    if (ref.watch(rateus) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a rating!")));
      return;
    }

    await FirebaseFirestore.instance.collection('feedback').add({
      'rating': ref.watch(rateus),
      'feedback': ref.watch(optionString),
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thank you for your feedback!")));



    ref.read(rateus.notifier).state=0;
    _feedbackController.text='';
    // ref.read(optionString.notifier).state="";


  }

  @override
  Widget build(BuildContext context) {
    // ref.read(optionString.notifier).state= _feedbackController.text;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("How would you rate your experience?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildStarRating(),
            SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: "Leave a comment (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text("Submit"),
              onPressed: _submitFeedback,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
            icon: Icon(
              Icons.star,
              size: 40,
              color: index < ref.watch(rateus) ? Colors.orange : Colors.grey,
            ),
            onPressed:() {
              ref
                  .read(rateus.notifier)
                  .state = index + 1;
            }
        );
      }),
    );
  }
}