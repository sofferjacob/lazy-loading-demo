part of 'data_bloc.dart';

abstract class DataState extends Equatable {
  const DataState();
  
  @override
  List<Object> get props => [];
}

class DataStateLoading extends DataState {}

class DataStateEmpty extends DataState {}

class DataStateLoadSuccess extends DataState {
  final List<Post> posts;
  final bool hasMoreData;
  
  const DataStateLoadSuccess(this.posts, this.hasMoreData);
  
  @override
  List<Object> get props => [posts];
}