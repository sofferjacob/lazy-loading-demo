import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/post.dart';
import '../supplemental/post_repository.dart';

part 'data_events.dart';
part 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() : super(DataStateLoading());
  
  List<StreamSubscription> subscriptions = [];
  List<List<Post>> posts = [];
  bool hasMoreData = true;
  DocumentSnapshot lastDoc;
  
  // We use this function to handle events from our streams
  handleStreamEvent(int index, QuerySnapshot snap) {
    // We request 15 docs at a time
    if (snap.docs.length < 15) {
      hasMoreData = false;
    }
    
    // If the snapshot is empty, there's nothing for us to do
    if (snap.docs.isEmpty) return;
    
    if (index == posts.length) {
      // Set the last document we pulled to use as a cursor
      lastDoc = snap.docs[snap.docs.length - 1];
    }
    // Turn the QuerySnapshot into a List of posts
    List<Post> newList = [];
    snap.docs.forEach((doc) {
      // This is a good spot to filter your data if you're not able
      // to compose the query you want.
      newList.add(Post.fromSnapshot(doc.data()));
    });
    // Update the posts list
    if (posts.length <= index) {
      posts.add(newList);
    } else {
      posts[index].clear();
      posts[index] = newList;
    }
    add(DataEventLoad(posts));
  }
  
  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    if (event is DataEventStart) {
      // Clean up our variables
      hasMoreData = true;
      lastDoc = null;
      subscriptions.forEach((sub) {
        sub.cancel();
      });
      posts.clear();
      subscriptions.clear();
      subscriptions.add(
        PostRepository.instance.getPosts().listen((event) { 
          handleStreamEvent(0, event);
        })
      );
      add(DataEventLoad(posts));
    }
    
    if (event is DataEventLoad) {
      // Flatten the posts list
      final elements = posts.expand((i) => i).toList();
      
      if (elements.isEmpty) {
        yield DataStateEmpty();
      } else {
        yield DataStateLoadSuccess(elements, hasMoreData);
      }
    }
    
    if (event is DataEventFetchMore) {
      if (lastDoc == null) {
        throw Exception("Last doc is not set");
      }
      final index = posts.length;
      subscriptions.add(
        PostRepository.instance.getPostsPage(lastDoc).listen((event) {
          handleStreamEvent(index, event);
        })
      );
    }
  }

  @override
  onChange(change) {
    print(change);
    super.onChange(change);
  }

  @override
  Future<void> close() async {
    subscriptions.forEach((s) => s.cancel());
    super.close();
  }
}