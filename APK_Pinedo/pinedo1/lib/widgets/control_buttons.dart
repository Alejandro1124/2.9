import 'package:flutter/material.dart';

Widget buildControlButtons(Function(int) sendStatus, int? selectedStatus) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlButton(Icons.arrow_upward, 'Esquinado Izquierda', 7, -0.785398, sendStatus, selectedStatus, Color.fromARGB(255, 4, 77, 234)),
            buildControlButton(Icons.arrow_upward, 'Avanzar', 1, 0, sendStatus, selectedStatus, Colors.green),
            buildControlButton(Icons.arrow_upward, 'Esquinado Derecha', 6, 0.785398, sendStatus, selectedStatus, Color.fromARGB(255, 4, 77, 234)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlButton(Icons.arrow_back, 'Girar Izquierda', 3, 0, sendStatus, selectedStatus, Colors.yellow),
            buildControlButton(Icons.stop, 'Detener', 5, 0, sendStatus, selectedStatus, Color.fromARGB(255, 232, 6, 6), isStopButton: true),
            buildControlButton(Icons.arrow_forward, 'Girar Derecha', 4, 0, sendStatus, selectedStatus, Colors.yellow),
          ],
        ),
        buildControlButton(Icons.arrow_downward, 'Retroceder', 2, 0, sendStatus, selectedStatus, Colors.green),
      ],
    ),
  );
}

Widget buildControlButton(IconData icon, String tooltip, int status, double rotationAngle, Function(int) sendStatus, int? selectedStatus, Color color, {bool isStopButton = false}) {
  final bool isSelected = selectedStatus == status;
  return Transform.rotate(
    angle: rotationAngle,
    child: GestureDetector(
      onTap: () => sendStatus(status),
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 54, 58, 55) : color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Color.fromARGB(255, 248, 244, 244), size: 32),
      ),
    ),
  );
}
