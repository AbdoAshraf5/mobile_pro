import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> medicines;

  NotificationsPage({required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: medicines.isEmpty
          ? Center(
              child: Text(
                'No medication notifications!',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                final times = medicine['times'] as List<String>;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.teal),
                    title: Text(
                      medicine['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: times.map((time) {
                        return Text(
                          'Time: $time',
                          style: TextStyle(color: Colors.white70),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
