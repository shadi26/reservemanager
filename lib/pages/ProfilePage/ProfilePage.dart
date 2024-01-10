import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:reserve/CustomWidgets/ShimmerLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/EditPhoneNumberWidget.dart';
import '../../CustomWidgets/RPSCustomPainter.dart';
import '../../Notifiers/ProfilePictureProvider.dart';
import '../../Notifiers/UserIdProvider.dart';
import '../../Notifiers/SelectedLanguage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../language/language.dart';
import '../../language/language_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDataLoaded = false; // Flag to track if data is loaded

  String userName = 'guest';
  String email = 'Unknown';
  String phone = 'Unknown';
  String language = 'English'; // Replace with the actual language
  String profilePicture = 'https://example.com/profile_picture.jpg';

  TextEditingController userNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  List<String> languageOptions = ['English', 'Arabic', 'Hebrew'];

  @override
  void initState() {
    _isDataLoaded = false; // Initialize the flag
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isDataLoaded = true; // Set the flag when data is loaded

      });
    });
    super.initState();
  }


  // Function to map user data from Firestore to variables
  void _mapUserData(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic>? userData =
    documentSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      setState(() {
        // Map data to variables
        userName = userData['name'] ?? 'guest';
        email = userData['email'] ?? 'Unknown';
        phone = userData['phone'] ?? 'Unknown';
        language = userData['defaultLanguage'] ?? 'English';
        // Map other variables if needed
      });
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

  Future<void> _printUserData() async {
    try {
      DocumentSnapshot documentSnapshot = await _getUserData();
      Map<String, dynamic>? userData =
      documentSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        print('User Data:');
        userData.forEach((key, value) {
          print('$key: $value');
        });
      } else {
        print('User data is null.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    try {
      DocumentSnapshot documentSnapshot = await _getUserData();
      Map<String, dynamic>? userData =
      documentSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        // Fetch and set the profile picture URL
        String fetchedProfilePicture = userData['profilePicture'] ??
            'https://example.com/profile_picture.jpg';
        setState(() {
          profilePicture = fetchedProfilePicture;
        });

        // Map other user data if needed
        _mapUserData(documentSnapshot);
      } else {
        print('User data is null.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFd85f68),
        title: Text(
          selectedLanguage.translate('profile'),
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a shimmer loading effect while data is being fetched
            return !_isDataLoaded?ShimmerLoading.buildProfilePageShimmer(context): _TreeBuild(context);
          } else if (snapshot.hasError) {
            // Handle errors
            return Text('Error: ${snapshot.error}');
          } else {

            // Data fetched successfully, build the UI using snapshot.data
           //final userData = snapshot.data?.data() as Map<String, dynamic>?;
            return _TreeBuild(context);
          }
        },
      ),
    );
  }

  Widget _TreeBuild (BuildContext context){
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Stack(
      children: [
        CustomPaint(
          size: const Size(double.maxFinite, 240),
          painter: RPSCustomPainter(),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 68.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFCCC2C3), // Set the border color to grey
                  width: 5.0, // Set the border width
                ),
              ),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: profilePicture.startsWith('https://example.com/profile_pictur')
                    ? AssetImage('assets/images/user.png')
                    : CachedNetworkImageProvider(profilePicture)
                as ImageProvider<Object>,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 168, left: 130.0),
            child: IconButton(
              onPressed: _pickImage,
              icon:  Image.asset(
                'assets/icons/cameraicon.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 245.0),
            child:Text(
              '$userName',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline, // Add underline
                decorationColor: Color(0xFFd85f68),
                decorationThickness: 0.5,

              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 310.0),
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: buildListTile(
                                Icons.person_2,
                                selectedLanguage.translate('username'),
                                '$userName',
                                    () => editName(
                                    title: selectedLanguage
                                        .translate('editname'),
                                    cancelbtn: selectedLanguage
                                        .translate('cancelbtn'),
                                    savebtn: selectedLanguage
                                        .translate('savebtn')),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child:buildListTile(
                              Icons.phone,
                              selectedLanguage.translate('phone'),
                              phone,
                                  () => editPhone(
                                title: selectedLanguage
                                    .translate('editphonenumber'),
                                cancelbtn:
                                selectedLanguage.translate('cancelbtn'),
                                savebtn:
                                selectedLanguage.translate('savebtn'),
                                onPhoneVerified:
                                onPhoneVerified, // Pass the callback
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: buildListTile(
                                Icons.email,
                                selectedLanguage.translate('email'),
                                email,
                                    () => editEmail(
                                    title: selectedLanguage
                                        .translate('editemail'),
                                    cancelbtn: selectedLanguage
                                        .translate('cancelbtn'),
                                    savebtn: selectedLanguage
                                        .translate('savebtn')),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: buildListTile(
                                Icons.language,
                                selectedLanguage.translate('language'),
                                selectedLanguage.profileSelectedLanguage,
                                    () => editLanguage(
                                    title: selectedLanguage
                                        .translate('editlanguage'),
                                    btn: selectedLanguage
                                        .translate('cancelbtn')),
                              )),
                        ),

                        // Add more details or sections as needed
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  ListTile buildListTile(IconData? icon, String title, String subtitle,
      [Function()? onTap]) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.grey) : null,
      title: Text(
        title,
        style: TextStyle(fontSize: 20, color: Colors.grey, fontFamily: 'Amiri'),
      ),
      subtitle: Text(
        subtitle,
        style:
        TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Amiri'),
      ),
      trailing: onTap != null
          ? IconButton(
        icon: Icon(Icons.edit, color: Color(0xFFD54D57)),
        onPressed: onTap,
      )
          : null,
    );
  }

  void onPhoneVerified(String newPhoneNumber, String verificationId, String smsCode) async {
    try {
      // Get the current user ID using Provider.of
      String? userId = Provider.of<UserIdProvider>(context, listen: false).userId;

      // Ensure userId is not null
      if (userId != null) {
        // Update the phone number in Firebase Authentication
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Update the phone number in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'phone': newPhoneNumber});

        } else {
          // Handle the case where the current user is null
          print('Current user is null');
        }
      } else {
        // Handle the case where userId is null
        print('User ID is null');
      }
    } catch (error) {
      // Log or handle errors gracefully
      print('Error updating phone number: $error');
    }
  }
  void editPhone(
      {required String title,
        required String cancelbtn,
        required String savebtn,
        required Function(String,String,String) onPhoneVerified}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Allow the bottom sheet to take up the full screen height
      builder: (BuildContext context) {
        // Return the widget that you want to show
        return EditPhoneNumberWidget(onPhoneVerified: onPhoneVerified);
      },
    );
  }

  void editEmail(
      {required String title,
        required String cancelbtn,
        required String savebtn}) {
    showEditDialog(
      context: context,
      title: title,
      cancelbtn: cancelbtn,
      savebtn: savebtn,
      controller: emailController,
      inputType: TextInputType.emailAddress,
      validation: isValidEmail,
      onSave: (text) async {
        try {
          // Get the current user ID using Provider.of
          String? userId =
              Provider.of<UserIdProvider>(context, listen: false).userId;

          if (userId != null) {
            // Update the email in Firebase
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'email': text});

            setState(() {
              email = text;
            });
          }
        } catch (error) {
          print('Error updating email: $error');
        }
      },
    );
  }

  void editName(
      {required String title,
        required String cancelbtn,
        required String savebtn}) {
    showEditDialog(
      context: context,
      title: title,
      cancelbtn: cancelbtn,
      savebtn: savebtn,
      controller: userNameController,
      inputType: TextInputType.text,
      onSave: (text) async {
        try {
          // Get the current user ID using Provider.of
          String? userId =
              Provider.of<UserIdProvider>(context, listen: false).userId;

          if (userId != null) {
            // Update the email in Firebase
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'name': text});

            setState(() {
              userName = text;
            });
          }
        } catch (error) {
          print('Error updating email: $error');
        }
      },
    );
  }

  void editLanguage({required String title, required String btn}) {
    List<Language> lanList = Language.languageList();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final selectedLanguage = Provider.of<SelectedLanguage>(context);
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          height: 285, // Adjust the height as needed
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFD54D57), // Red color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          // Navigate back when the icon is clicked
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          'assets/icons/Xbtn.png',
                          width: 16.0, // Set the desired width of the image
                          height: 16.0, // Set the desired height of the image
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 32.0,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    child: Text(selectedLanguage.translate('persoanllanguage'),
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Amiri',
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 40,
                    child: Center(
                      child: DropdownButton2<Language>(
                        isExpanded: true,
                        items: lanList
                            .map<DropdownMenuItem<Language>>(
                              (item) => DropdownMenuItem<Language>(
                            value: item,
                            child: Center(
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
                        value: lanList.firstWhere(
                                (element) =>
                            element.name ==
                                selectedLanguage.profileSelectedLanguage,
                            orElse: () => lanList.first),
                        onChanged: (Language? language) async {
                          if (language != null) {
                            Locale _locale = await setLocale(language.languageCode);
                            Navigator.pop(context);
                            Get.updateLocale(_locale);
                            selectedLanguage.setProfileLanguage(language.name);

                            try {
                              // Get the current user ID using Provider.of
                              String? userId = Provider.of<UserIdProvider>(context,
                                  listen: false)
                                  .userId;

                              if (userId != null) {
                                // Update the email in Firebase
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .update({'defaultLanguage': language.name});

                                setState(() {});
                              }
                            } catch (error) {
                              print('Error updating email: $error');
                            }
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50.0,
                          width: 140.0,
                          padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color(0xFFD54D57),
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
                          width: 140.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
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
                    ),
                  ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  bool isValidEmail(String email) {
    // Simple email validation
    // You can use a more robust email validation logic if needed
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(email);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Convert the image to Uint8List
      Uint8List imageBytes = await pickedFile.readAsBytes();

      // Compress the image
      img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        // Resize the image to your desired dimensions
        image = img.copyResize(image, width: 800); // Adjust width as needed

        // Encode the compressed image to bytes
        imageBytes = img.encodeJpg(image, quality: 85); // Adjust quality as needed

        // Get the current user ID using Provider.of
        String? userId = Provider.of<UserIdProvider>(context, listen: false).userId;

        if (userId != null) {
          // Create a reference to Firebase Storage
          final storageRef = FirebaseStorage.instance.ref();
          final userProfileImageRef = storageRef.child("users/$userId/profile_picture.jpg");

          // Upload the compressed image to Firebase Storage
          try {
            await userProfileImageRef.putData(imageBytes);

            // Retrieve the URL of the uploaded image
            String imageUrl = await userProfileImageRef.getDownloadURL();

            // Update the profile picture URL in Firestore
            await FirebaseFirestore.instance.collection('users').doc(userId).update({'profilePicture': imageUrl});

            // Update local state
            setState(() {
              profilePicture = imageUrl;
              // Update the profile picture URL in your ProfilePictureProvider
              Provider.of<ProfilePictureProvider>(context, listen: false).setProfilePicture(imageUrl);
            });
          } catch (e) {
            print('Error uploading profile picture: $e');
          }
        }
      }
    }
  }


  void showEditDialog({
    required BuildContext context,
    required String title,
    required String cancelbtn,
    required String savebtn,
    required TextEditingController controller,
    required TextInputType inputType,
    bool Function(String)? validation,
    required void Function(String) onSave,
  }) {
    controller.text = '';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFD54D57), // Red color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: 0,
                      top: 0.0,
                      bottom: 2.0,
                      child: IconButton(
                        onPressed: () {
                          // Navigate back when the icon is clicked
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          'assets/icons/Xbtn.png',
                          width: 16.0, // Set the desired width of the image
                          height: 16.0, // Set the desired height of the image
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 32.0,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: 260,
                height: 40,
                child: TextField(
                  controller: controller,
                  keyboardType: inputType,
                  decoration: InputDecoration(
                    hintText: '${title.toLowerCase()}',
                    hintStyle: TextStyle(
                      color: Colors.grey, // Hint text color
                      fontFamily: 'Amiri',
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 50.0),
                    // Adjust vertical padding
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color when not focused
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      // Set border radius here
                      borderSide: BorderSide(
                        color: Colors.black, // Border color when focused
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0,bottom: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (validation != null &&
                            !validation!(controller.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Please enter a valid ${title.toLowerCase()}.',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Colors.red[400]!,
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          onSave(controller.text);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFD54D57), // Background color
                      ),
                      child: Text(
                        savebtn,
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontFamily: 'Amiri',
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

