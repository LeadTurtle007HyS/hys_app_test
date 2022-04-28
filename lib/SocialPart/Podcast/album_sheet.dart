import 'package:flutter/material.dart';
import 'package:hys/database/crud.dart';
import 'package:hys/models/podcast_album_model.dart';

class AlbumSheet extends StatefulWidget {
  const AlbumSheet({
    Key key,
  }) : super(key: key);

  @override
  State<AlbumSheet> createState() => _AlbumSheetState();
}

class _AlbumSheetState extends State<AlbumSheet> {
  CrudMethods crudobj = CrudMethods();
  TextEditingController _textFieldController = TextEditingController();
  String codeDialog;
  String valueText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    createAlbum(String albumName) {
      //  crudobj.createAlbum(albumName);
    }

    Future<void> _displayTextInputDialog(BuildContext context) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Create Album'),
              content: TextField(
                onChanged: (value) {
                  valueText = value;
                },
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Enter album name"),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      valueText = "";
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    createAlbum(valueText);
                    valueText = "";
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }

    return new Scaffold(
      appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            "Album",
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          )),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<List<PodcastAlbumModel>>(
          //    stream: crudobj.allAlbumList(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<PodcastAlbumModel>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData && snapshot.data.length > 0) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    PodcastAlbumModel podcastAlbumModel = snapshot.data[index];
                    return Card(
                        color: Color.fromRGBO(88, 165, 196, 1),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop(podcastAlbumModel);
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              podcastAlbumModel.coverImage,
                            ),
                          ),
                          title: Text(podcastAlbumModel.albumName,
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                          subtitle: Text("",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              )),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                          ),
                        ));
                  },
                );
              } else {
                return InkWell(
                    onTap: () {
                      _displayTextInputDialog(context);
                    },
                    child: Center(
                        child: Row(
                      children: [
                        const Text(
                          "You don't have any album. Create a album",
                          style: TextStyle(
                              color: Color.fromRGBO(7, 120, 168, 1.0),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: Color.fromRGBO(7, 120, 168, 1.0),
                          size: 30,
                        )
                      ],
                    )));
              }
            }
          },
        ),
      ),
    );
  }
}
