import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndManualPage extends StatelessWidget {
  const HelpAndManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Manual"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Welcome to the House Booking Assistant AI!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "This assistant helps you find, book, and manage house rentals easily. Below are some frequently asked questions to guide you.",
            ),
            SizedBox(height: 20),
            Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            FAQItem(
              question: "How do I book a house?",
              answer:
                  "You can book a house by selecting its image or typing its name. Payment must be made via M-Pesa or Flutterwave before the house is confirmed as booked.",
            ),
            FAQItem(
              question: "What happens if I don't complete my payment?",
              answer:
                  "Your booking will not be confirmed until payment is received. The house will still be available for others to book.",
            ),
            FAQItem(
              question: "Can I cancel a booking?",
              answer:
                  "Yes, you can cancel your booking before the move-in date. This will reset the house's availability.",
            ),
            FAQItem(
              question: "How do I make a payment?",
              answer:
                  "Payments are made via M-Pesa STK Push or Flutterwave. You'll receive a payment request on your phone to complete the transaction.",
            ),
            FAQItem(
              question: "What if I encounter an issue?",
              answer: "You can contact support using the options below.",
            ),
            SizedBox(height: 20),
            ContactSupport(),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
            title: Text(widget.question,
            style: TextStyle(fontWeight: FontWeight.bold)),
        expandedAlignment: Alignment.centerRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                widget.answer,

            ),
          ),
        ],
      ),
    );
  }
}

class ContactSupport extends StatefulWidget {
  const ContactSupport({super.key});

  @override
  State<ContactSupport> createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupport> {
  bool isExpanded = false;

  final List<Map<String, String>> supportContacts = [
    {
      "name": "Nick Dieda",
      "phone": "+254700742362",
      "email": "nickeagle888@gmail.com"
    },

  ];

  // Function to launch a phone call
  void _callSupport(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    await launchUrl(callUri);
  }


  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=House Booking Assistant Support&body=Describe your issue here...',
    );

    await launchUrl(emailUri);
  }

  void _sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);

    await launchUrl(smsUri);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text("Contact Support",
            style: TextStyle(fontWeight: FontWeight.bold)),
        children: supportContacts.map((contact) {
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text(contact["name"]!),
              ),
              ListTile(
                leading: Icon(Icons.call, color: Colors.green),
                title: Text("Call ${contact['name']}"),
                onTap: () => _callSupport(contact["phone"]!),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text("Send Email to ${contact['name']}"),
                onTap: () => _sendEmail(contact["email"]!),
              ),
              ListTile(
                leading: Icon(Icons.sms, color: Colors.orange),
                title: Text("Send SMS to ${contact['name']}"),
                onTap: () => _sendSMS(contact["phone"]!),
              ),
              Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
