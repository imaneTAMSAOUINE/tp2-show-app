import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/show.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Show>> futureShows;

  @override
  void initState() {
    super.initState();
    futureShows = ApiService().fetchShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              title: Text('Add Show'),
              onTap: () {
                Navigator.pushNamed(context, '/add_show');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Show>>(
        future: futureShows,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  leading: Image.network(snapshot.data![index].image),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load shows'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}