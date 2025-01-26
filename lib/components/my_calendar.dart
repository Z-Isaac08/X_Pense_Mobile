import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final void Function(DateTime, DateTime)? onDaySelected;
  final DateTime today;
  const Calendar({super.key, required this.onDaySelected, required this.today});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.019),
      margin: EdgeInsets.all(screenHeight * 0.025),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: TableCalendar(
        focusedDay: widget.today,
        rowHeight: screenHeight * 0.05,
        availableGestures: AvailableGestures.all,
        calendarStyle: const CalendarStyle(),
        headerStyle:
        const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        firstDay: DateTime.utc(2000, 01, 01),
        selectedDayPredicate: (day) => isSameDay(day, widget.today),
        lastDay: DateTime.utc(2040, 12, 31),
        onDaySelected: widget.onDaySelected,
      ),
    );
  }
}