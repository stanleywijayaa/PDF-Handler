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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text(
          "Title",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Row(
        children: [
          // ==== LEFT PANEL ====
          Container(
            width: 200,
            color: Colors.grey[100],
            child: Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Import"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Resize"),
                ),
                const Divider(thickness: 2),
                const Text(
                  "Components",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),//⚠️add _onpressed function under this later⚠️.
                _componentButton("Text Box"),
                _componentButton("Check Box"),
                _componentButton("Radio Button"),
                _componentButton("Signature"),
              ],
            ),
          ),

          // ==== MIDDLE (PDF PREVIEW AREA) ====
          Expanded(
            child: Center(
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text("PDF Preview Here"),
                ),
              ),
            ),
          ),

          // ==== RIGHT PANEL ====
          Container(
            width: 200,
            color: Colors.grey[100],
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Data",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10), //⚠️create function to loop through nocobase table and call it here.⚠️
                _dataButton("Table 1"),
                _dataButton("Table 2"),
                _dataButton("Table 3"),
                _dataButton("Table 4"),
                _dataButton("Table 5"),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      child: const Text("Fill Data"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),

      // ==== BOTTOM BAR (OPTIONAL PAGE INFO) ====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("1200x800", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Page: 1/3", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _componentButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          minimumSize: const Size(150, 40),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _dataButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          minimumSize: const Size(150, 40),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
