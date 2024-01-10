import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ServicesInACityWidget extends StatefulWidget {
  @override
  _ServicesInACityWidgetState createState() => _ServicesInACityWidgetState();
}

class _ServicesInACityWidgetState extends State<ServicesInACityWidget> {
  TextEditingController cityController = TextEditingController();
  TextEditingController headLinesController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController friday0Controller = TextEditingController();
  TextEditingController friday1Controller = TextEditingController();
  TextEditingController monday0Controller = TextEditingController();
  TextEditingController monday1Controller = TextEditingController();
  TextEditingController saturday0Controller = TextEditingController();
  TextEditingController sunday0Controller = TextEditingController();
  TextEditingController sunday1Controller = TextEditingController();
  TextEditingController thursday0Controller = TextEditingController();
  TextEditingController thursday1Controller = TextEditingController();
  TextEditingController tuesday0Controller = TextEditingController();
  TextEditingController tuesday1Controller = TextEditingController();
  TextEditingController wednesday0Controller = TextEditingController();
  TextEditingController wednesday1Controller = TextEditingController();

  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  Future getImage(ImageSource source, int imageIndex) async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        switch (imageIndex) {
          case 1:
            _image1 = File(pickedFile.path);
            break;
          case 2:
            _image2 = File(pickedFile.path);
            break;
          case 3:
            _image3 = File(pickedFile.path);
            break;
          case 4:
            _image4 = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Widget buildImageButton(String buttonText, int imageIndex) {
    return Column(
      children: [
        Text(buttonText),
        _getImageButton(imageIndex),
      ],
    );
  }

  Widget _getImageButton(int imageIndex) {
    switch (imageIndex) {
      case 1:
        return _buildImageWidget(_image1, imageIndex);
      case 2:
        return _buildImageWidget(_image2, imageIndex);
      case 3:
        return _buildImageWidget(_image3, imageIndex);
      case 4:
        return _buildImageWidget(_image4, imageIndex);
      default:
        return Container(); // Return an empty container if image is null
    }
  }

  Widget _buildImageWidget(File? imageFile, int imageIndex) {
    return imageFile == null ?
    ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Image Source'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImage(ImageSource.camera, imageIndex);
                  },
                  child: Text('Camera'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImage(ImageSource.gallery, imageIndex);
                  },
                  child: Text('Gallery'),
                ),
              ],
            );
          },
        );
      },
      child: Text('Select Image $imageIndex'),
    )
        : Image.file(imageFile);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Admin Page'),
              background: Image.network(
                'https://images.pexels.com/photos/5579045/pexels-photo-5579045.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                fit: BoxFit.cover,
              ),
            ),
            backgroundColor: Color(0xFFD54D57),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Service Images',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                buildImageButton('Service Image', 1),
                                buildImageButton('Circular Image', 2),
                                buildImageButton('Carousel Image 1', 3),
                                buildImageButton('Carousel Image 2', 4),
                              ],
                            ),
                            SizedBox(height: 40.0),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Service Info',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              controller: cityController,
                              decoration: InputDecoration(labelText: 'City'),
                            ),
                            TextFormField(
                              controller: headLinesController,
                              decoration:
                              InputDecoration(labelText: 'Headlines'),
                            ),
                            TextFormField(
                              controller: statusController,
                              decoration: InputDecoration(labelText: 'Status'),
                            ),
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(labelText: 'Title'),
                            ),
                            SizedBox(height: 40.0),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Weekly Stadium Opening Schedule',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buildDaySchedule(
                                'Friday', friday0Controller, friday1Controller),
                            buildDaySchedule(
                                'Monday', monday0Controller, monday1Controller),
                            buildDaySchedule('Saturday', saturday0Controller),
                            buildDaySchedule(
                                'Sunday', sunday0Controller, sunday1Controller),
                            buildDaySchedule(
                                'Thursday', thursday0Controller, thursday1Controller),
                            buildDaySchedule(
                                'Tuesday', tuesday0Controller, tuesday1Controller),
                            buildDaySchedule('Wednesday', wednesday0Controller, wednesday1Controller),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                addToCollection(context);
                              },
                              child: Text('Add New Service'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildDaySchedule(String day, TextEditingController controller1,
      [TextEditingController? controller2]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(day),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: TextFormField(
                  controller: controller1,
                  decoration: InputDecoration(labelText: 'Opening Time'),
                ),
              ),
            ),
            if (controller2 != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    controller: controller2,
                    decoration: InputDecoration(labelText: 'Closing Time'),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.0),
      ],
    );
  }


  void addToCollection(BuildContext context) async {
    // Check if any required field is null
    if (_image1 == null ||
        _image2 == null ||
        _image3 == null ||
        _image4 == null ||
        cityController.text.isEmpty ||
        headLinesController.text.isEmpty ||
        statusController.text.isEmpty ||
        titleController.text.isEmpty) {
      // Display an error message or handle the case where some fields are empty
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error: Please fill in all required fields and select an image.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get values from controllers
    String city = cityController.text;
    String headLines = headLinesController.text;
    String status = statusController.text;
    String title = titleController.text;
    Map<String, List<String>> weeklyStadiumOpeningSchedule = {
      'Friday': [friday0Controller.text, friday1Controller.text],
      'Monday': [monday0Controller.text, monday1Controller.text],
      'Saturday': [saturday0Controller.text],
      'Sunday': [sunday0Controller.text, sunday1Controller.text],
      'Thursday': [thursday0Controller.text, thursday1Controller.text],
      'Tuesday': [tuesday0Controller.text, tuesday1Controller.text],
      'Wednesday': [wednesday0Controller.text, wednesday1Controller.text],
    };

    // Convert main images to base64
    List<int> imageBytes1 = await _image1!.readAsBytes();
    String base64Image1 = base64Encode(imageBytes1);

    List<int> imageBytes2 = await _image2!.readAsBytes();
    String base64Image2 = base64Encode(imageBytes2);

    List<int> imageBytes3 = await _image3!.readAsBytes();
    String base64Image3 = base64Encode(imageBytes3);

    List<int> imageBytes4 = await _image4!.readAsBytes();
    String base64Image4 = base64Encode(imageBytes4);

    try {
      // Here, you would typically use a Firestore instance and the add() method to add data to your collection.
      await FirebaseFirestore.instance.collection('ServicesInACity').add({
        'city': city,
        'headlines': headLines,
        'status': status,
        'title': title,
        'schedule': weeklyStadiumOpeningSchedule,
        'circularimage1': base64Image1,
        'circularimage2': base64Image2,
        'circularimage3': base64Image3,
        'circularimage4': base64Image4,
      });

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to database successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Optionally, you can clear the form or navigate to a different screen after success.
      // Clear the form
      cityController.clear();
      // ... Clear other controllers
      // Optionally, navigate to a different screen
      // Navigator.pushReplacementNamed(context, '/success_screen');
    } catch (e) {
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
