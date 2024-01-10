import 'package:cloud_firestore/cloud_firestore.dart';
import '../../CustomWidgets/CustomDrawer.dart';
import 'package:reserve/CustomWidgets/ShimmerLoading.dart';
import '../../CustomWidgets/MyCarouselWithDots.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/LocationSelection.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../CustomWidgets/ExpandableListContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../CustomWidgets/CustomeDropdownMenu.dart';
import'../../Notifiers/SelectedLanguage.dart';
import '../../CustomWidgets/CustomCircularImageSlider.dart';



List<dynamic> imageUrls = [
  // Add more image URLs here
];
List<dynamic> cityImageUrls=[

];



late String currentCity ;

class ReservationpageWidget extends StatefulWidget {
  final String data;

  const ReservationpageWidget({Key? key, required this.data}) : super(key: key);

  @override
  _ReservationpageWidgetState createState() => _ReservationpageWidgetState();
}

class _ReservationpageWidgetState extends State<ReservationpageWidget> {
  List<List<Map<String, dynamic>>> serviceList = [];
  late String currentCity;
  List<String>citiesMenu =["shefaamr",'tamra'];
  late String? selectedCity;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<GlobalKey<ExpandableListContainerState>> expandableListKeys = [];
  ScrollController _scrollController = ScrollController(); // Add this line
  final Map<String, double> headlineOffsets = {};
  bool _isDataLoaded = false;
  double offset = 200.0;
  List<String> imageAssetPaths = [];
  List<String> serviceNames = [];



  void initState() {
    super.initState();

    initializeData();
  }

  void initializeData() {
    // Access the selected location from the LocationSelectionNotifier
    currentCity = context.read<LocationSelectionNotifier>().selectedLocation;
    selectedCity = currentCity;

    initializeExpandableListKeys();
    initializeImageUrls();

    fetchCityNames().then((cities) {
      setState(() {
        citiesMenu = cities;
      });
    });

    fetchDataAndOrganize(selectedCity ?? "").then((result) {
      setState(() {
        serviceList = result;
        initializeHeadlineOffsets();
      });
    });

    fetchCircularImageSliderData(selectedCity ?? "").then((result) {
      setState(() {
        // Convert dynamic lists to lists of strings
        imageAssetPaths = (result['imageAssetPaths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        serviceNames = (result['serviceNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

      });
    });
  }

  Future<Map<String, List<dynamic>>> fetchCircularImageSliderData(
      String city) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('circularImageSlider')
        .limit(1) // Limit to the first document
        .get();

    Map<String, List<dynamic>> circularImageSliderData = {
      'imageAssetPaths': [],
      'serviceNames': [],
    };

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      circularImageSliderData['imageAssetPaths'] = data['imageAssetPaths'];
      circularImageSliderData['serviceNames'] = data['serviceNames'];
    }

    return circularImageSliderData;
  }

  void initializeExpandableListKeys() {
    for (int i = 0; i < 3; i++) {
      GlobalKey<ExpandableListContainerState> containerKey =
      GlobalKey<ExpandableListContainerState>();
      expandableListKeys.add(containerKey);
    }
  }
  void initializeImageUrls() {
    imageUrls = context.read<LocationSelectionNotifier>().imageUrls;
    cityImageUrls = context.read<LocationSelectionNotifier>().imageUrls;
  }

  void initializeHeadlineOffsets() {
    for (int i = 0; i < serviceList.length; i++) {
      GlobalKey<ExpandableListContainerState> containerKey =
      GlobalKey<ExpandableListContainerState>();
      expandableListKeys.add(containerKey);
      String headline = serviceList[i].isNotEmpty
          ? serviceList[i].first['headLines'] as String
          : 'Default Title';

      // Adjust offset calculation
      offset = i * 700;
      // Ensure that offset is 0 for the first item
      if (i == 0) {
        offset = 200;
      }

      headlineOffsets[headline] = offset;
    }
  }

  Future<List<String>> fetchCityNames() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('cities').get();
    List<String> cityNames = [];
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> cityData =
      documentSnapshot.data() as Map<String, dynamic>;
      String cityName = cityData['name'];
      cityNames.add(cityName);
    }
    return cityNames;
  }

  Future<List<List<Map<String, dynamic>>>> fetchDataAndOrganize(
      String city) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('servicesInACity')
        .where('city', isEqualTo: city)
        .get();

    // Organize the data by headlines
    Map<String, List<Map<String, dynamic>>> organizedData = {};

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> serviceData =
      documentSnapshot.data() as Map<String, dynamic>;
      imageUrls = serviceData['imageUrls'];
      //convert image to widget
      String headlines = serviceData['headLines'];
      if (!organizedData.containsKey(headlines)) {
        organizedData[headlines] = [];
      }

      // Add the serviceId to the serviceData
      serviceData['serviceId'] = documentSnapshot.id;
      organizedData[headlines]!.add(serviceData);
    }



    // Convert the Map values to a list
    List<List<Map<String, dynamic>>> result = organizedData.values.toList();
    _isDataLoaded = true;
    return result;
  }

  void updateCitiesMenu(){
    setState(() {

      if (citiesMenu.isNotEmpty) {
        selectedCity = currentCity;
      } else {
        selectedCity = null;
      }
    });
  }




  Future<List<dynamic>> fetchImageUrls(String city) async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('cities')
        .where('name', isEqualTo: city)
        .get();
    List<dynamic> imageslist = [] ;
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> serviceData = documentSnapshot.data() as Map<String, dynamic>;

      imageslist=serviceData['imageUrls'];
      setState(() {
        imageUrls=serviceData['imageUrls'];
      });
    }

    return imageUrls;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final ffAppState = context.watch<FFAppState>();
    final authProvider = context.watch<MyAuthProvider>();
    final selectedLanguage = context.watch<SelectedLanguage>();

    return GestureDetector(
      child: Scaffold(
        key: scaffoldKey,
        body: FutureBuilder<List<List<Map<String, dynamic>>>>(
          future: fetchDataAndOrganize(selectedCity ?? ""),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _isDataLoaded==false) {
              return _buildShimmerLoadingAll(context);
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              // Data has been loaded successfully
              serviceList = snapshot.data ?? [];
              return _TreeBuild(context);
            }
          },
        ),
        drawer: CustomDrawer(
          isAuthenticated: authProvider.isAuthenticated,
        ),
      ),
    );
  }
  Widget _TreeBuild (BuildContext context){
    final routeName = ModalRoute.of(context)?.settings.name;
    final ffAppState = context.watch<FFAppState>();
    final authProvider = context.watch<MyAuthProvider>();
    final selectedLanguage = context.watch<SelectedLanguage>();
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: Color(0xFFD54D57),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () {
              scaffoldKey.currentState!.openDrawer();
            },
          ),
          flexibleSpace: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/icons/ReserveLogo.png',
                width: 400.0,
                height: 100.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0, left: 5.0),
              child: CityMenu(
                cities: citiesMenu
                    .map((city) => selectedLanguage.translate(city))
                    .toList(),
                selectedCity: selectedLanguage.translate(selectedCity!),
                onChanged: (String? city) {
                  if (city != null) {
                    setState(() {
                      selectedCity = selectedLanguage.untranslate(city!);
                    });
                    fetchDataAndOrganize(selectedCity!).then((result) {
                      setState(() {
                        serviceList = result;
                      });
                    });
                    fetchImageUrls(selectedCity!).then((result) {
                      setState(() {
                        imageUrls = result;
                      });
                    });
                  }
                },
              ),
            ),
          ],
          centerTitle: true,
          elevation: 4.0,
          pinned: false,
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            height: 230.0,
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: MyCarouselWithDots(
                    imageUrls: cityImageUrls,
                    autoPlayImg: true,
                    enableEnlargeView: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            minHeight: 125.0,
            maxHeight: 125.0,
            child: CircularImageSlider(
              serviceNames: serviceNames,
              imageAssetPaths: imageAssetPaths,
              onServiceTapped: handleServiceTapped,
            ),
          ),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              String headline = serviceList[index].isNotEmpty
                  ? serviceList[index].first['headLines'] as String
                  : 'Default Title';
              return ExpandableListContainer(
                key: expandableListKeys[index],
                title: headline,
                cardDataList: serviceList[index],
              );
            },
            childCount: serviceList.length,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10.0)),
      ],
    );
  }

  Widget _buildShimmerLoadingAll(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ShimmerLoading.AppbarShimmer(context),
          ShimmerLoading.shimmerLoadingCarousel(context),
          ShimmerLoading.CircularImageSliderShimmer(),
          ShimmerLoading.shimmerLoadingContent(context),
        ],
      ),
    );
  }

  void collapseAllExpandableContainers() {
    for (var key in expandableListKeys) {
      key.currentState?.setExpanded(false);
    }

  }

  void handleServiceTapped(String serviceTitle) {
    collapseAllExpandableContainers();
    String FixederviceTitle = serviceTitle.replaceAll(' ', '');
    // Look up the offset in the map based on the tapped headline
    double offset = headlineOffsets[FixederviceTitle] ?? 0.0;
    _scrollController.animateTo(offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut);
  }
}
class CityMenu extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String?> onChanged;

  const CityMenu({
    Key? key,
    required this.cities,
    required this.selectedCity,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);

    return Consumer<SelectedLanguage>(
      builder: (context, selectedLanguage, child) {
        return CustomDropdownMenu(
          items: cities,
          value: selectedCity,
          onChanged: onChanged,
          menuHeight: 35,
          menuWidth: 100,
          menuColor: Color(0xFFD54D57),
          buttonColor: Colors.transparent,
          textColor: Colors.white,
          defaultTextColor: Colors.grey,
          useMarquee: true,
          textFont: 18.0,
          buttonElevated: 0,
          //animatedText: true,
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}