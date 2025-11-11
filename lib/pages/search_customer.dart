import 'package:flutter/material.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/services/data_logic.dart';

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
  double leftFraction = 0.6;
  final DataLogic api = DataLogic();

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final dividerWidth = 20.0;
        final leftWidth = (constraints.maxWidth - dividerWidth) * leftFraction;
        final rightWidth = (constraints.maxWidth - dividerWidth) * (1 - leftFraction);

        return Row(
          children: [
            //LEFT SIDE
            SizedBox(
              width: leftWidth,
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

            //RIGHT SIDE
            SizedBox(
              width: rightWidth,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Material (
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Title
                      Text(
                        "Search ${widget.template?.tableName ?? "Data"}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 12),
                      //Search Box
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Enter ${widget.template?.tableName ?? "Data"} name / id",
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
                            :customers.isEmpty
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerList() {
    if (customers.isEmpty) {
      return const Center(child: Text('No customers found'));
    }

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final number = index + 1;
        final id = customer['id'] ?? 'N/A';
        final nameKey = customer.keys.firstWhere(
          (key) => key.toLowerCase().contains('name'),
          orElse: () => '',
        );
        final nameValue = nameKey.isNotEmpty ? customer[nameKey] : 'N/A';
        final createdAt = customer['createdAt'] ?? 'N/A';
        final updatedAt = customer['updatedAt'] ?? 'N/A';

        return Card(
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
              nameValue.toString() + ("($id)"),
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
        );
      },
    );
  }
}
