// EditIntraDayScreen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditLongTermScreen extends StatefulWidget {
  final String documentId;

  const EditLongTermScreen({Key? key, required this.documentId})
      : super(key: key);

  @override
  _EditLongTermScreenState createState() => _EditLongTermScreenState();
}

class _EditLongTermScreenState extends State<EditLongTermScreen> {
  TextEditingController stockNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController cmpController = TextEditingController();
  TextEditingController targetController = TextEditingController();
  TextEditingController slController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<String> categories = ['IntraDay', 'ShortTerm', 'LongTerm'];
  List<String> statusOptions = ['Active', 'Achieved', 'SL Hit'];

  DateTime? selectedDate;

  bool isLoading = false; // Added loading indicator state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Stocks')
          .doc(widget.documentId)
          .get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      stockNameController.text = data['stockName'];
      categoryController.text = data['category'];
      statusController.text = data['status'];
      cmpController.text = data['cmp'];
      targetController.text = data['target'];
      slController.text = data['sl'];
      remarkController.text = data['remark'];

      // Handle the 'date' field correctly
      if (data['date'] is String) {
        // If it's a String, parse it as a DateTime
        selectedDate = DateTime.parse(data['date']);
        dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      } else if (data['date'] is Timestamp) {
        // If it's a Timestamp, convert it to a DateTime
        Timestamp timestamp = data['date'] as Timestamp;
        selectedDate = timestamp.toDate();
        dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      }

      setState(() {
        isLoading = false;
      }); // Update the state to reflect changes
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Check if any of the required fields are empty after trimming whitespace
      if (stockNameController.text.trim().isEmpty ||
          categoryController.text.trim().isEmpty ||
          statusController.text.trim().isEmpty ||
          cmpController.text.trim().isEmpty ||
          targetController.text.trim().isEmpty ||
          slController.text.trim().isEmpty ||
          remarkController.text.trim().isEmpty ||
          selectedDate == null) {
        // Show an error message if any of the required fields are empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Proceed with the update if all required fields are filled
      await FirebaseFirestore.instance
          .collection('Stocks')
          .doc(widget.documentId)
          .update({
        'stockName': stockNameController.text,
        'category': categoryController.text,
        'status': statusController.text,
        'cmp': cmpController.text,
        'target': targetController.text,
        'sl': slController.text,
        'remark': remarkController.text,
        'date': selectedDate,
      });

      // Fetch updated data after the update is successful
      await _fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context); // Go back to the previous screen after updating
    } catch (e) {
      print('Error updating data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit LongTerm',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: categoryController.text.isNotEmpty
                  ? categoryController.text
                  : null,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  categoryController.text = value ?? '';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: statusController.text.isNotEmpty
                  ? statusController.text
                  : null,
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  statusController.text = value ?? '';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: stockNameController,
              decoration: InputDecoration(
                labelText: 'Stock Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: cmpController,
              decoration: InputDecoration(
                labelText: 'CMP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: slController,
              decoration: InputDecoration(
                labelText: 'SL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: remarkController,
              decoration: InputDecoration(
                labelText: 'Remark',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                labelText: 'Date',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () => selectDate(context),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateData,
              style: ElevatedButton.styleFrom(
                backgroundColor: CupertinoColors.systemBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Update!',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
