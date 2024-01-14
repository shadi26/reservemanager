import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve/Notifiers/DrawerUserName.dart';
import '../Notifiers/AuthProvider.dart';
import '../Notifiers/ProfilePictureProvider.dart';
import '../Notifiers/UserIdProvider.dart';
import '../language/language.dart';
import '../language/language_constants.dart';
import 'package:get/get.dart';
import '../Notifiers/SelectedLanguage.dart'; // Import SelectedLanguage notifier
import 'CustomConfirmationDialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomDrawer extends StatefulWidget {
  final bool isAuthenticated;


  CustomDrawer({
    Key? key,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<Language> lanList = Language.languageList();
  String profilePicture = 'https://example.com/profile_picture.jpg';
  late String? imageUrl='https://firebasestorage.googleapis.com/v0/b/reserve-cd385.appspot.com/o/images%2F1.jpg?alt=media&token=0ca1ee8a-029c-4ec0-9af4-d755d4ac8619';


  Future<String?> getDownloadUrl(String imagePath) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref(imagePath);
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  void fetchData() async {

    if (imageUrl != null) {
      // Do something with the download URL, such as displaying the image
      print('Download URL: $imageUrl');
    } else {
      // Handle the case where the download URL couldn't be retrieved
      print('Failed to retrieve download URL');
    }
  }


  // Function to get user data from Firestore
  Future<DocumentSnapshot> _getUserData() async {
    // Get the user ID from the provider
    String? userId = context.read<UserIdProvider>().userId;

    // Check if the user ID is not null
    if (userId != null) {
      // Reference to the users collection in Firestore
      CollectionReference users =
      FirebaseFirestore.instance.collection('users');

      // Get the document snapshot for the specific user ID
      return await users.doc(userId).get();
    } else {
      throw Exception('User ID is null');
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    imageUrl=await getDownloadUrl('/images/1.jpg');


    try {
      DocumentSnapshot documentSnapshot = await _getUserData();
      Map<String, dynamic>? userData =
      documentSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        // Fetch and set the profile picture URL using the provider
        String fetchedProfilePicture =
            userData['profilePicture'] ?? 'https://example.com/profile_picture.jpg';
        // Access the provider and set the new profile picture
        Provider.of<ProfilePictureProvider>(context, listen: false)
            .setProfilePicture(fetchedProfilePicture);


      } else {
        print('User data is null.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use Provider.of to access the value from UserNameProvider
    final userNameProvider = Provider.of<UserNameProvider>(context, listen: false);

    return Consumer<SelectedLanguage>(
      builder: (context, selectedLanguage, child) {
        final myAuthProvider = Provider.of<MyAuthProvider>(context);
        //
        return Drawer(
          width: 255,
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  stops: [0.65, 0.35], // Adjust these values
                  colors: [
                    const Color(0xFFD54D57).withOpacity(0.9),
                    Colors.white.withOpacity(0.1),
                  ],
                )
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white, // Set the color of the border
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Consumer<ProfilePictureProvider>(
                              builder: (context, profilePictureProvider, _) => CircleAvatar(
                                radius: 40,
                                backgroundImage: profilePictureProvider.profilePicture.startsWith('https://example.com')
                                    ? AssetImage('assets/images/user.png') as ImageProvider<Object>
                                    : CachedNetworkImageProvider(profilePictureProvider.profilePicture)
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 115,
                          child: Text(
                            userNameProvider.userName != ''
                                ? selectedLanguage.translate(userNameProvider.userName)
                                : selectedLanguage.translate('guest'),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Amiri',
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    if (widget.isAuthenticated) {
                      // Sign out logic
                      ConfirmationDialog.show(
                        context: context,
                        title: selectedLanguage.translate('logout'),
                        content: selectedLanguage.translate('logoutConfirmationText'),
                        confirmButtonText: selectedLanguage.translate('yesbtn'),
                        cancelButtonText: selectedLanguage.translate('nobtn'),
                        onConfirm: () {
                          // Perform logout logic
                          myAuthProvider.signOut(context);
                          Navigator.pop(context);
                        },
                      );

                    } else {
                      // Sign in logic
                      myAuthProvider.signIn(context);
                    }
                  },
                ),
                ListTile(
                 title: Padding(
                   padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                   child: Divider(
                      color: Colors.white,  // You can customize the color of the divider
                      thickness: 1.0,       // You can adjust the thickness of the divider
                      indent: 10.0,        // You can add an indentation to the divider
                      endIndent: 10.0,     // You can add an end indentation to the divider
                    ),
                 ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.login,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        myAuthProvider.isAuthenticated
                            ? selectedLanguage.translate('logout')
                            : selectedLanguage.translate('login'),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Amiri',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (widget.isAuthenticated) {
                      // Sign out logic
                      ConfirmationDialog.show(
                        context: context,
                        title: selectedLanguage.translate('logout'),
                        content: selectedLanguage.translate('logoutConfirmationText'),
                        confirmButtonText: selectedLanguage.translate('yesbtn'),
                        cancelButtonText: selectedLanguage.translate('nobtn'),
                        onConfirm: () {
                          // Perform logout logic
                          myAuthProvider.signOut(context);
                          Navigator.pop(context);
                        },
                      );

                    } else {
                      // Sign in logic
                      myAuthProvider.signIn(context);
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        selectedLanguage.translate('profile'),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Amiri',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final myAuthProvider = Provider.of<MyAuthProvider>(context, listen: false);
                    if ( ! myAuthProvider.isAuthenticated ) {
                      // User ID is null, navigate to CustomPhoneInputWidget
                    } else {
                      // User ID is not null, navigate to ProfilePage
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.list,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      DropdownButton2<Language>(
                        isExpanded: true,
                        items: lanList
                            .map<DropdownMenuItem<Language>>(
                              (item) => DropdownMenuItem<Language>(
                            value: item,
                            child: Directionality(
                              textDirection: selectedLanguage.selectedLanguage == 'English'
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Amiri',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        value: lanList.firstWhere((element) => element.name == selectedLanguage.selectedLanguage, orElse: () => lanList.first),
                        onChanged: (Language? language) async {
                          if (language != null) {
                            Locale _locale = await setLocale(language.languageCode);
                            Navigator.pop(context);
                            Get.updateLocale(_locale);
                            selectedLanguage.setLanguage(language.name);

                          }
                        },

                        buttonStyleData: ButtonStyleData(
                          height: 50.0,
                          width: 100.0,
                          padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),

                            color: Colors.transparent,
                          ),
                          elevation: 0,
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Colors.white,
                          iconDisabledColor: Colors.white,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFD54D57).withOpacity(0.9),
                          ),
                          offset: const Offset(0, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(20),
                            thickness: MaterialStateProperty.all<double>(4),
                            thumbVisibility: MaterialStateProperty.all<bool>(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 30,
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                ListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        selectedLanguage.translate("privacyterms"),
                        style: TextStyle(
                          fontFamily: 'amiri',
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    //CreditCardEntryDialog.showCreditCardEntryDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
