import 'package:flutter/material.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await authProvider.getToken();

      if (authProvider.token != null) {
        await userProvider.fetchUserProfile(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : user != null
              ? SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user['avatarUrl'] != null
                                ? NetworkImage(user['avatarUrl'])
                                : null,
                            child: user['avatarUrl'] == null
                                ? Icon(Icons.person, size: 40)
                                : null,
                          ),
                          SizedBox(width: 50),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? "N/A",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text("Role: ${user['role'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey)),
                              Text("Email: ${user['email'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey)),
                              Text("Age: ${user['age'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                  "Status: ${user['status'] == 1 ? 'Active' : 'Inactive'}",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                  "Quiz Attempts: ${user['numberOfQuizAttempt'] ?? 0}",
                                  style: TextStyle(color: Colors.grey)),
                              Text("Created: ${user['createdTime'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                  "Last Updated: ${user['lastUpdatedTime'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    showEditUserModal(context, user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Edit"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Center(child: Text("No user data available")),
    );
  }

  void showEditUserModal(BuildContext context, Map<String, dynamic> user) {
    TextEditingController nameController =
        TextEditingController(text: user['name'] ?? "");
    TextEditingController ageController =
        TextEditingController(text: user['age']?.toString() ?? "");
    TextEditingController phoneController =
        TextEditingController(text: user['phoneNumber'] ?? "");
    TextEditingController avatarController =
        TextEditingController(text: user['avatarUrl'] ?? "");

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit User"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Name cannot be empty" : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: "Age"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return "Age cannot be empty";
                      int? age = int.tryParse(value);
                      if (age == null || age < 1 || age > 150) {
                        return "Invalid age";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: avatarController,
                    decoration: InputDecoration(labelText: "Avatar URL"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);

                  await userProvider.updateUser(
                    authProvider.token!,
                    user['id'],
                    nameController.text,
                    int.parse(ageController.text),
                    phoneController.text,
                    avatarController.text,
                    context,
                  );

                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
