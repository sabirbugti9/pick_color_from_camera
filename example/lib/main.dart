import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pick_color_from_camera/pick_color_from_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pick Color From Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color? selectColor;

  void _pickColor() async {
    String? result = await PickColorFromCamera.pickColor();
    setState(() {
      selectColor = Color(int.parse(result!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            selectColor ?? Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Pick Color From Camera",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickColor,
              child: const Text("Pick Color"),
            ),
          ],
        ),
      ),
    );
  }
}
