import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/settings_page.dart';
import 'package:chatapp/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreServices _firestoreServices = FirestoreServices();

  void signUserOut() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      // Cập nhật trạng thái thành Offline
      await _firestoreServices.updateUserStatus(currentUser.uid, "Offline");
    }
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //logo
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _firebaseAuth.currentUser?.email ?? "No email",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 50,
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: Text("HOME"),
                  leading: Icon(
                    Icons.home,
                    size: 30,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: Text("SETTINGS"),
                  leading: Icon(
                    Icons.settings,
                    size: 30,
                  ),
                  onTap: () {
                    //pop the drawer
                    Navigator.pop(context);

                    //navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 25),
            child: ListTile(
              title: Text("LOGOUT"),
              leading: Icon(
                Icons.logout,
                size: 30,
              ),
              onTap: signUserOut,
            ),
          ),
        ],
      ),
    );
  }
}
