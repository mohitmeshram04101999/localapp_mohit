import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/flashFiles_controller.dart';
import 'package:mooxy_pdf/login_page.dart';
import 'package:mooxy_pdf/providers.dart';

class BottomForm extends ConsumerStatefulWidget {
  const BottomForm({super.key});

  @override
  ConsumerState createState() => _BottomFormState();
}

class _BottomFormState extends ConsumerState<BottomForm> {
  @override
  void initState() {
    super.initState();
    FlashFilesController().getAllDailyUpdate();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController queryController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1000, maxHeight: 450),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[900],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Please, Provide your suggestions!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Enter Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Enter Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: queryController,
                            minLines: 5,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Enter Suggestions',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () async {
                              final userId = await ref
                                  .read(sharedPreferencesProvider)
                                  .value
                                  ?.getString('userId');
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  queryController.text.isEmpty) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Error',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 24)),
                                        content: Text(
                                            'Please fill all the fields',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20)),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          )
                                        ],
                                      );
                                    });
                              }
                              FlashFilesController().postQuery(
                                  query: queryController.text.trim(),
                                  userId: userId!,
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim());
                              // AppControllers().sendQuery(
                              //     nameController.text,
                              //     emailController.text,
                              //     queryController.text);
                            },
                            child: Text('Submit'),
                          )),
                    ),
                  ],
                ),
                // Daily Updates Section
                SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Daily Updates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      FutureBuilder<DailyUpdateResponse?>(
                        future: FlashFilesController().getAllDailyUpdate(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.data.isEmpty) {
                            return Center(child: Text('No data available'));
                          }

                          final dailyUpdates = snapshot.data!;
                          return Expanded(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  AppStateProviders.prifixUrl +
                                      dailyUpdates.data.last.image,
                                ),
                              ),
                              title: Text(
                                dailyUpdates.data.last.message,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          // return Expanded(
                          //   child: ListView.builder(
                          //     primary: false,
                          //     shrinkWrap: true,
                          //     itemCount: dailyUpdates.data.length,
                          //     itemBuilder: (context, index) => ListTile(
                          //       leading: CircleAvatar(
                          //         backgroundImage: NetworkImage(
                          //           AppStateProviders.prifixUrl +
                          //               dailyUpdates.data[index].image,
                          //         ),
                          //       ),
                          //       title: Text(
                          //         dailyUpdates.data[index].message,
                          //         style: TextStyle(color: Colors.white),
                          //       ),
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
