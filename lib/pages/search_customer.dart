import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/services/data_logic.dart';
import 'package:pdf_handler/services/template_logic.dart';
import 'package:pdfx/pdfx.dart';

class SearchCustomer extends StatefulWidget {
  final Template? template;
  final int uid;

  const SearchCustomer({
    super.key, 
    required this.template,
    required this.uid,
  });

  @override
  State<SearchCustomer> createState() => _SearchCustomerState();
}

class _SearchCustomerState extends State<SearchCustomer> {
  PdfControllerPinch? _pdfController;
  Uint8List? _pdfBytes;
  final TextEditingController _searchController = TextEditingController();
  double leftFraction = 0.6;
  final DataLogic api = DataLogic();
  final TemplateLogic tempApi = TemplateLogic();

  List <Map<String, dynamic>> customers = [];
  List <Map<String, dynamic>> filteredCustomers =[];
  bool isLoading = false;
  bool isLoadingPdf = true;
  String? errorMessage;
  String? errorMessagePDF;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadPdfBytes();
  }

  Future<void> _loadPdfBytes() async {
    try {
      final bytes = await _loadPdf();
      if (bytes != null) {
        _pdfBytes = bytes;
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(_pdfBytes!),
        );
        setState(() => isLoadingPdf = false);
      } else {
          setState(() {
            errorMessagePDF = "Failed to load PDF";
            isLoadingPdf = false;
          });
      }
    } catch (e) {
        setState(() {
          errorMessagePDF = e.toString();
          isLoadingPdf = false;
        });
    }
  }

  Future<Uint8List?> _loadPdf() async {
      final url = await tempApi.getTemplate(
        templateId: widget.template!.id
      );
      return url;
  }

  Future<void> _loadCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await api.getCustomers(
        templateId: widget.template?.id ?? 0,
        customerId: widget.uid,
      );
      setState(() {
        customers = data;
        filteredCustomers = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCustomers = customers;
      });
      return;
    }
    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredCustomers = customers.where((customer) {
        final combined = customer.values.join(' ').toLowerCase();
        return combined.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _loadFilledPdf(int dataId) async {
    setState(() {
      isLoadingPdf = true;
      errorMessagePDF = null;
    });
    try {
      final bytes = await _loadPdf();
      if (bytes == null) {
        throw Exception("Template bytes not found");
      }

      final pdfBytes = await api.fillData(
        templateId: widget.template!.id,
        customerId: widget.uid,
        fileBytes: bytes,
        dataId: dataId,
      );

      if (pdfBytes != null && mounted) {
        setState(() {
          _pdfController?.dispose();
          _pdfController = PdfControllerPinch(
            document: PdfDocument.openData(pdfBytes),
          );
          isLoadingPdf = false;
        });
      } else {
        setState(() {
          errorMessagePDF = "Failed to generate filled PDF";
          isLoadingPdf = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessagePDF = e.toString();
        isLoadingPdf = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dividerWidth = 20.0;
        final leftWidth = (constraints.maxWidth - dividerWidth) * leftFraction;
        final rightWidth = (constraints.maxWidth - dividerWidth) * (1 - leftFraction);

        return SizedBox(
          height: constraints.maxHeight,
          child: Row(
            children: [
              // LEFT SIDE
              SizedBox(
                width: leftWidth,
                height: double.infinity,
                child: Container(
                  color: Colors.grey[200],
                  child: isLoadingPdf
                      ? const Center(child: CircularProgressIndicator())
                      : (_pdfController != null)
                          ? PdfViewPinch(controller: _pdfController!)
                          : Center(
                              child: Text(
                                errorMessagePDF ?? 'No PDF loaded',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                ),
              ),

              // DRAGGABLE DIVIDER
              StatefulBuilder(
                builder: (context, localSetState) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      if (!mounted) return;
                      setState(() {
                        leftFraction += details.delta.dx / constraints.maxWidth;
                        if (leftFraction < 0.2) leftFraction = 0.2;
                        if (leftFraction > 0.8) leftFraction = 0.8;
                      });
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                      child: SizedBox(
                        width: dividerWidth,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Container(color: Colors.grey[200])),
                                Expanded(child: Container(color: Colors.white)),
                              ],
                            ),
                            Container(
                              width: 1,
                              color: Colors.grey.shade400,
                            ),
                            Container(
                              width: 8,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // RIGHT SIDE
              SizedBox(
                width: rightWidth,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          "Search ${widget.template?.tableName ?? "Data"}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        // Search Box
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText:
                                "Enter ${widget.template?.tableName ?? "Data"} name / id",
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.search),
                          ),
                          onSubmitted: _searchCustomers,
                        ),
                        const SizedBox(height: 20),
                        // Customer List
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : errorMessage != null
                                  ? Center(child: Text("Error: $errorMessage"))
                                  : customers.isEmpty
                                      ? const Center(child: Text("No customers found"))
                                      : _buildCustomerList(),
                        ),
                        const SizedBox(height: 20),
                        // Export button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Export PDF",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePdfLoad(int id) async {
    try {
      await _loadFilledPdf(id);
    } catch (e) {
      setState(() {
        errorMessagePDF = "Error loading PDF: $e";
      });
    } finally {
      // ignore: use_build_context_synchronously
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }


  Widget _buildCustomerList() {
    if (filteredCustomers.isEmpty) {
      return const Center(child: Text('No customers found'));
    }

    return ListView.builder(
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        final number = index + 1;
        final id = customer['id'] ?? 'N/A';
        final nameKey = customer.keys.firstWhere(
          (key) => key.toLowerCase().contains('name'),
          orElse: () => '',
        );
        final nameValue = nameKey.isNotEmpty ? customer[nameKey] : 'N/A';
        final createdAt = customer['createdAt'] ?? 'N/A';
        final updatedAt = customer['updatedAt'] ?? 'N/A';

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            _handlePdfLoad(id);
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(number.toString()),
              ),
              title: Text(
                nameValue.toString() + ("(ID: $id)"),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created at: $createdAt'),
                  Text('Updated at: $updatedAt'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
