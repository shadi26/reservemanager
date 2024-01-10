import 'package:flutter/material.dart';

class CreditCardEntryDialog {
  static void showCreditCardEntryDialog(BuildContext context) {
    final TextEditingController _cardNumberController = TextEditingController();
    final TextEditingController _cvvController = TextEditingController();
    final TextEditingController _idNumberController = TextEditingController();

    // Dropdown options for months and years
    final List<String> months = List.generate(12, (index) => (index + 1).toString());
    final List<String> years = List.generate(10, (index) => (DateTime.now().year + index).toString());

    // Selected values for the dropdowns
    String selectedMonth = months[0];
    String selectedYear = years[0];

    void submitCreditCardInfo() {
      // TODO: Add logic to handle credit card information submission
      // You can access the entered information using the controllers
      // Implement your logic here

      // Close the dialog after processing
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              width: 350.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFD54D57),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Image.asset(
                              'assets/icons/Xbtn.png',
                              width: 14, // Set the desired width
                              height: 14, // Set the desired height
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Text(
                          'Enter Credit Card Info',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Number',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Amiri',
                            fontSize: 14.0,
                          ),
                        ),
                        TextField(
                          controller: _idNumberController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Enter your ID Number',
                          ),
                          keyboardType: TextInputType.text,
                          onSubmitted: (_) => submitCreditCardInfo(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Number',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Amiri',
                            fontSize: 14.0,
                          ),
                        ),
                        TextField(
                          controller: _cardNumberController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Enter your Card Number',
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => submitCreditCardInfo(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiry Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Amiri',
                            fontSize: 14.0,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedMonth,
                                items: months.map((String month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    selectedMonth = value;
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedYear,
                                items: years.map((String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    selectedYear = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Amiri',
                            fontSize: 14.0,
                          ),
                        ),
                        TextField(
                          controller: _cvvController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Enter CVV',
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => submitCreditCardInfo(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          contentPadding: EdgeInsets.zero,
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Amiri',
                      fontSize: 20.0,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFD54D57),
                ),
                onPressed: submitCreditCardInfo,
              ),
            ),
          ],
        );
      },
    );
  }
}
