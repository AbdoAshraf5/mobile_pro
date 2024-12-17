import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _drugInfo;
  String? _errorMessage;

  Future<void> _fetchDrugInfo(String drugName) async {
    setState(() {
      _isLoading = true;
      _drugInfo = null;
      _errorMessage = null;
    });

    try {
      final url =
          'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=true&explaintext=true&titles=$drugName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'];
        final page = pages.values.first;

        if (page['extract'] != null) {
          setState(() {
            _drugInfo = page['extract'];
          });
        } else {
          setState(() {
            _errorMessage = "No information found for \"$drugName\".";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to fetch data. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drug Info Finder'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Drug Name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  _fetchDrugInfo(_controller.text.trim());
                }
              },
              icon: Icon(Icons.search),
              label: Text('Search'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              )
            else if (_drugInfo != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drug Information:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _drugInfo!,
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
