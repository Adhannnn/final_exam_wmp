import 'package:flutter/material.dart';
import 'enrollment.dart';
import 'enrollment_list.dart';
import 'login.dart';

class MenuPage extends StatelessWidget {
  final int userId;

  MenuPage(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnrollmentPage(userId)),
                );
              },
              child: Text('Enrollment'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnrollmentSummaryPage(userId)),
                );
              },
              child: Text('Enrollment Summary'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Log out by navigating back to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
