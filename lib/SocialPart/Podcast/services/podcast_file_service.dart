import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hys/SocialPart/Podcast/constants/app_data.dart';
import 'package:hys/models/podcast_bg_file_model.dart';

class PodcastFileService{

  static Future<List<PodcastBgFile>> allBackgroundMusic(){



    final List<PodcastBgFile> notesFromFirestore = <PodcastBgFile>[];
    try{
        FirebaseFirestore.instance.collection(AppData.podcastFileNode).get().then((value){
          for(final DocumentSnapshot<Map<String,dynamic>> doc in value.docs){
            notesFromFirestore.add(PodcastBgFile.fromDocumentSnapshot(doc:doc));
          }
          return notesFromFirestore;
        }).onError((error, stackTrace) {
          return notesFromFirestore;
        });
    } catch(e){
      rethrow;
    }
  }


}