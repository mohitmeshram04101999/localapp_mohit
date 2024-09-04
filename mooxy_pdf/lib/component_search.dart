import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/fullForm_componentSearch_controller.dart';

class ComponentSearch extends ConsumerStatefulWidget {
  const ComponentSearch({super.key});

  @override
  ConsumerState createState() => _ComponentSearchState();
}

class _ComponentSearchState extends ConsumerState<ComponentSearch>
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
        title: Text('Component Search'),
        actions: [],
      ),
      body: Stack(
        children: [
          Container(
            child: FutureBuilder<ComponentResponse?>(
              future: FullFormComponentSearchController()
                  .getComponentResults(componentQuery.text.trim()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data available'));
                }
                final result = snapshot.data!;
                return componentQuery.text.isEmpty
                    ? Center(
                        child: SizedBox(
                            height: 500,
                            // width: 1000,
                            child: Text("Search to view components")),
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
                                    title: Text('${result.data[index].name}'),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) {
                                          return Scaffold(
                                            appBar: AppBar(
                                              title: Text(
                                                  '${result.data[index].name}'),
                                            ),
                                            body: FutureBuilder<
                                                    ComponentPartResponse?>(
                                                future:
                                                    FullFormComponentSearchController()
                                                        .getComponentPartResult(
                                                            componentQuery
                                                                .text
                                                                .trim(),
                                                            result.data[index]
                                                                .name),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else if (!snapshot
                                                      .hasData) {
                                                    return Center(
                                                        child: Text(
                                                            'No data available'));
                                                  }
                                                  final result = snapshot.data!;
                                                  return SingleChildScrollView(
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          DataTable(
                                                              columns: [
                                                                DataColumn(
                                                                    label: Text(
                                                                        'Brand')),
                                                                DataColumn(
                                                                    label: Text(
                                                                        'Description')),
                                                                DataColumn(
                                                                    label: Text(
                                                                        'Model')),
                                                                DataColumn(
                                                                    label: Text(
                                                                        'Part No')),
                                                                DataColumn(
                                                                    label: Text(
                                                                        'IC Name')),
                                                              ],
                                                              rows: result.data
                                                                  .map((e) =>
                                                                      DataRow(
                                                                          cells: [
                                                                            DataCell(Text(e.componentBrandName)),
                                                                            DataCell(Text(e.description)),
                                                                            DataCell(Text(e.model)),
                                                                            DataCell(Text(e.partNo)),
                                                                            DataCell(Text(e.icName)),
                                                                          ]))
                                                                  .toList()),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          );
                                        },
                                      ));
                                    },
                                  );
                                }),
                          ],
                        ),
                      );
              },
            ),
          ),
          Positioned(
            top: 10,
            left: 100,
            right: 100,
            child: SearchBar(
                hintText: 'Search Component',
                controller: componentQuery,
                onChanged: (value) {
                  FullFormComponentSearchController()
                      .getComponentResults(value);
                  setState(() {});
                }),
          )
        ],
      ),
    );
  }
}
