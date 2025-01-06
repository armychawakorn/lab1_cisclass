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
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                          'images/${students[index].studentId.replaceAll("-", "")}.jpg'),
                      backgroundColor: Colors.grey,
                    ),
                    title: Text(students[index].name),
                    subtitle: Text(
                        '${students[index].studentId} - ${students[index].gender == 0 ? "ชาย" : ""} - ${students[index].major}'),
                  );
                },
              ));
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
