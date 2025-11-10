import 'package:flutter/material.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/services/custdata_logic.dart';

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
  //For search field later
  final TextEditingController _searchController = TextEditingController();
  final ApiService api = ApiService();

  List <Map<String, dynamic>> customers = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  "PDF Preview\n(coming later)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // RIGHT SIDE
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Title
                  const Text(
                    "Search Customer",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  //Search Box
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Enter customer name / id",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //Placeholder for customer details
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
                  //Export button
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
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final entries = customer.entries.map((e) => "${e.key}: ${e.value}").toList();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries
                .map((line) => Text(line, style: const TextStyle(fontSize: 14)))
                .toList(),
            ),
          ),
        );
      },
    );
  }
}
