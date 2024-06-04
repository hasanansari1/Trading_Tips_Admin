import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditIPO extends StatefulWidget {
  final String documentId;

  const EditIPO({Key? key, required this.documentId}) : super(key: key);

  @override
  _EditIPOScreenState createState() => _EditIPOScreenState();
}

class _EditIPOScreenState extends State<EditIPO> {
  DateTime? selectedDate;
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
    );
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentSnapshot doc =
          await _firestore.collection('IPO').doc(widget.documentId).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      stockNameController.text = data['stockName'];
      lotController.text = data['lot'].toString();
      priceController.text = data['price'].toString();
      remarkController.text = data['remark'];
      selectedStatus = data['status'];

      // Handle the 'openingDate' field correctly
      var openingDateData = data['openingDate'];
      if (openingDateData is Timestamp) {
        openingDate = openingDateData.toDate();
        openingDateController.text =
            DateFormat('dd/MM/yyyy').format(openingDate!);
      } else if (openingDateData is String) {
        openingDate = DateFormat('dd/MM/yyyy').parseStrict(openingDateData);
        openingDateController.text =
            DateFormat('dd/MM/yyyy').format(openingDate!);
      }

      // Handle the 'closingDate' field correctly
      var closingDateData = data['closingDate'];
      if (closingDateData is Timestamp) {
        closingDate = closingDateData.toDate();
        closingDateController.text =
            DateFormat('dd/MM/yyyy').format(closingDate!);
      } else if (closingDateData is String) {
        closingDate = DateFormat('dd/MM/yyyy').parseStrict(closingDateData);
        closingDateController.text =
            DateFormat('dd/MM/yyyy').format(closingDate!);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Trim all text fields before checking for emptiness
      final trimmedStockName = stockNameController.text.trim();
      final trimmedLot = lotController.text.trim();
      final trimmedPrice = priceController.text.trim();
      final trimmedRemark = remarkController.text.trim();

      // Check if any required fields are empty after trimming whitespace
      if (trimmedStockName.isEmpty ||
          trimmedLot.isEmpty ||
          trimmedPrice.isEmpty ||
          trimmedRemark.isEmpty ||
          openingDate == null ||
          closingDate == null ||
          selectedStatus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Proceed with the update if all required fields are filled
      await _firestore.collection('IPO').doc(widget.documentId).update({
        'stockName': trimmedStockName,
        'lot': int.tryParse(trimmedLot) ?? 0,
        'price': double.tryParse(trimmedPrice) ?? 0.0,
        'openingDate': Timestamp.fromDate(openingDate!),
        'closingDate': Timestamp.fromDate(closingDate!),
        'remark': trimmedRemark,
        'status': selectedStatus!,
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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit IPO',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown menu button
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

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextFormField(
                controller: stockNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  labelText: "Stock Name",
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextFormField(
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

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextFormField(
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

            const SizedBox(height: 10),

            _buildDateInput(openingDateController, true),

            const SizedBox(height: 10),

            _buildDateInput(closingDateController, false),

            const SizedBox(height: 10),

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

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateData,
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
                        "Update Data",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
