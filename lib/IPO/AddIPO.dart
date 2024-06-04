import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddIPO extends StatefulWidget {
  const AddIPO({Key? key}) : super(key: key);

  @override
  _AddIPOState createState() => _AddIPOState();
}

class _AddIPOState extends State<AddIPO> {
  DateTime? openingDate;
  DateTime? closingDate;
  bool isLoading = false;
  final TextEditingController openingDateController = TextEditingController();
  final TextEditingController closingDateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController stockNameController = TextEditingController();
  TextEditingController lotController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  String? selectedStatus; // Variable to store the selected status
  final List<String> statusOptions = ['All', 'Current', 'Upcoming'];

  String timestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy')
        .format(dateTime); // Change the format as needed
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isOpeningDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isOpeningDate
          ? openingDate ?? DateTime.now()
          : closingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null &&
        (isOpeningDate
            ? pickedDate != openingDate
            : pickedDate != closingDate)) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        if (isOpeningDate) {
          openingDate = pickedDate;
        } else {
          closingDate = pickedDate;
        }
      });
    }
  }

  Widget _buildDateInput(TextEditingController controller, bool isOpeningDate) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () {
        _selectDate(context, controller, isOpeningDate);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        labelText: isOpeningDate ? "Opening Date" : "Closing Date",
        suffixIcon: IconButton(
          onPressed: () {
            _selectDate(context, controller, isOpeningDate);
          },
          icon: const Icon(Icons.calendar_today),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // return isOpeningDate ? 'Please select an opening date' : 'Please select a closing date';
        }
        return null;
      },
    );
  }

  Future<void> _addToFirebase() async {
    if (_validateForm()) {
      setState(() {
        isLoading = true;
      });

      try {
        await _firestore.collection('IPO').add({
          'stockName': stockNameController.text.trim(),
          'lot': int.tryParse(lotController.text.trim()) ?? 0,
          'price': double.tryParse(priceController.text.trim()) ?? 0.0,
          'openingDate': openingDate != null
              ? timestampToString(Timestamp.fromDate(openingDate!))
              : null,
          'closingDate': closingDate != null
              ? timestampToString(Timestamp.fromDate(closingDate!))
              : null,
          'remark': remarkController.text.trim(),
          'status': selectedStatus ?? 'All',
        });

        _resetForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data added to Firestore successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error adding data to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add data to Firestore. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedStatus == null ||
          selectedStatus!.isEmpty ||
          stockNameController.text.trim().isEmpty ||
          lotController.text.trim().isEmpty ||
          priceController.text.trim().isEmpty ||
          remarkController.text.trim().isEmpty || // Ensure remarks is not empty
          openingDate == null ||
          closingDate == null) {
        _showSnackBar('Please fill in all the fields.');
        return false;
      }
      return true;
    } else {
      _showSnackBar('Please fill in all the required fields.');
      return false;
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    stockNameController.clear();
    lotController.clear();
    priceController.clear();
    openingDateController.clear();
    closingDateController.clear();
    remarkController.clear();
    openingDate = null;
    closingDate = null;
    selectedStatus = null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Adding IPO",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      labelText: "Status",
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
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
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
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      keyboardType: const TextInputType.numberWithOptions(),
                      controller: lotController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        labelText: "Lot",
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
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      keyboardType: const TextInputType.numberWithOptions(),
                      controller: priceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        labelText: "Price",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildDateInput(openingDateController, true),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildDateInput(closingDateController, false),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: TextFormField(
                      controller: remarkController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        labelText: "Remark",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        _addToFirebase();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Add To Firestore!",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
