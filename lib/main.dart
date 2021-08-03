import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_list/add_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  ///top appbar transparent
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Student(),
    );
  }
}

class Student extends StatefulWidget {
  const Student({Key key}) : super(key: key);

  @override
  _StudentState createState() => _StudentState();
}

class _StudentState extends State<Student> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  bool filterTime = false;
  String searchName = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    categoryController = TextEditingController();
    subCategoryController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Data")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all((10.0)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: (40),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey, width: (2)),
                      color: Colors.grey.shade100,
                    ),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          searchName = val;
                        });
                      },
                      controller: searchController,
                      cursorColor: Colors.blueGrey,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blueGrey,
                        ),
                        border: InputBorder.none,
                        hintText: 'Search Name...',
                        hintStyle: TextStyle(
                          color: Colors.blueGrey.shade200,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: (20),
                  icon: Icon(
                    filterTime
                        ? Icons.filter_alt_outlined
                        : Icons.filter_alt_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      filterTime = !filterTime;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text(
                    "Add Category",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      showDialog(
                        context: context,
                        builder: (ctx) => StudentAddUpdate(
                          docId: null,
                          name: null,
                          subA: null,
                          subB: null,
                          subC: null,
                          dbname: "Student",
                        ),
                      );
                    });
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                  stream: searchName != "" && searchName != null
                      ? db
                          .collection("Student")
                          .where('category', isGreaterThanOrEqualTo: searchName)
                          .snapshots()
                      : filterTime
                          ? db
                              .collection("Student")
                              .orderBy("time", descending: false)
                              .snapshots()
                          : db
                              .collection("Student")
                              .orderBy("time", descending: true)
                              .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData ||
                        snapshot.data.docs.isEmpty) {
                      return Center(child: Text("Data Not Found"));
                    } else {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.symmetric(horizontal: (10)),
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            int subA = snapshot.data.docs[index]['subA'];
                            int subB = snapshot.data.docs[index]['subB'];
                            int subC = snapshot.data.docs[index]['subC'];
                            int total = subA += subB += subC;
                            var average = (total / 3.0);
                            var percentage = (total / 300.0) * 100;

                            return Card(
                              elevation: 10,
                              margin: EdgeInsets.only(bottom: (15)),
                              child: ListTile(
                                tileColor: Colors.white,
                                trailing: IconButton(
                                  splashRadius: (20),
                                  constraints:
                                      BoxConstraints(minWidth: 0, minHeight: 0),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          insetPadding: EdgeInsets.symmetric(
                                              vertical: 100, horizontal: 50),
                                          content: SingleChildScrollView(
                                              child: Center(
                                            child: Text("Are You Sure."),
                                          )),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Cancel")),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  db
                                                      .collection("Student")
                                                      .doc(snapshot
                                                          .data.docs[index].id)
                                                      .delete();
                                                });

                                                Navigator.pop(context);
                                              },
                                              child: Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                ),
                                leading: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      splashRadius: (20),
                                      constraints: BoxConstraints(
                                          minWidth: 0, minHeight: 0),
                                      icon:
                                          Icon(Icons.edit, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => StudentAddUpdate(
                                              docId:
                                                  snapshot.data.docs[index].id,
                                              name: snapshot.data.docs[index]
                                                  ['name'],
                                              subA: snapshot.data.docs[index]
                                                  ['subA'],
                                              subB: snapshot.data.docs[index]
                                                  ['subB'],
                                              subC: snapshot.data.docs[index]
                                                  ['subC'],
                                              dbname: "Student",
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                    Text("${index + 1}"),
                                  ],
                                ),
                                title: Text(
                                  snapshot.data.docs[index]['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // Image.network(
                                        //   snapshot.data.docs[index]['url'],
                                        //   // height: 100,
                                        //   // width: 100,
                                        // ),
                                        Column(
                                          children: [
                                            Text("SubA"),
                                            Text(
                                              snapshot.data.docs[index]['subA']
                                                  .toString(),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text("SubB"),
                                            Text(
                                              snapshot.data.docs[index]['subB']
                                                  .toString(),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text("SubC"),
                                            Text(
                                              snapshot.data.docs[index]['subC']
                                                  .toString(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "${percentage.toStringAsFixed(2)} %",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }
}
