import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeService {
  static final Faker _faker = Faker();

  static Future<String> generateBase64Image(String imageUrl) async {
    try {
      // Fetch image data from URL
      var response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Encode image data to base64
        var base64Image = base64Encode(response.bodyBytes);
        return base64Image;
      } else {
        // Handle error or return an empty string
        return '';
      }
    } catch (e) {
      // Handle any exception that might occur during the HTTP request
      print('Error fetching image: $e');
      return '';
    }
  }

  static Map<String, dynamic> generateWeeklySchedule() {
    final List<String> daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    final Map<String, dynamic> weeklySchedule = {};

    for (final day in daysOfWeek) {
      final List<String> times = [];

      if (day == 'Saturday') {
        // For Saturday, set the schedule as "Closed"
        times.add('Closed');
      } else {
        // For other days, generate two random opening times
        times.add(generateRandomTime());
        times.add(generateRandomTime());
      }

      weeklySchedule[day] = times;
    }

    return weeklySchedule;
  }

  static String generateRandomTime() {
    final int hour = _faker.randomGenerator.integer(23);
    final int minute = _faker.randomGenerator.integer(59);
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  static String generateRandomTitle() {
    // Generate a random title using lorem property
    return _faker.lorem.words(_faker.randomGenerator.integer(3, min: 1)).join(' ');
  }

  static Future<void> addDocumentToFirestore() async {
    try {
      // Generate circular image URL related to football using the avatar method
      final circularImageUrl = _faker.image.image();
      final circularImageBase64 = await generateBase64Image(circularImageUrl);

      // Generate regular image URL related to football
      final imageImageUrl = _faker.image.image();
      final imageBase64 = await generateBase64Image(imageImageUrl);

      // Generate an array of image URLs related to football
      final imageUrlsBase64 = await Future.wait(
        List.generate(
          2,
              (index) async {
            final imageUrl = _faker.image.image();
            return await generateBase64Image(imageImageUrl);
          },
        ),
      );

      // Generate a document with base64-encoded images related to football
      final document = {
        'circularimage': circularImageBase64,
        'city': 'shefaamr',
        'headLines': "FootballStadiums",
        'image': imageBase64,
        'imageUrls': imageUrlsBase64,
        'status': 'Open',
        'title': generateRandomTitle(),
        'weeklyStadiumOpeningSchedule': generateWeeklySchedule(),
      };

      // Add the document to Firestore
      final collectionReference = FirebaseFirestore.instance.collection('servicesInACity');
      await collectionReference.add(document);
    } catch (e) {
      // Handle any exception that might occur during the process
      print('Error adding document to Firestore: $e');
    }
  }
}
