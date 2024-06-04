import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddData extends StatefulWidget {
  const AddData({super.key});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  String? selectedOption;
  String? selectedStatus;
  DateTime? selectedDate;
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController stockNameController = TextEditingController();
  TextEditingController cmpController = TextEditingController();
  TextEditingController targetController = TextEditingController();
  TextEditingController slController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _addToFirestore() async {
    if (_validateFields()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Check if the stock name is already present in the selected category
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('Stocks')
            .where('category', isEqualTo: selectedOption)
            .where('stockName',
                isEqualTo: stockNameController.text.trim()) // Apply trim here
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Stock name already exists in the selected category, show a Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Stock name already exists in the selected category.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Convert selectedDate to a formatted string
          String formattedDate =
              selectedDate!.toLocal().toString().split(' ')[0];

          // Stock name is unique in the selected category, proceed to add data
          await _firestore.collection('Stocks').add({
            'category': selectedOption,
            'status': selectedStatus,
            'stockName': stockNameController.text.trim(), // Apply trim here
            'cmp': cmpController.text.trim(), // Apply trim here
            'target': targetController.text.trim(), // Apply trim here
            'sl': slController.text.trim(), // Apply trim here
            'remark': remarkController.text.trim(), // Apply trim here
            'date': formattedDate, // Store date as string
          });

          // Reset values after successful data addition
          setState(() {
            selectedOption = null;
            selectedStatus = null;
            selectedDate = null;
            stockNameController.clear();
            cmpController.clear();
            targetController.clear();
            slController.clear();
            remarkController.clear();
          });

          // Show success message in Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data added to Firestore successfully!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Handle errors
        print('Error adding data to Firestore: $e');

        // Show error message in Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add data to Firestore. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Show a Snackbar when fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  bool _validateFields() {
    return selectedOption != null &&
        selectedStatus != null &&
        stockNameController.text.trim().isNotEmpty &&
        cmpController.text.trim().isNotEmpty &&
        targetController.text.trim().isNotEmpty &&
        slController.text.trim().isNotEmpty &&
        remarkController.text.trim().isNotEmpty &&
        selectedDate != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Stocks",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOption = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: <String?>[null, 'IntraDay', 'ShortTerm', 'LongTerm']
                        .map((String? option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option ?? 'Category'),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: <String?>[
                      null,
                      'Active',
                      'Achieved',
                      'SL Hit',
                    ].map((String? option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option ?? 'Status'),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    controller: stockNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      labelText: "Stock Name",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    controller: cmpController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      labelText: "CMP",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    controller: targetController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      labelText: "Target",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    controller: slController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      labelText: "SL",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    controller: remarkController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      labelText: "Remark",
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                    controller: TextEditingController(
                      text: selectedDate == null
                          ? ''
                          : 'Selected Date: ${selectedDate!.toString().substring(0, 10)}',
                    ),
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _addToFirestore();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: CupertinoColors.systemBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Add To Firestore!",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
