import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/fullForm_componentSearch_controller.dart';

class FullFormSearch extends ConsumerStatefulWidget {
  const FullFormSearch({super.key});

  @override
  ConsumerState createState() => _FullFormSearchState();
}

class _FullFormSearchState extends ConsumerState<FullFormSearch>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  TextEditingController fullFromQuery = TextEditingController();
  TextEditingController componentQuery = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this)
      ..addListener(
        () {
          setState(() {});
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Form'),
        actions: [],
      ),
      body: Stack(
        children: [
          Container(
            child: FutureBuilder<FullFormResponse?>(
              future: FullFormComponentSearchController()
                  .getFullFormResults(fullFromQuery.text.trim()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data available'));
                } else {
                  final result = snapshot.data!;
                  return fullFromQuery.text.isEmpty
                      ? Center(
                          child: SizedBox(
                              height: 500,
                              // width: 1000,
                              child: Text("Search to view full forms")),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 100,
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: result.data.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          '${result.data[index].fullForm}'),
                                      subtitle: Text(
                                          '${result.data[index].shortName}'),
                                      onTap: () {
                                        // FullFormComponentSearchController()
                                        //     .getComponentResults('pmi');
                                      },
                                    );
                                  }),
                            ],
                          ),
                        );
                }
              },
            ),
          ),
          Positioned(
              top: 10,
              left: 100,
              right: 100,
              child: SearchBar(
                hintText: 'Search Full Form',
                controller: fullFromQuery,
                onChanged: (value) {
                  FullFormComponentSearchController().getFullFormResults(value);
                  setState(() {});
                },
              ))
        ],
      ),
    );
  }
}
