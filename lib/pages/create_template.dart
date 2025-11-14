import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf_handler/services/form_logic.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_handler/model/field.dart';
import 'package:pdf_handler/model/table.dart';
import 'package:pdf_handler/model/schema.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/services/data_logic.dart';
import 'package:pdf_handler/pages/search_customer.dart';

class CreateTemplate extends StatefulWidget {
  final String hintText = "Untitled Form";
  final int uid;
  const CreateTemplate({super.key, required this.uid});
  @override
  State<CreateTemplate> createState() => _CreateTemplateState();
}

class _CreateTemplateState extends State<CreateTemplate> {
  PdfControllerPinch? _pdfController;
  late TextEditingController _controller;
  final DataLogic dataLogic = DataLogic();
  final FocusNode _focusNode = FocusNode();
  TableModel? selectedTable;
  Field? selectedField;
  dynamic _selectedData;
  bool _isFocused = false;
  bool _saved = false;
  String tableTitle = 'Data Fields';
  String selectedComponent = "";
  Future<List<dynamic>>? _futureDataCached;
  String fileName = '';
  int pdfPageNum = 1;
  int pdfTotalPage = 1;
  double pdfWidth = 0, pdfHeight = 0;
  bool isLoading = true;
  Template? finishedTemplate;
  int? _savedPdfId;
  final GlobalKey pdfAreaKey = GlobalKey();
  final List<Field> _placedComponents = [];
  late Uint8List fileBytes;

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
    _pdfController?.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      fileBytes = Uint8List.fromList(
        result.files.first.bytes!.toList(),
      ); // file content
      String fileName = result.files.first.name.replaceAll(
        RegExp(r'\.[^\/.]+$'),
        '',
      );

      setState(() {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(
            Uint8List.fromList(result.files.first.bytes!.toList()),
          ),
        );
        _controller.text = fileName;
      });
    }
  }

  Future<List<dynamic>> _futureData() async {
    if (selectedTable != null) {
      await selectedTable!.fetchSchema(uid: widget.uid);
      return selectedTable!.schema;
    } else {
      final tables = await dataLogic.getTables(uid: widget.uid);
      return tables ?? [];
    }
  }

  void _addDraggableComponent() {
    if (selectedField == null || selectedComponent.isEmpty) return;

    // // If the user selected a Schema (field)
    // String fieldKey = '';
    // if (selectedField is Field) {
    //   fieldKey = (_selectedData as Schema).title;
    // } else {
    //   fieldKey = 'Unnamed Field';
    // }

    setState(() {
      _placedComponents.add(
        Field(
          type: selectedComponent,
          fieldName: selectedField!.fieldName,
          dataField: selectedField!.dataField,
          page: selectedField!.page - 1,
          x: const Offset(100, 100).dx,
          y: const Offset(100, 100).dy,
          width: 100,
          height: 50,
        ),
      );
    });
  }

  void _selectItem(dynamic item) {
    setState(() {
      _selectedData = item;
      //print(item.toString());

      if (item is TableModel) {
        selectedTable = item;
        // Update the future to fetch the schema of this table
        _futureDataCached = selectedTable!
            .fetchSchema(uid: widget.uid)
            .then((_) => selectedTable!.schema);
        tableTitle = selectedTable!.title;
      } else if (item is Schema) {
        if (item.childSchema == null || item.childSchema!.isEmpty) {
          selectedField = Field(
            type: selectedComponent,
            fieldName: item.title,
            dataField: item.fieldName,
            page: pdfPageNum,
          );
        }
        _addDraggableComponent();
      }
    });
  }

  void _exportFinishedTemplate(BuildContext context, String name) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a template name")),
      );
      return;
    }

    // ✅ Build your export logic here
    final formLogic = FormLogic(
      templateName: name.trim(),
      tableName: selectedTable!.tableName, // whatever table user picked
      placedComponents: _placedComponents, // your draggable items
      pdfAreaKey: pdfAreaKey,
      pdfWidth: pdfWidth,
      pdfHeight: pdfHeight,
      UID: widget.uid,
      fileBytes: Uint8List.fromList(fileBytes.toList()),
    );

    final rawFinishedTemplate = await formLogic.exportTemplate(context);
    if (rawFinishedTemplate != null) {
      setState(() {
        finishedTemplate = Template(
          id: rawFinishedTemplate['id'],
          title: rawFinishedTemplate['title'],
          tableName: rawFinishedTemplate['tableName'],
          fileSize: rawFinishedTemplate['fileSize'],
        );
        if (finishedTemplate != null) _saved = true;
      });
    } // close dialog

    if (context.mounted) Navigator.pop(context);
  }

  void _setPageData(PdfDocument document) async {
    final page = await document.getPage(1);
    setState(() {
      isLoading = false;
      pdfHeight = page.height;
      pdfWidth = page.width;
    });
    page.close();
  }

  void _selectAnotherTable() {
    if (_placedComponents.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            backgroundColor: const Color.fromARGB(255, 210, 210, 210),
            title: Center(
              child: Text(
                'Remove Fields',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            content: Text(
              'You can only use one data table.\nSelecting another table will remove all current fields',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    _placedComponents.clear();
                    _selectedData = null;
                    selectedTable = null;
                    tableTitle = 'Data Fields';
                    _futureDataCached = dataLogic.getTables(uid: widget.uid);
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _placedComponents.clear();
        _selectedData = null;
        selectedTable = null;
        tableTitle = 'Data Fields';
        _futureDataCached = dataLogic.getTables(uid: widget.uid);
      });
    }
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
                Material(
                  color: Colors.green,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    splashColor: const Color.fromARGB(255, 77, 184, 77),
                    onTap: () {
                      _loadPdf();
                    },
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: const Icon(
                        Icons.file_upload_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: const Color(0xFF464646),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    textAlign: TextAlign.center,
                    "Components",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                _componentButton("Text Box"),
                _componentButton("Check Box"),
                _componentButton("Radio Button"),
                _componentButton("Signature"),
                const SizedBox(height: 10),
                Container(
                  color: const Color(0xFF464646),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    textAlign: TextAlign.center,
                    "Fields",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    itemCount: _placedComponents.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(8),
                          ),
                        ),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          leading: Icon(Icons.text_fields, size: 20),
                          trailing: IconButton(
                            onPressed: () {
                              _placedComponents.removeAt(index);
                              setState(() {});
                            },
                            icon: Icon(Icons.delete, size: 20),
                          ),
                          minLeadingWidth: 0,
                          minTileHeight: 10,
                          title: Text(
                            _placedComponents[index].fieldName,
                            style: TextStyle(fontSize: 11),
                          ),
                          subtitle: Text(
                            _placedComponents[index].dataField,
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ==== MIDDLE (PDF PREVIEW AREA) ====
          Expanded(
            child: Column(
              children: [
                _pdfController == null
                    ? Expanded(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey,
                        child: Center(
                          child: Text('Import a PDF file to start'),
                        ),
                      ),
                    )
                    : Expanded(
                      child: Stack(
                        key: pdfAreaKey,
                        children: [
                          Container(
                            color: Color.fromARGB(255, 100, 100, 100),
                            child: PdfViewPinch(
                              onDocumentLoaded:
                                  (document) => setState(() {
                                    pdfTotalPage = document.pagesCount;
                                    _setPageData(document);
                                  }),
                              onPageChanged:
                                  (page) => setState(() {
                                    pdfPageNum = page;
                                  }),
                              onDocumentError:
                                  (error) =>
                                      Text('Error rendering pdf: $error'),
                              padding: 10,
                              maxScale: 1,
                              minScale: 1,
                              controller: _pdfController!,
                              scrollDirection: Axis.vertical,
                            ),
                          ),
                          //Draggable overlay
                          ..._placedComponents.map((component) {
                            return Positioned(
                              left: component.x,
                              top: component.y,
                              child: Draggable(
                                feedback: _buildDraggableBox(
                                  component,
                                  isDragging: true,
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: _buildDraggableBox(component),
                                ),
                                child: _buildDraggableBox(component),
                                onDragEnd: (details) {
                                  final RenderBox box =
                                      pdfAreaKey.currentContext!
                                              .findRenderObject()
                                          as RenderBox;
                                  final localOffset = box.globalToLocal(
                                    details.offset,
                                  );
                                  setState(() {
                                    final updated = component.copyWith(
                                      x: localOffset.dx,
                                      y: localOffset.dy,
                                    );
                                    final index = _placedComponents.indexOf(
                                      component,
                                    );
                                    _placedComponents[index] = updated;
                                  });
                                },
                              ),
                            );
                          }),
                          if (isLoading)
                            Container(
                              color: const Color.fromARGB(255, 100, 100, 100),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                // ==== BOTTOM BAR (OPTIONAL PAGE INFO) ====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${pdfWidth}x$pdfHeight',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Page: $pdfPageNum/$pdfTotalPage",
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
                          onPressed: () => _selectAnotherTable(),
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
                ),
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
                        padding: const EdgeInsets.all(12),
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
                          if (item is Schema &&
                              item.childSchema != null &&
                              item.childSchema!.isNotEmpty) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              color:
                                  _selectedData == item
                                      ? Colors.blue
                                      : const Color.fromARGB(
                                        255,
                                        240,
                                        240,
                                        240,
                                      ),
                              child: ExpansionTile(
                                title: Text(
                                  titleText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        _selectedData == item
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                backgroundColor:
                                    _selectedData == item
                                        ? Colors.blue
                                        : const Color.fromARGB(
                                          255,
                                          240,
                                          240,
                                          240,
                                        ),
                                onExpansionChanged: (_) {},
                                children: [
                                  ...item.childSchema!.map((child) {
                                    final isSelected = _selectedData == child;
                                    return Container(
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.transparent,
                                      child: ListTile(
                                        title: Text(
                                          child.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        tileColor:
                                            isSelected ? Colors.blue : null,
                                        onTap: () => _selectItem(child),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            color:
                                _selectedData == item
                                    ? Colors.blue
                                    : const Color.fromARGB(255, 240, 240, 240),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _selectItem(item),
                              child: ListTile(
                                title: Text(
                                  titleText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        _selectedData == item
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
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
                    if (_saved && finishedTemplate != null)
                      ElevatedButton(
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: '',
                            barrierColor: Colors.black54,
                            transitionDuration: const Duration(
                              milliseconds: 180,
                            ),
                            pageBuilder: (context, anim1, anim2) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: Container(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    child: SearchCustomer(
                                      template: finishedTemplate,
                                      uid: widget.uid,
                                    ),
                                  ),
                                ),
                              );
                            },
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
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedComponent = label;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedComponent == label
                  ? Colors.blue
                  : Color.fromARGB(255, 240, 240, 240),
          minimumSize: const Size(300, 50),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedComponent == label ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    final TextEditingController dialogController = TextEditingController();
    dialogController.text = _controller.text;
    final FocusNode dialogFocusNode = FocusNode();
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
                      controller: dialogController,
                      focusNode: dialogFocusNode,
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
                  SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _controller.text = dialogController.text;
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              () => _exportFinishedTemplate(
                                context,
                                dialogController.text,
                              ),
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableBox(Field field, {bool isDragging = false}) {
    return Container(
      width: 150,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isDragging
                  ? Colors.blue.withValues(alpha: 0.5)
                  : const Color.fromARGB(255, 0, 122, 255),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        field.fieldName,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }
}
