import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'add_show_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// Notificateur global pour le rafraîchissement
class AppRefreshNotifier {
  static final ValueNotifier<bool> refreshHome = ValueNotifier(false);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> movies = [];
  List<dynamic> anime = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupRefreshListener();
    fetchShows();
  }

  @override
  void dispose() {
    AppRefreshNotifier.refreshHome.removeListener(_handleRefresh);
    super.dispose();
  }

  void _setupRefreshListener() {
    AppRefreshNotifier.refreshHome.addListener(_handleRefresh);
  }

  void _handleRefresh() {
    if (AppRefreshNotifier.refreshHome.value) {
      fetchShows();
      AppRefreshNotifier.refreshHome.value = false;
    }
  }

  Future<void> fetchShows() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/shows'));

      if (response.statusCode == 200) {
        List<dynamic> allShows = jsonDecode(response.body);

        setState(() {
          movies = allShows.where((show) => show['category'] == 'movie').toList();
          anime = allShows.where((show) => show['category'] == 'anime').toList();
          series = allShows.where((show) => show['category'] == 'serie').toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar("Error loading shows: ${e.toString()}");
    }
  }

  Future<void> deleteShow(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/shows/$id'));

      if (response.statusCode == 200) {
        fetchShows(); // Refresh list after deletion
        _showSuccessSnackbar("Show deleted successfully");
      } else {
        throw Exception('Failed to delete show');
      }
    } catch (e) {
      _showErrorSnackbar("Error deleting show: ${e.toString()}");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Show"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteShow(id);
            },
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildShowList(List<dynamic> shows) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shows.isEmpty) {
      return const Center(
        child: Text(
          "No Shows Available",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchShows,
      child: ListView.builder(
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return Dismissible(
            key: Key(show['id'].toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              confirmDelete(show['id']);
              return false; // Prevent automatic dismissal
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    ApiConfig.baseUrl + show['image'],
                  ),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(Icons.broken_image),
                ),
                title: Text(
                  show['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(show['description']),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildShowList(movies);
      case 1:
        return _buildShowList(anime);
      case 2:
        return _buildShowList(series);
      default:
        return const Center(child: Text("Unknown Page"));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show App"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchShows,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddShowPage(
                      onShowAdded: () {
                        AppRefreshNotifier.refreshHome.value = true;
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddShowPage(
              onShowAdded: () {
                AppRefreshNotifier.refreshHome.value = true;
              },
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}