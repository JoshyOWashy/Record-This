import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:record_this/screens/add.dart';
import 'package:record_this/screens/details.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  Future<Object?> databaseQuery() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("collection/albums");

    DatabaseEvent event = await ref.once();

    // check if query returned with nothing
    if (!event.snapshot.exists) {
      return [];
    }
    return event.snapshot.value;
  }

  /*
   TODO: 
    - do something with search results
    - add nice display for collection
    - add route to results page when clicking on an album
    - if collection is empty make user add an album and make it nice
  */
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    List<String> albumList = [];
    List data = [];
    List<AlbumDisplay> albumCollection = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Collection'),
        actions: [
          //add an album
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPage()),
                );
              }),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              if (data.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                        title: Text('No Albums in Collection'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('You have no albums in your collection.'),
                              Text("Press the '+' button to add an album"),
                            ],
                          ),
                        )));
              } else {
                await showSearch(
                    context: context,
                    delegate: MySearchDelegate(
                      albumList: albumList,
                      collection: data,
                    ));
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: databaseQuery(),
          builder: (context, snapshot) {
            // data is loaded from query
            if (snapshot.hasData) {
              data = snapshot.data as List<dynamic>;

              //query returns with nothing
              if (data.isEmpty) {
                return Center(
                    child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text('You have no albums in your collection.'),
                              Text("Press the '+' button to add an album"),
                              SizedBox(height: 10),
                            ]),
                          ),
                        )));
              }

              // add album titles to list for search suggestions
              // and create a widget for each
              for (var album in data) {
                albumList.add(album['title'].toString());

                albumCollection.add(AlbumDisplay(album: album));
              }

              // query has data so show albums
              return Column(
                children: [
                  Center(
                    child: Wrap(
                      children: albumCollection,
                    ),
                  ),
                ],
              );
            }

            // when query returns with an error
            else if (snapshot.hasError) {
              return Center(
                  child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            Text("Error: ${snapshot.error}"),
                            const SizedBox(height: 10),
                          ]),
                        ),
                      )));
            }

            // show loading symbol while data is still being loaded
            else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate({required this.albumList, required this.collection});
  List<String> albumList;
  List collection;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, "");
            }
            query = '';
          })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ""));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        query,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = albumList.where((album) {
      final result = album.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final album = suggestions[index];

        return ListTile(
          title: Text(album),
          onTap: () {
            query = album;

            showResults(context);
          },
        );
      },
    );
  }
}

class AlbumDisplay extends StatelessWidget {
  final dynamic album;
  const AlbumDisplay({super.key, required this.album});
  @override
  Widget build(BuildContext context) {
    final title = album["title"].toString();
    final albumArt = album["albumArt"].toString();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text("albumArt: $albumArt"),
        Text("title: $title"),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(album: album)),
              );
            },
            child: const Text("View"))
      ]),
    );
  }
}
