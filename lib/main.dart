import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:reserve/Notifiers/AuthProvider.dart';
import 'package:reserve/Notifiers/CheckoutProvider.dart';
import 'package:reserve/Notifiers/CurrentPageProvider.dart';
import 'package:reserve/Notifiers/PaymentMethodNotifier.dart';
import 'package:reserve/Notifiers/SelectedServiceIdProvider.dart';
import 'package:reserve/Notifiers/UserIdProvider.dart';
import 'package:reserve/pages/ProfilePage/ProfilePage.dart';
import 'package:reserve/pages/ServiceSelection/ServiceSelection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Notifiers/ReservationDoneNotifier.dart';
import 'pages/Login/CustomPhoneInputWidget.dart';
import 'Notifiers/DrawerUserName.dart';
import 'Notifiers/LocationSelection.dart';
import 'Notifiers/ProfilePictureProvider.dart';
import 'Notifiers/SelectedLanguage.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'dependency_injection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'uistates/ErrorWidgets.dart';
import 'uistates/LoadingScreenWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../language/language_constants.dart';
import'services/languagesMap.dart';

// Function to load the login status from SharedPreferences
Future<bool> loadLoginStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

Future<void> removeAllReservations() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reservationsCollection = firestore.collection("Reservations");

    QuerySnapshot querySnapshot = await reservationsCollection.get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Delete each document in the collection
      await doc.reference.delete();
    }

    print("All documents in Reservations collection deleted successfully.");
  } catch (e) {
    // Handle errors if necessary
    print("Error deleting documents: $e");
  }
}


// Load defaultLanguage from SharedPreferences
Future<String> loadDefaultLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('defaultLanguage') ?? '';
}

Future<void> addTimestampToReservations() async {
  try {
    // Reference to the Reservations collection
    CollectionReference reservations = FirebaseFirestore.instance.collection('Reservations');

    // Get all documents in the collection
    QuerySnapshot querySnapshot = await reservations.get();

    // Iterate through each document and update with the timestamp
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await reservations.doc(document.id).update({
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    print('Timestamp added to all documents successfully!');
  } catch (e) {
    print('Error adding timestamp to documents: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: const FirebaseOptions(apiKey:'AIzaSyA_3ys2X068NkRaVUlEaJRZWKgJhX66WxE',appId:'1:377758336231:android:394b19fca9f68f7430ce42'
      ,messagingSenderId:'377758336231',projectId:'reserve-cd385',storageBucket: 'reserve-cd385.appspot.com'));
  // update document to servicesInAcity collection
  //addMapToSpecificDocument({"Thursday": ["10:00", "22:00"], "Monday": ["5:00", "20:00"], "Friday": ["11:00", "23:00"], "Sunday": ["8:00", "20:00"], "Wednesday": ["10:00", "19:00"], "Tuesday": ["7:00", "21:00"], "Saturday": ["Closed"]},"بركة شفاعمر");
  usePathUrlStrategy();
  /*                                                                         initialize shared preferences                                                      */
  // Load authentication state before running the app
  await MyAuthProvider().loadAuthenticationState();

  // Load defaultLanguage from SharedPreferences
  String defaultLanguage = await loadDefaultLanguage();

  final userIdProvider = UserIdProvider();
  // Load userId from SharedPreferences
  final savedUserId = await userIdProvider.loadUserIdFromPreferences();
  if (savedUserId != null) {
    // If userId is available, set it in the provider
    userIdProvider.setUserId(savedUserId);
  }

  // Initialize UserNameProvider and load userName from SharedPreferences
  UserNameProvider userNameProvider = UserNameProvider();
  await userNameProvider.loadUserNameFromPreferences();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();
  //loading language from database
  await LanguageMaps.loadDataForLanguages();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiProvider(

    providers: [
      ChangeNotifierProvider(create: (_) => LocationSelectionNotifier()),
      ChangeNotifierProvider(create: (context) => appState),
      ChangeNotifierProvider.value(value: userNameProvider),
      ChangeNotifierProvider(create: (context) => PaymentMethodNotifier()),
      ChangeNotifierProvider(create: (context) => SelectedServiceIdProvider()),
      ChangeNotifierProvider.value(value: userIdProvider),
      ChangeNotifierProvider(create: (context) => MyAuthProvider()),
      ChangeNotifierProvider(create: (context) => SelectedLanguage()),
      ChangeNotifierProvider(create: (context) => CheckoutProvider()),
      ChangeNotifierProvider(create: (context) => CurrentPageProvider()),
      ChangeNotifierProvider(create: (context) => ProfilePictureProvider()),
      ChangeNotifierProvider(create: (context) => ReservationDoneNotifier()),

      // Other providers if any
    ],

    child: MyApp(),

  ));
  // Call getCities and print the result

  DependencyInjection.init();

  //to create a collection servicesInACity
  //await createServicesCollection();
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

 /*
  // Add this method to update the locale
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  */
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  late PersistentTabController _controller;
  late Future<void> dataLoading;
  late ConnectivityResult _connectivityResult;
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0); // Initialize the controller
    _connectivityResult = ConnectivityResult.none; // Initialize with a default value
    dataLoading = loadData();
    checkConnectivity();
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
  }

  Future<void> checkConnectivity() async {
    final connectivity = Connectivity();
    _connectivityResult = await connectivity.checkConnectivity();

    if (_connectivityResult == ConnectivityResult.none) {
      // Handle no internet connectivity here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the PersistentTabController if not already done
    _controller ??= PersistentTabController(initialIndex: 0);

    return GetMaterialApp(
      // Keep existing properties like locale, localizationsDelegates, supportedLocales, etc.
      home: Scaffold(
        body: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(), // Ensure this method returns the list of your screens
          items: _navBarItems(), // Ensure this method returns your navigation items
          // ... other properties for PersistentTabView as required

          // Set the navBarStyle to style12
          navBarStyle: NavBarStyle.style14, // Change this to NavBarStyle.style12
        ),
      ),
    );
  }







  // Replace this function with your actual data-loading function
  Future<void> loadData() async {
    // Simulate loading data
    await Future.delayed(Duration(seconds: 2));
  }


  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    FlutterFlowTheme.saveThemeMode(mode);
  });

  List<PersistentBottomNavBarItem> _navBarItems() {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset(
          'assets/icons/services.png',
          width: 40,  // Set the width as per your requirement
          height: 40,  // Set the height as per your requirement
        ),
        title: selectedLanguage.translate("MyServices"),
        inactiveColorPrimary: Colors.black,
        activeColorPrimary: Color(0xFFD54D57),
      ),

      PersistentBottomNavBarItem(
        icon: Image.asset(
          'assets/icons/booking.jpg',
          width: 40,  // Set the width as per your requirement
          height: 40,  // Set the height as per your requirement
        ),
        title: selectedLanguage.translate("bookings"),
        inactiveColorPrimary: Colors.black,
        activeColorPrimary: Color(0xFFD54D57),
      ),


      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_2_outlined), // Use either Icons.person or Icons.account_circle
        title: selectedLanguage.translate("profile"),
        inactiveColorPrimary: Colors.black,
        activeColorPrimary: Color(0xFFD54D57),
      ),
    ];
  }

  List<Widget> _buildScreens() {
    return [
      ReservationPage1Widget(),
      CurrentReservationsWidget(),
      ProfilePage()
    ];
    //... Your existing _buildScreens code ...
  }
}
