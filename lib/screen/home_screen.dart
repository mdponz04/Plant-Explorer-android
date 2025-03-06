import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'plant_detail_screen.dart';
import 'quizzes_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Mặc định ở Home

  // Hàm xử lý khi nhấn vào BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScanScreen()),
        );
        break;
      case 1:
        // Home, không cần chuyển trang
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizzesScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Explorer'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Mở Profile Screen khi nhấn vào icon Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explore Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_forward),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(3, (index) {
                  return GestureDetector(
                    onTap: () {
                      // Mở màn hình chi tiết Plant khi nhấn vào 1 Plant Card
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         PlantDetailScreen(plantName: "Plant ${index + 1}"),
                      //   ),
                      // );
                    },
                    child: _buildPlantCard("Plant ${index + 1}"),
                  );
                }),
              ),
            ),

            SizedBox(height: 20),

            // Quizzes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quizzes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_forward),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(3, (index) {
                  return _buildQuizCard("Quiz ${index + 1}");
                }),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quizzes"),
        ],
      ),
    );
  }

  // Widget for Plant Card
  Widget _buildPlantCard(String plantName) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.image, size: 30, color: Colors.grey),
          ),
          SizedBox(height: 5),
          Text(plantName, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Widget for Quiz Card
  Widget _buildQuizCard(String quizName) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey),
            SizedBox(height: 5),
            Text(quizName, style: TextStyle(fontSize: 14)),
            Text("1 Point", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
