import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record_this/classes/album_display.dart';
import 'package:record_this/classes/search_delegate.dart';
import 'package:record_this/screens/add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  Future<List> newDatabaseQuery() async {
    final db = FirebaseFirestore.instance;
    List albums = [];

    await db.collection("albums").get().then((event) {
      if (event.docs.isEmpty) {
        return albums;
      }

      for (var doc in event.docs) {
        albums.add(doc.data());
      }
    });
    return albums;
  }

  /*
   TODO: 
    - make everything look actually nice
  */
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    List<String> albumList = [];
    List data = [];
    List<Widget> albumCollection = [];

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
          future: newDatabaseQuery(),
          builder: (context, snapshot) {
            // data is loaded from query
            if (snapshot.hasData) {
              //query returns with nothing
              if (listEquals(snapshot.data, [])) {
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
              // add albums to a list to when searching for specific album
              // and create a widget for each album
              final List snapshotData;
              snapshotData = snapshot.data as List;
              for (var album in snapshotData) {
                data.add(album);
                albumList.add(album['title'].toString());
                albumCollection.add(Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AlbumDisplay(
                      album: album,
                      albumID: album["id"].toString(),
                      detailOption: "collectionView"),
                ));
              }

              // query has data so show albums
              return Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Center(
                        child: Wrap(
                          children: albumCollection,
                        ),
                      ),
                    ],
                  ),
                ),
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
