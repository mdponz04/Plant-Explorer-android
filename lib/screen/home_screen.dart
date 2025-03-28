import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_explore/model/plant.dart';
import 'package:plant_explore/model/quiz.dart';
import 'package:plant_explore/core/providers/home_provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';

import 'profile_screen.dart';
import 'scan_screen.dart';
import 'plant_detail_screen.dart';
import 'quizzes_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.fetchPlants();
      homeProvider.fetchQuizzes();
      homeProvider.fetchFavoritePlants();
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _navigateToScreen(ScanScreen());
    if (index == 2) _navigateToScreen(QuizzesScreen());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: _buildAppBar(authProvider),
      body: homeProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(homeProvider),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      title: Text('Plant Explorer'),
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () => _navigateToScreen(ProfileScreen()),
        ),
        authProvider.token == null
            ? IconButton(
                icon: Icon(Icons.login),
                onPressed: () => _navigateToScreen(LoginScreen()),
              )
            : IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  authProvider.logout();
                },
              ),
      ],
    );
  }

  Widget _buildContent(HomeProvider homeProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection("Plants", homeProvider.plants, _buildPlantCard),
          _buildSection("Quizzes", homeProvider.quizzes, _buildQuizCard),
          _buildSection("Favorite Plants", homeProvider.favoritePlants,
              _buildFavoritePlantCard),
        ],
      ),
    );
  }

  Widget _buildSection<T>(
      String title, List<T> items, Widget Function(T) itemBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        SizedBox(height: 10),
        items.isEmpty
            ? Center(child: Text("No $title available"))
            : _buildListView(items, itemBuilder),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Icon(Icons.arrow_forward),
      ],
    );
  }

  Widget _buildListView<T>(List<T> items, Widget Function(T) itemBuilder) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(items[index]),
        separatorBuilder: (_, __) => SizedBox(width: 10),
      ),
    );
  }

  Widget _buildPlantCard(Plant plant) {
    return GestureDetector(
      onTap: () => _navigateToScreen(PlantDetailScreen(plant: plant)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.local_florist, size: 30, color: Colors.green),
          ),
          SizedBox(height: 5),
          Text(plant.scientificName, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFavoritePlantCard(Plant plant) {
    return GestureDetector(
      onTap: () => _navigateToScreen(PlantDetailScreen(plant: plant)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.favorite,
                size: 30, color: Colors.red), // Default icon
          ),
          SizedBox(height: 5),
          Text(
            plant.scientificName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    quiz.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.broken_image, size: 20, color: Colors.grey),
                  ),
                )
              : Icon(Icons.quiz, size: 40, color: Colors.grey),
          SizedBox(height: 5),
          Text(
            quiz.name ?? "Unnamed Quiz",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text("1 Point", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_sharp), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded), label: "Quizzes"),
      ],
    );
  }
}
