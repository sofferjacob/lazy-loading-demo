import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepository {
  // Singleton boilerplate
  PostRepository._();
  
  static PostRepository _instance = PostRepository._();
  static PostRepository get instance => _instance;
  
  // Instance
  final CollectionReference _postCollection = FirebaseFirestore.instance.collection('posts');
  
  Stream<QuerySnapshot> getPosts() {
   return _postCollection
      .limit(15)
      .snapshots();
  }
  
  Stream<QuerySnapshot> getPostsPage(DocumentSnapshot lastDoc) {
    return _postCollection
        .startAfterDocument(lastDoc)
        .limit(15)
        .snapshots();
  }
}