import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_explore/model/plant.dart';
import 'package:plant_explore/model/quiz.dart';
import 'package:plant_explore/model/favoritePlant.dart';
import 'package:plant_explore/core/providers/home_provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';

import 'profile_screen.dart';
import 'scan_screen.dart';
import 'plant_detail_screen.dart';
import 'quizzes_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  // @override
  // Widget build(BuildContext context) {
  //   final authProvider = context.watch<AuthProvider>();
  //   final homeProvider = context.watch<HomeProvider>();

  //   return Scaffold(
  //     appBar: _buildAppBar(authProvider),
  //     body: homeProvider.isLoading
  //         ? Center(child: CircularProgressIndicator())
  //         : _buildContent(homeProvider),
  //     bottomNavigationBar: _buildBottomNavigationBar(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: _buildAppBar(authProvider),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reload all data when the user pulls down to refresh
          await Future.wait([
            homeProvider.fetchPlants(),
            homeProvider.fetchQuizzes(),
            homeProvider.fetchFavoritePlants(),
          ]);
        },
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(homeProvider),
      ),
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
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
      ],
    );
  }

  // Widget _buildContent(HomeProvider homeProvider) {
  //   return SingleChildScrollView(
  //     padding: EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSection("Plants", homeProvider.plants, _buildPlantCard),
  //         _buildSection("Quizzes", homeProvider.quizzes, _buildQuizCard),
  //         _buildSection(
  //             "Favorite Plants", homeProvider.favoritePlants, _buildFavoritePlantCard),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildContent(HomeProvider homeProvider) {
  return SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(), // Ensure it's always scrollable
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection("Plants", homeProvider.plants, _buildPlantCard),
        _buildSection("Quizzes", homeProvider.quizzes, _buildQuizCard),
        _buildSection(
            "Favorite Plants", homeProvider.favoritePlants, _buildFavoritePlantCard),
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
          Text(plant.name, style: TextStyle(fontSize: 14)),
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
          quiz.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    quiz.imageUrl,
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

Widget _buildFavoritePlantCard(Favoriteplant plant) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.topRight,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.pink[100], // Pink background for favorites
            child: Icon(
              Icons.local_florist,
              size: 30,
              color: Colors.pink, // Pink icon color
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                size: 16,
                color: Colors.red, // Red heart to indicate favorite
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 5),
      Text(
        plant.plantName,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quizzes"),
      ],
    );
  }
}
