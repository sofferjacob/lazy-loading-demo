import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String title;
  final String author;
  
  const Post(this.title, this.author);

  factory Post.fromSnapshot(Map data) {
    return Post(data['title'], data['author']);
  }
  
  @override
  List<Object> get props => [title, author];
}