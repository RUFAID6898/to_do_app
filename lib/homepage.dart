// import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

TextEditingController notecontroller = TextEditingController();
final openfir = FirebaseFirestore.instance.collection('add');
ValueNotifier<DateTime> notifier = ValueNotifier(DateTime.now());

void adde() {
  openfir.add({'ithem': notecontroller.text, 'date': notifier.value});
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    //DateTime _time = DateTime.now();

    // String newnote = _notecontroller.text;
    // String save = 'selacted value';
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('TODO APP'),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow,
          splashColor: Colors.red,
          onPressed: () {
            // alertbutton(context);
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Center(child: Text('Day Note')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: notecontroller,
                        decoration: InputDecoration(
                            label: Text('Type your day'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2025))
                                .then(
                              (value) {
                                notifier.value = value!;
                              },
                            );
                          },
                          child: ValueListenableBuilder(
                            valueListenable: notifier,
                            builder: (context, value, child) {
                              return Text(
                                  "${value.day}/${value.month}/${value.year}");
                            },
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            adde();
                            notecontroller.clear();
                            Navigator.pop(context);
                          },
                          child: Text('Submit')),
                    )
                  ],
                );
              },
            );
          },
          child: Icon(Icons.note_alt_outlined),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: openfir.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final snap = snapshot.data!.docs[index];

                  DateTime date = (snap['date'] as Timestamp).toDate();

                  return ListTile(
                    title: Text(snap['ithem']),
                    subtitle: Row(
                      children: [
                        Text(
                          date.day.toString(),
                        ),
                        Text('/'),
                        Text(date.month.toString()),
                        Text('/'),
                        Text(date.year.toString())
                      ],
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          openfir.doc(snap.id).delete();
                        },
                        icon: Icon(Icons.delete)),
                  );
                },
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('error${snapshot.error}'));
            }
            return CircularProgressIndicator();
          },
        ));
  }
}
// // request.time < timestamp.date(2023, 11, 15);

