import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdf_handler/model/schema.dart';
import 'package:pdf_handler/model/table.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/pages/search_customer.dart';
import 'package:pdf_handler/services/data_logic.dart';

class CreateTemplate extends StatefulWidget {
  final String hintText = "Untitled Form";
  final int uid;
  const CreateTemplate({super.key, required this.uid});
  @override
  State<CreateTemplate> createState() => _CreateTemplateState();
}

class _CreateTemplateState extends State<CreateTemplate> {
  late TextEditingController _controller;
  final DataLogic dataLogic = DataLogic();
  final FocusNode _focusNode = FocusNode();
  TableModel? selectedTable;
  dynamic _selectedData;
  bool _isFocused = false;
  bool _saved = false;
  String tableTitle = 'Data Fields';
  Future<List<dynamic>>? _futureDataCached;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _futureDataCached = _futureData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _futureData() async {
    if (_selectedData != null) {
      await _selectedData!.fetchSchema(uid: widget.uid);
      return _selectedData!.schema;
    } else {
      final tables = await dataLogic.getTables(uid: widget.uid);
      return tables ?? [];
    }
  }

  void _selectItem(dynamic item) {
    setState(() {
      _selectedData = item;

      if (item is TableModel) {
        selectedTable = item;
        // Update the future to fetch the schema of this table
        _futureDataCached = selectedTable!
            .fetchSchema(uid: widget.uid)
            .then((_) => selectedTable!.schema);
        tableTitle = selectedTable!.title;
      } else if (item is Schema) {
        // Optional: do something if a Schema is selected
        _selectedData = item;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 107, 179),
        automaticallyImplyLeading: false,
        titleSpacing: 10,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: _isFocused ? null : widget.hintText,
                  hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Row(
        children: [
          // ==== LEFT PANEL ====
          Container(
            width: max(MediaQuery.of(context).size.width * 0.18, 200),
            color: const Color.fromARGB(255, 80, 80, 80),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color.fromARGB(255, 199, 199, 199),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "New",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "Resize",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Components",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ), //⚠️add _onpressed function under this later⚠️.
                _componentButton("Text Box"),
                _componentButton("Check Box"),
                _componentButton("Radio Button"),
                _componentButton("Signature"),
              ],
            ),
          ),

          // ==== MIDDLE (PDF PREVIEW AREA) ====
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Container(
                          width: 600,
                          height: 800,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.white,
                          ),
                          child: const Center(child: Text("PDF Preview Here")),
                        ),
                      ),
                    ),
                  ),
                ),
                // ==== BOTTOM BAR (OPTIONAL PAGE INFO) ====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "1200x800",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Page: 1/3",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==== RIGHT PANEL ====
          Container(
            width: max(MediaQuery.of(context).size.width * 0.18, 200),
            color: const Color(0xFF505050),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  color: const Color.fromARGB(255, 70, 70, 70),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedData != null)
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedData = null;
                              selectedTable = null;
                              tableTitle = 'Data Fields';
                              _futureDataCached = dataLogic.getTables(
                                uid: widget.uid,
                              );
                            });
                          },
                        )
                      else
                        SizedBox(width: 40, height: 40),
                      Expanded(
                        child: Text(
                          tableTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ), //⚠️create function to loop through nocobase table and call it here.⚠️
                Expanded(
                  child: FutureBuilder(
                    future: _futureDataCached,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data found'));
                      }

                      final items = snapshot.data!;
                      return ListView.builder(
                        physics: ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          String titleText = '';
                          if (item is Schema) {
                            titleText = item.title;
                          } else if (item is TableModel) {
                            titleText = item.title;
                          } else {
                            titleText = item.toString();
                          }
                          return InkWell(
                            onTap: () => _selectItem(item),
                            child: Card(
                              color:
                                  _selectedData == item
                                      ? Colors.blue
                                      : const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(title: Text(titleText)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_saved)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SearchCustomer(
                                    template: Template(
                                      //⚠️Change to created template⚠️//
                                      id: 2,
                                      title: 'ABC',
                                      tableName: 'product',
                                      fileSize: 123456,
                                    ),
                                    uid: widget.uid,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                        child: const Text(
                          "Fill Data",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                        child: const Text(
                          "Fill Data",
                          style: TextStyle(
                            color: Color.fromARGB(255, 190, 190, 190),
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => _showSaveDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 44, 127, 11),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
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

  void _showSaveDialog(BuildContext context) {
    if (_controller.text == '') {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Save Template",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 18,
                        ),
                        cursorColor: const Color.fromARGB(255, 0, 0, 0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: _isFocused ? null : widget.hintText,
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {}
  }
}
