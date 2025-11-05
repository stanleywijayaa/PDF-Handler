import 'package:flutter/material.dart';

class SearchTemplate extends StatefulWidget {
  const SearchTemplate({super.key});
  @override
  State<SearchTemplate> createState() => _SearchTemplateState();
}

class _SearchTemplateState extends State<SearchTemplate> {
  _SearchTemplateState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Search Template',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 230, 230, 230),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 125, 125, 125),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      fillColor: Color.fromARGB(255, 200, 200, 200),
                      label: Text(
                        'Search Template...',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount =
                          constraints.maxWidth > 1200
                              ? 4
                              : constraints.maxWidth > 800
                              ? 3
                              : constraints.maxWidth > 600
                              ? 2
                              : 1;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap:
                            true, // 👈 makes grid take only as much space as needed
                        physics:
                            NeverScrollableScrollPhysics(), // 👈 prevent nested scroll conflict
                        children: List.generate(10, (index) {
                          return Card(
                            elevation: 3,
                            child: Center(child: Text('Card ${index + 1}')),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
