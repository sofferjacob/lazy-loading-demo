import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data_bloc/data_bloc.dart';

class LazyListScreen extends StatefulWidget {
  @override
  createState() => _LazyListScreenState();
}

class _LazyListScreenState extends State<LazyListScreen> {
  DataBloc _dataBloc = DataBloc();
  
  @override
  initState() {
    super.initState();
    _dataBloc.add(DataEventStart());
  }
  
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
        title: Text('Posts'),
     ),
     
     body: BlocBuilder<DataBloc, DataState>(
        cubit: _dataBloc,
        builder: (BuildContext context, DataState state) {
          if (state is DataStateLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DataStateEmpty) {
              return Center(
                child: Text('No Posts', style: Theme.of(context).textTheme.bodyText1,),
              );
          } else if (state is DataStateLoadSuccess) {
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
              itemCount: state.hasMoreData ? state.posts.length + 1 : state.posts.length,
              itemBuilder: (context, i) {
                if (i >= state.posts.length) {
                  _dataBloc.add(DataEventFetchMore());
                  return Container(
                    margin: EdgeInsets.only(top: 15),
                    height: 30,
                    width: 30,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return ListTile(
                  title: Text(state.posts[i].title),
                  subtitle: Text(state.posts[i].author),
                );
              },
              separatorBuilder: (context, i) {
                return Divider();
              }
            );
          }
        }
     ),
   ); 
  }

  @override
  void dispose() { 
    _dataBloc.close();
    super.dispose();
  }
  
}