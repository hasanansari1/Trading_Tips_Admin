import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGuidelinesScreen extends StatefulWidget {
  const AddGuidelinesScreen({super.key});

  @override
  _AddGuidelinesScreenState createState() => _AddGuidelinesScreenState();
}

class _AddGuidelinesScreenState extends State<AddGuidelinesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _headingsController = TextEditingController();
  final TextEditingController _guidelinesController = TextEditingController();
  final TextEditingController _contactUsController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guidelines Form',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _headingsController,
                  decoration: InputDecoration(
                      labelText: 'Headings',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter headings';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _guidelinesController,
                  maxLines: 6,
                  decoration: InputDecoration(
                      labelText: 'Guidelines',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter guidelines';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLines: 2,
                  controller: _contactUsController,
                  decoration: InputDecoration(
                      labelText: 'Contact us',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter guidelines';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadData,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: CupertinoColors.systemBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Upload Guidelines!',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _uploadData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Trim the data before uploading
      String headings = _headingsController.text.trim();
      String guidelines = _guidelinesController.text.trim();
      String contactUs = _contactUsController.text.trim();

      // Upload data to Firebase
      await FirebaseFirestore.instance.collection('Guidelines').add({
        'headings': headings,
        'guidelines': guidelines,
        'contactUs': contactUs,
      });

      setState(() {
        _isLoading = false;
      });

      // Clear the text fields after successful upload
      _headingsController.clear();
      _guidelinesController.clear();
      _contactUsController.clear();

      // Display a success message or navigate to another screen if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data uploaded successfully'),
        ),
      );
    }
  }
}
