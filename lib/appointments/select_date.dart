// Folder: lib/appointments
// File: select_date.dart
// FINAL FIX – Chuẩn app bệnh viện, không lỗi tháng, không lỗi lịch

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectDatePage extends StatefulWidget {
  const SelectDatePage({super.key});

  @override
  State<SelectDatePage> createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late DateTime currentMonth;
  DateTime? selectedDate;

  late DateTime maxDate;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(today.year, today.month);
    maxDate = DateTime(today.year, today.month + 3, 1);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat("MMMM yyyy", "vi").format(currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        title: const Text("Chọn ngày khám"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.3,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _monthButton(Icons.chevron_left, false),
              Text(
                monthLabel,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003399)),
              ),
              _monthButton(Icons.chevron_right, true),
            ],
          ),

          const SizedBox(height: 12),

          // WEEKDAY LABELS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]
                .map((d) => Text(
                      d,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
                .toList(),
          ),

          const SizedBox(height: 10),

          Expanded(child: _buildCalendarGrid()),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ======================== GRID ========================
  Widget _buildCalendarGrid() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);

    // Convert Monday=1...Sunday=7 -> CN=0
    int startWeekday = firstDay.weekday % 7;
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    List<Widget> cells = [];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(_dayBox(d));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: cells,
    );
  }

  // ======================== DAY TILE ========================
  Widget _dayBox(int day) {
    final date = DateTime(currentMonth.year, currentMonth.month, day);

    bool isPast = date.isBefore(today);
    bool isAfterMax = date.isAfter(maxDate);
    bool isToday = date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;

    bool isSelected = selectedDate != null &&
        selectedDate!.day == date.day &&
        selectedDate!.month == date.month &&
        selectedDate!.year == date.year;

    Color bg;
    Color textColor;

    if (isPast || isAfterMax) {
      bg = Colors.grey.shade300;
      textColor = Colors.black45;
    } else {
      bg = Colors.blue;
      textColor = Colors.white;
    }

    if (isToday && !isPast) {
      bg = Colors.blue.shade700;
    }

    if (isSelected) {
      bg = Colors.green;
    }

    return GestureDetector(
      onTap: (isPast || isAfterMax)
          ? null
          : () {
              setState(() {
                selectedDate = date;
              });

              // trả về ngày cho SelectSlotPage
              Navigator.pop(context, date);
            },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$day", style: TextStyle(fontSize: 16, color: textColor)),
            if (isToday)
              const Text(
                "Hôm nay",
                style: TextStyle(fontSize: 10, color: Colors.white),
              )
          ],
        ),
      ),
    );
  }

  // ======================== MONTH BUTTONS ========================
  Widget _monthButton(IconData icon, bool forward) {
    return InkWell(
      onTap: () {
        final nextMonth = DateTime(
            currentMonth.year, currentMonth.month + (forward ? 1 : -1));

        if (nextMonth.isBefore(DateTime(today.year, today.month, 1))) return;
        if (nextMonth.isAfter(maxDate)) return;

        setState(() {
          currentMonth = nextMonth;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: forward ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: forward ? Colors.white : Colors.black54),
      ),
    );
  }
}
