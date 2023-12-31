import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:record_this/classes/search_album.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  Future<Object?> discogQuery() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("collection/albums");

    DatabaseEvent event = await ref.once();

    // check if query returned with nothing
    if (!event.snapshot.exists) {
      return [];
    }
    return event.snapshot.value;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final artistController = TextEditingController();
    final releaseYearController = TextEditingController();
    final labelController = TextEditingController();

    /*
      TODO:
        add options for label, year, possibly other things
    */
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Album'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //title input
              const Text("Title"),
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              //artist input
              const Text("Artist"),
              TextFormField(
                controller: artistController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an artist';
                  }
                  return null;
                },
              ),

              //optional additions
              const SizedBox(height: 24),
              const Text(
                "Optional",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              //relase year input
              const Text("Release Year"),
              TextFormField(
                controller: releaseYearController,
              ),
              const SizedBox(height: 24),

              //record label input
              const Text("Record Label"),
              TextFormField(
                controller: labelController,
              ),
              const SizedBox(height: 24),

              //submit button
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final title = titleController.text;
                      final artist = artistController.text;

                      /* 
                        TODO:

                          Send the data to the confirmation page

                      */

                      // SearchAlbum(title, artist);
                    }
                  },
                  child: const Text("Search"))
            ]),
          ),
        ));
  }
}
