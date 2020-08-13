import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SqliteHelper.dart';

void main() => runApp(MaterialApp(
    home: MyApp()
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String url = 'https://jsonplaceholder.typicode.com/posts';
  final sqlHelp = SqliteHelper();

  getAllPost() async{
    await sqlHelp.open();
    return await sqlHelp.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.http),
        onPressed: () async {
          await sqlHelp.open();
          var resp = await http.get(url);
          List l = jsonDecode(resp.body);
          l.forEach((el) async {
            return await sqlHelp.insert(el);
          });
          setState(() {});
      }),
      appBar: AppBar(
        title: Text('SQLite example'),
      ),
      body: FutureBuilder(
        future: getAllPost(),
        builder: (context, snap) {
          if (snap.hasData) {
            List l = snap.data;
            return ListView.builder(
              itemCount: l.length,
              itemBuilder: (context, idx) {
                return InkWell(
                  onTap: () async {
                    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('已刪除！')));
                    await sqlHelp.delete(l[idx]['id']);
                    setState(() {});
                  },
                  child: ListTile(
                    leading: Icon(Icons.local_post_office),
                    title: Text(l[idx]['title']),
                  )
                );
              }
            );
          }
          return Container();
      }),
    );
  }
}

