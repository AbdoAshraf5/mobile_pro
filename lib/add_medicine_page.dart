import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMedicinePage extends StatefulWidget {
  final Map<String, dynamic>? medicine;

  AddMedicinePage({this.medicine});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  final List<TextEditingController> timeControllers = [];

  String doseFrequency = '1'; // Default to 1 dose
  String intervalType = 'Daily'; // Default to daily
  int customDosesPerDay = 1; // Default for custom doses
  int customDaysPerWeek = 1; // Default for custom days

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      nameController.text = widget.medicine!['name'];
      startDateController.text = widget.medicine!['startDate'];
      durationController.text = widget.medicine!['duration']?.toString() ?? '';
      doseFrequency = widget.medicine!['doses'].toString();
    }
    _generateTimeFields(1); // Default to 1 dose time field
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 10)),
    );
    if (pickedDate != null) {
      setState(() {
        startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  void _generateTimeFields(int count) {
    timeControllers.clear();
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        timeControllers.add(TextEditingController());
      }
    }
  }

  bool _isFormValid() {
    // Check if required fields are filled
    if (nameController.text.isEmpty ||
        startDateController.text.isEmpty ||
        doseFrequency.isEmpty ||
        (doseFrequency != 'Custom' &&
            timeControllers.any((controller) => controller.text.isEmpty)) ||
        (doseFrequency == 'Custom' &&
            (customDosesPerDay <= 0 ||
                timeControllers
                    .any((controller) => controller.text.isEmpty)))) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Medicine Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: startDateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration:
                    InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (in days, optional)',
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: doseFrequency,
                items: ['1', '2', '3', 'Custom']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value == 'Custom'
                              ? 'Custom schedule'
                              : '$value doses/day'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    doseFrequency = value!;
                    if (value == '1') {
                      _generateTimeFields(1);
                    } else if (value == '2') {
                      _generateTimeFields(2);
                    } else if (value == '3') {
                      _generateTimeFields(3);
                    } else if (value == 'Custom') {
                      _generateTimeFields(0);
                    }
                  });
                },
                decoration: InputDecoration(labelText: 'Select Doses per Day'),
              ),
              SizedBox(height: 16),
              if (doseFrequency != 'Custom')
                ...List.generate(timeControllers.length, (index) {
                  return Column(
                    children: [
                      TextField(
                        controller: timeControllers[index],
                        readOnly: true,
                        onTap: () => _selectTime(timeControllers[index]),
                        decoration: InputDecoration(
                            labelText: 'Dose ${index + 1} Time (AM/PM)'),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                }),
              if (doseFrequency == 'Custom') ...[
                TextField(
                  decoration: InputDecoration(labelText: 'Days per Week'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    customDaysPerWeek = int.tryParse(value) ?? 1;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Doses per Day'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      customDosesPerDay = int.tryParse(value) ?? 1;
                      _generateTimeFields(customDosesPerDay);
                    });
                  },
                ),
                if (customDosesPerDay > 0) ...[
                  ...List.generate(customDosesPerDay, (index) {
                    return TextField(
                      controller: index < timeControllers.length
                          ? timeControllers[index]
                          : TextEditingController(),
                      readOnly: true,
                      onTap: () => index < timeControllers.length
                          ? _selectTime(timeControllers[index])
                          : null,
                      decoration:
                          InputDecoration(labelText: 'Dose ${index + 1} Time'),
                    );
                  }),
                ],
              ],
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isFormValid()
                    ? () {
                        Navigator.pop(context, {
                          'name': nameController.text,
                          'startDate': startDateController.text,
                          'duration': durationController.text.isEmpty
                              ? null
                              : int.parse(durationController.text),
                          'doses': int.parse(doseFrequency == 'Custom'
                              ? customDosesPerDay.toString()
                              : doseFrequency),
                          'times': timeControllers.map((c) => c.text).toList(),
                        });
                      }
                    : null,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
