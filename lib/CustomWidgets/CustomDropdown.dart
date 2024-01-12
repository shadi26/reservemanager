
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  final List<String> items;

  CustomDropdown({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      isExpanded: true,
      value: value,
      onChanged: (value) {
        onChanged(value!);
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18.0,
            ),
          ),
        );
      }).toList(),
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
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        width: 100.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
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
    );
  }
}
