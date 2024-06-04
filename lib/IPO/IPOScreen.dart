import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equitystar/IPO/IPOModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'EditIPOScreen.dart';

class IPOScreen extends StatefulWidget {
  const IPOScreen({Key? key}) : super(key: key);

  @override
  _IPOScreenState createState() => _IPOScreenState();
}

class _IPOScreenState extends State<IPOScreen> {
  Future<void> _deleteData(String documentId) async {
    await FirebaseFirestore.instance.collection('IPO').doc(documentId).delete();
  }

  Future<void> _showDeleteConfirmationDialog(String documentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Delete IPO?",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          content: const Text(
            "Are you sure you want to delete this IPO?",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'IPO Data',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('IPO').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<IPOModel> ipoData = snapshot.data!.docs.map((doc) {
            return IPOModel.fromSnapshot(doc);
          }).toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: ipoData.length,
            itemBuilder: (context, index) {
              IPOModel data = ipoData[index];
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
                      _buildSubtitleText('Status', data.status),
                      _buildSubtitleText('Lot', data.lot.toString()),
                      _buildSubtitleText('Price', data.price.toString()),
                      _buildSubtitleText('Opening Date', data.openingDate),
                      _buildSubtitleText('Closing Date', data.closingDate),
                      _buildSubtitleText('Remark', data.remark),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(Icons.edit, Colors.green, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditIPO(documentId: data.id),
                          ),
                        );
                      }),
                      _buildIconButton(Icons.delete, Colors.red, () {
                        _showDeleteConfirmationDialog(data.id);
                      }),
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

  Widget _buildSubtitleText(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(fontSize: 15),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
