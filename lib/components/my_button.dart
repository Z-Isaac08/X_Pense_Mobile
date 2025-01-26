import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8)
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: screenWidth * 0.035,
                color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}