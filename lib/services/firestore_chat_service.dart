import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hys/models/all_message_model.dart';

class FirestoreChatServices {

    static Stream<List<AllMessageModel>> allChatStream(String userID){
    try{
      return FirebaseFirestore.instance.collection("messages").where('userid', isEqualTo:  userID)
            .snapshots()
            .map((notes){
          final List<AllMessageModel> notesFromFirestore = <AllMessageModel>[];
          for(final DocumentSnapshot<Map<String,dynamic>> doc in notes.docs){
            notesFromFirestore.add(AllMessageModel.fromDocumentSnapshot(doc:doc));
          }
          return notesFromFirestore;
        });
    } catch(e){
      rethrow;
    }
  }

}