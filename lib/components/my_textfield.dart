import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const SearchField(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: Theme.of(context).colorScheme.primary,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontFamily: "Poppins",
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          contentPadding: EdgeInsets.all(screenWidth * 0.02),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


class MyTextField extends StatelessWidget {
  final String hintText;
  final bool isPhone;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.isPhone
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontFamily: "Poppins"),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: "Poppins"),
        ), // Use the specified or default validator
      ),
    );
  }
}