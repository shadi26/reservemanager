import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';  // Import this for rootBundle
import 'package:flutter/services.dart' show rootBundle, ByteData, rootBundle;
import 'dart:typed_data';
import 'dart:io';  // Add this import for File
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'; // Import this for the 'join' function.



//************************************************************************************************************************************************************************



Future<List<Map<String, dynamic>>> fetchDataFromFirebase(String collectionName) async {
  // Create a reference to the Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the specified collection
  CollectionReference collection = firestore.collection(collectionName);

  try {
    // Fetch the documents from the collection
    QuerySnapshot querySnapshot = await collection.get();

    // Convert each document into a Map and return as a list
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    // If there's an error, print it and return an empty list
    print('Error fetching data: $e');
    return [];
  }
}



Future<List<Map<String, dynamic>>> fetchDataFromFirebaseWithCondition(
    String collectionName, String fieldName, dynamic fieldValue) async {
  // Create a reference to the Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the specified collection
  CollectionReference collection = firestore.collection(collectionName);

  try {
    // Fetch the documents from the collection where the field matches the given value
    QuerySnapshot querySnapshot = await collection.where(fieldName, isEqualTo: fieldValue).get();

    // Convert each document into a Map and return as a list
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    // If there's an error, print it and return an empty list
    print('Error fetching data with condition: $e');
    return [];
  }
}

Future<void> addCitiesToDatabase(List<Map<String, dynamic>> cities) async {
  final collectionRef = FirebaseFirestore.instance.collection('cities');

  for (var city in cities) {
    await collectionRef.add(city).catchError((e) {
      print(e); // handle errors
    });
  }
}

Future<void> addDataToServicesInACity(List<Map<String, dynamic>> dataList) async {
  final collectionRef = FirebaseFirestore.instance.collection('cities');

  for (var data in dataList) {
    await collectionRef.add(data).catchError((e) {
      print(e); // handle errors
    });
  }
}

//* ************************************************************************************************************************************************************

Future<void> addMapToSpecificDocument(Map<String, dynamic> mapData , String StadTitle) async {
  final collectionRef = FirebaseFirestore.instance.collection('servicesInACity');

  try {
    // Query to find the document with the title "مسبح1"
    final querySnapshot = await collectionRef.where('title', isEqualTo: StadTitle).get();

    if (querySnapshot.docs.isEmpty) {
      print('No document found with title مسبح1');
      return;
    }

    // Assuming there's only one such document, get its ID
    final docId = querySnapshot.docs.first.id;

    // Set the map data with merge: true
    await collectionRef.doc(docId).set({
      'weeklyStadiumOpeningSchedule': mapData
    }, SetOptions(merge: true));

    print('Document successfully updated with map data');
  } catch (e) {
    print('Error updating document: $e');
  }
}

Future<void> addImageUrlsToSpecificDocument(List<String> imageUrls, String StadTitle) async {
  final collectionRef = FirebaseFirestore.instance.collection('servicesInACity');

  try {
    // Query to find the document with the specified title
    final querySnapshot = await collectionRef.where('title', isEqualTo: StadTitle).get();

    if (querySnapshot.docs.isEmpty) {
      print('No document found with title $StadTitle');
      return;
    }

    // Assuming there's only one such document, get its ID
    final docId = querySnapshot.docs.first.id;

    // Set the image URLs with merge: true to update the field without overwriting the entire document
    await collectionRef.doc(docId).set({
      'imageUrls': imageUrls
    }, SetOptions(merge: true));

    print('Document successfully updated with image URLs');
  } catch (e) {
    print('Error updating document: $e');
  }
}
//for creating translation files in DB
Future<Map<String, dynamic>> readLocalizationFromArb() async {
  try {
    final arbString = await rootBundle.loadString('lib/l10n/app_en.arb');
    print('this arb is ${arbString}');
    return json.decode(arbString);
  } catch (e) {
    //print('Error reading ARB file: $e');
    return {};
  }
}

Future<void> storeLocalizationInFirebase() async {
  try {
    // Read localization data from ARB file
    Map<String, dynamic> localizationData = await readLocalizationFromArb();

    // Store localization data in Firestore collection
    CollectionReference localizationCollection =
    FirebaseFirestore.instance.collection('localization');

    await localizationCollection.doc('herbew').set(localizationData);

    print('Localization data stored in Firestore successfully.');
  } catch (e) {
    print('Error storing localization data in Firestore: $e');
  }

}

//-----------------------------important-------------------------------------------------
//fetching from languages from database
Future<Map<String, dynamic>> fetchDataFromFirebaseForlanguage(String language) async {
  try {
    CollectionReference localizationCollection = FirebaseFirestore.instance.collection('localization');
    DocumentSnapshot documentSnapshot = await localizationCollection.doc(language).get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Extract data from the document
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      return data;
    } else {
      print('Document does not exist for language: $language');
      return {};
    }
  } catch (e) {
    print('Error fetching data from Firebase: $e');
    return {};
  }
}



