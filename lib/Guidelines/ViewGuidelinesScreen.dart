import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewGuidelinesScreen extends StatelessWidget {
  const ViewGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Guidelines',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Guidelines').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No guidelines available'),
            );
          } else {
            // Extracting data from Firestore
            List<DocumentSnapshot> guidelines = snapshot.data!.docs;

            // Sorting guidelines by headings
            guidelines.sort((a, b) => a['headings'].compareTo(b['headings']));

            return ListView.builder(
              itemCount: guidelines.length,
              itemBuilder: (context, index) {
                // Extracting individual guideline data
                String headings = guidelines[index]['headings'];
                String guideline = guidelines[index]['guidelines'];
                String contactUs = guidelines[index]['contactUs'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        headings,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      title: Text(guideline),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    ListTile(
                      title: Text(contactUs),
                    ),
                    const ListTile(
                      title: Text(
                        "equitystar@gmail.com",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const Divider(), // Add a divider between each set of guidelines
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
