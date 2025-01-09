import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIS Class',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Student Information System'),
    );
  }
}

Future<bool> assetExists(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } catch (e) {
    return false;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final String response = await rootBundle.loadString('assets/students.json');
    final data = await json.decode(response);
    setState(() {
      students = List<Student>.from(
          data.map((json) => Student.fromJson(json)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final imagePath = 'images/${student.studentId.replaceAll("-", "")}.jpg';

                return FutureBuilder<bool>(
                  future: assetExists(imagePath),
                  builder: (context, snapshot) {
                    final resolvedImage = (snapshot.connectionState == ConnectionState.done && snapshot.data == true) ? AssetImage(imagePath) : const AssetImage('images/default.jpg');

                    return Container(
                      color: student.gender == 0 ? Colors.blue[100] : Colors.pink[100],
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailsPage(
                                student: student,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: resolvedImage,
                          backgroundColor: Colors.grey,
                        ),
                        title: Text(student.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Student ID: ${student.studentId}'),
                            Text('Major: ${student.major}'),
                            Text('Gender: ${student.gender == 0 ? "ชาย" : "หญิง"}'),
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

class StudentDetailsPage extends StatelessWidget {
  final Student student;

  const StudentDetailsPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final imagePath = 'images/${student.studentId.replaceAll("-", "")}.jpg';
    const defaultImagePath = 'images/default.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text('${student.gender == 0 ? "นาย" : "นางสาว"}${student.name}'),
      ),
      body: Center(
        child: FutureBuilder<bool>(
          future: assetExists(imagePath),
          builder: (context, snapshot) {
            final resolvedImage = (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == true)
                ? AssetImage(imagePath)
                : const AssetImage(defaultImagePath);

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: resolvedImage,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 20),
                Text('Name: ${student.name}', style: const TextStyle(fontSize: 20)),
                Text('Student ID: ${student.studentId}', style: const TextStyle(fontSize: 20)),
                Text(
                  'Gender: ${student.gender == 0 ? "ชาย" : student.gender == 1 ? "หญิง" : "อื่นๆ"}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text('Major: ${student.major}', style: const TextStyle(fontSize: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Student {
  final String studentId;
  final String name;
  final int gender;
  final String major;

  Student({
    required this.studentId,
    required this.name,
    required this.gender,
    required this.major,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      name: json['name'],
      gender: json['gender'],
      major: json['major'],
    );
  }
}
