import 'package:flutter/material.dart';
import 'database_helper.dart';

class EnrollmentSummaryPage extends StatefulWidget {
  final int userId;

  EnrollmentSummaryPage(this.userId);

  @override
  _EnrollmentSummaryPageState createState() => _EnrollmentSummaryPageState();
}

class _EnrollmentSummaryPageState extends State<EnrollmentSummaryPage> {
  final _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _enrolledSubjects = [];
  int _totalCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadEnrollmentSummary();
  }

  _loadEnrollmentSummary() async {
    var subjects = await _dbHelper.getUserSubjects(widget.userId);
    var totalCredits = await _dbHelper.getTotalCredits(widget.userId);

    setState(() {
      _enrolledSubjects = subjects;
      _totalCredits = totalCredits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enrollment Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Total Credits: $_totalCredits'),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _enrolledSubjects.length,
                itemBuilder: (context, index) {
                  var subject = _enrolledSubjects[index];
                  return ListTile(
                    title: Text(subject['name']),
                    subtitle: Text('${subject['credits']} credits'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
