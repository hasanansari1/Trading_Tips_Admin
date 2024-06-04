import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'EditShortTerm.dart';
import 'ShortTermModel.dart';

class ShortTermScreen extends StatefulWidget {
  const ShortTermScreen({Key? key}) : super(key: key);

  @override
  _ShortTermScreenState createState() => _ShortTermScreenState();
}

class _ShortTermScreenState extends State<ShortTermScreen> {
  // Function to delete data from Firestore
  Future<void> _deleteData(String documentId) async {
    await FirebaseFirestore.instance
        .collection('Stocks')
        .doc(documentId)
        .delete();
  }

  // Function to show a confirmation dialog
  Future<void> _showDeleteConfirmationDialog(String documentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Delete Stock?",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          content: const Text(
            "Are you sure you want to delete this stock?",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "No",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteData(documentId);
                Navigator.of(context).pop(); // Close the dialog
                Fluttertoast.showToast(
                  msg: "Data deleted successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> navigateToEditScreen(String documentId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditShortTermScreen(documentId: documentId),
      ),
    );

    // Reload data when returning from the edit screen
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Short Term Data',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Stocks')
            .where('category', isEqualTo: 'ShortTerm')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<ShortTermModel> shortTermData = snapshot.data!.docs.map((doc) {
            return ShortTermModel.fromSnapshot(doc);
          }).toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: shortTermData.length,
            itemBuilder: (context, index) {
              ShortTermModel data = shortTermData[index];
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(data.date.toDate());

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    data.stockName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${data.category}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Status: ${data.status}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'CMP: ${data.cmp}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Target: ${data.target}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'SL: ${data.sl}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Remark: ${data.remark}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Date: $formattedDate',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          navigateToEditScreen(data.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Show confirmation dialog before deletion
                          _showDeleteConfirmationDialog(data.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
