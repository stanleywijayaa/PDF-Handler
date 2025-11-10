import 'package:flutter/material.dart';

class CreateTemplate extends StatefulWidget {
  const CreateTemplate({super.key});
  @override
  State<CreateTemplate> createState() => _CreateTemplateState();
}

class _CreateTemplateState extends State<CreateTemplate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Handler 3000', style: TextStyle(color: Colors.white),), 
        centerTitle: true, 
        backgroundColor: Color.fromARGB(255, 1, 164, 219),
      ),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173FF),
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(4),
                      ),
                    ),
                    child: Text(
                      'Import',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173FF),
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(4),
                      ),
                    ),
                    child: Text(
                      'Resize',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(child: Text('b')),
          Center(child: Text('c')),
        ],
      ),
    );
  }
}
