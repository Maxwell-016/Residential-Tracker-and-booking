import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';
import 'package:flutter_frontend/security/hashPassword.dart'; // Import the hashPassword function

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class AddIndividualsPage extends StatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const AddIndividualsPage({
    super.key,
    required this.colorSelected,
    required this.changeTheme,
    required this.changeColor,
  });

  @override
  State<AddIndividualsPage> createState() => _AddIndividualsPageState();
}

class _AddIndividualsPageState extends State<AddIndividualsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Password controller
  String _selectedRole = 'Student'; // Default role
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if the user already exists
        final querySnapshot = await _firestore
            .collection('Users')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // User already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User already exists')),
          );
        } else {
          // Hash the password using the imported function
          final hashedPassword = hashPassword(_passwordController.text.trim());

          // Prepare user data
          final userData = {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRole,
            'password': hashedPassword, // Save the hashed password
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
          _passwordController.clear();
          setState(() {
            _selectedRole = 'Student';
          });
        }
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: 'Add Users',
        ),
      ),
      drawer: const AdminSideNav(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true, // Hide the password input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _addUser,
                        child: const Text('Add User'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}