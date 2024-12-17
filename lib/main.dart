import 'package:flutter/material.dart';
import 'SigninUp.dart';
import 'add_medicine_page.dart';
import 'notifications.dart';
import 'info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCtNpy2yqTk_Be5xupWT13-ULdB-P4rz48',
      appId: '1:267835984026:android:f9c520c00615897e18f723',
      messagingSenderId: '267835984026',
      projectId: 'ppedetection-58cab',
    ),
  );
  runApp(MedicationReminderApp());
}

class MedicationReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medication Reminder',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[850],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.teal, fontSize: 20),
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? SignInUpPage()
          : HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> medicines = [];
  String searchQuery = '';

  void _addOrUpdateMedicine(Map<String, dynamic>? medicine, int? index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(medicine: medicine),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          medicines[index] = result;
        } else {
          medicines.add(result);
        }
      });
    }
  }

  void _deleteMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInUpPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMedicines = medicines
        .where((medicine) =>
            medicine['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Reminder'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(medicines: medicines),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Medicines',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          filteredMedicines.isEmpty
              ? Center(
                  child: Text(
                    'No medicines found!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = filteredMedicines[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.medication, color: Colors.teal),
                          title: Text(
                            medicine['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date: ${medicine['startDate']}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              if (medicine['duration'] != null)
                                Text(
                                  'Duration: ${medicine['duration']} days',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              Text(
                                'Dosage: ${medicine['doses']} times/day',
                                style: TextStyle(color: Colors.white70),
                              ),
                              if (medicine['times'] != null &&
                                  medicine['times'].isNotEmpty)
                                Text(
                                  'Times: ${medicine['times'].join(', ')}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _addOrUpdateMedicine(medicine, index);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteMedicine(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrUpdateMedicine(null, null);
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
