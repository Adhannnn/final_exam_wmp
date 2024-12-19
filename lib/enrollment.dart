import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'menu.dart';

class EnrollmentPage extends StatefulWidget {
  final int userId;

  EnrollmentPage(this.userId);

  @override
  _EnrollmentPageState createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  final _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _subjects = [];
  int _totalCredits = 0;
  static const int MAX_CREDITS = 24;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  _loadSubjects() async {
    var subjects = await _dbHelper.getSubjects();
    var totalCredits = await _dbHelper.getTotalCredits(widget.userId);

    setState(() {
      _subjects = subjects;
      _totalCredits = totalCredits;
    });
  }

  _enrollSubject(int subjectId) async {
    if (_totalCredits + 3 <= MAX_CREDITS) {  // Assuming each subject is 3 credits
      await _dbHelper.enrollUserInSubject(widget.userId, subjectId);
      _loadSubjects(); // Refresh subjects
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Max credit limit reached')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enroll in Subjects')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total Credits: $_totalCredits / $MAX_CREDITS'),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  var subject = _subjects[index];
                  return ListTile(
                    title: Text(subject['name']),
                    subtitle: Text('${subject['credits']} credits'),
                    trailing: ElevatedButton(
                      onPressed: () => _enrollSubject(subject['id']),
                      child: Text('Enroll'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage(widget.userId)),
                );
              },
              child: Text('Go to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
