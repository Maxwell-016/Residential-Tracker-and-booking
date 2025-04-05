import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddIndividualsPage extends StatefulWidget {
  const AddIndividualsPage({super.key});

  @override
  State<AddIndividualsPage> createState() => _AddIndividualsPageState();
}

class _AddIndividualsPageState extends State<AddIndividualsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'Student'; // Default role
  bool _isAdmin = false; // Checkbox for special privileges
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addIndividual() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare user data
        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _isAdmin ? 'Admin' : _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        await _firestore.collection('Users').add(userData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully!')),
        );

        // Clear the form
        _nameController.clear();
        _emailController.clear();
        setState(() {
          _selectedRole = 'Student';
          _isAdmin = false;
        });
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add user: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Individuals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                  DropdownMenuItem(value: 'Landlord', child: Text('Landlord')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Grant Admin Privileges'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addIndividual,
                      child: const Text('Add Individual'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}