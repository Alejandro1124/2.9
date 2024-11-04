import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CarControlApp());
}

class CarControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Carrito IoT',
      theme: ThemeData(
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
        ),
      ),
      home: CarControlScreen(),
    );
  }
}

class CarControlScreen extends StatefulWidget {
  @override
  _CarControlScreenState createState() => _CarControlScreenState();
}




/////////////////////////////////////////////////////////////
// 
class _CarControlScreenState extends State<CarControlScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? userName;
  List<Map<String, dynamic>> _databaseRecords = [];
  List<Map<String, dynamic>> _extraRecords = [];
  int? selectedStatus;
  bool isLoading = false;
  bool showExtraRecords = false;
  final String baseIp = 'http://52.91.109.250:5000';


  @override
  void initState() {
    super.initState();
    fetchDatabaseRecords();
  }
  /////////////////////////////////////////////////////////
// Post para mandar los status y la informacion 
  Future<void> sendStatus(int status) async {
    if (userName == null || userName!.isEmpty) {
      print("Debe ingresar un nombre.");
      return;
    }

    final url = Uri.parse('$baseIp/status');
    final String idDevice = "6111edf4c69e5e62f29a3f9b252bfec26f390130a813853274eaf55d2192e73d";
    final String date = DateTime.now().toUtc().toIso8601String();

    final body = json.encode({
      'name': userName,
      'status': status,
      'date': date,
      'id_device': idDevice,
    });

    print("Cuerpo de la solicitud: $body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        setState(() {
          selectedStatus = status;
        });
        print("Status $status enviado con éxito");
      } else {
        print("Error enviando status $status: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  // Metodo get para traer los registros y pasarlo a las tablas 

 Future<void> fetchDatabaseRecords() async {
  setState(() {
    isLoading = true;
  });

  final urlPrimary = Uri.parse('$baseIp/last_status');
  final urlExtra = Uri.parse('$baseIp/status');

  try {
    // Petición para los registros de la primera tabla
    final responsePrimary = await http.get(urlPrimary);
    if (responsePrimary.statusCode == 200) {
      setState(() {
        _databaseRecords = List<Map<String, dynamic>>.from(json.decode(responsePrimary.body));
      });
    } else {
      print("Error al obtener registros de la primera tabla: ${responsePrimary.statusCode}");
    }

    // Petición para los registros de la segunda tabla
    final responseExtra = await http.get(urlExtra);
    if (responseExtra.statusCode == 200) {
      setState(() {
        _extraRecords = List<Map<String, dynamic>>.from(json.decode(responseExtra.body));
      });
    } else {
      print("Error al obtener registros de la segunda tabla: ${responseExtra.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
// get para la segunda tabla donde se muestran todos los registros 
  Future<void> fetchExtraRecords() async {
    final url = Uri.parse('$baseIp/status');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _extraRecords = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print("Error al obtener registros adicionales: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Widget buildControlButtons() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlButton(icon: Icons.arrow_upward, tooltip: 'Esquinado Izquierda', status:6 , rotationAngle: -0.785398, color: const Color.fromARGB(255, 4, 77, 234)),
            buildControlButton(icon: Icons.arrow_upward, tooltip: 'Avanzar', status: 1, color: Colors.green),
            buildControlButton(icon: Icons.arrow_upward, tooltip: 'Esquinado Derecha', status: 7, rotationAngle: 0.785398, color: const Color.fromARGB(255, 4, 77, 234)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlButton(icon: Icons.arrow_back, tooltip: 'Girar Izquierda', status: 4, color: Colors.yellow),
            buildControlButton(icon: Icons.stop, tooltip: 'Detener', status: 5, isStopButton: true, color: const Color.fromARGB(255, 232, 6, 6)),
            buildControlButton(icon: Icons.arrow_forward, tooltip: 'Girar Derecha', status: 3, color: Colors.yellow),
          ],
        ),
        buildControlButton(icon: Icons.arrow_downward, tooltip: 'Retroceder', status: 2, color: Colors.green),
      ],
    ),
  );
}

 Widget buildControlButton({
  required IconData icon,
  required String tooltip,
  required int status,
  double rotationAngle = 0,
  bool isStopButton = false,
  required Color color, // Nuevo parámetro
}) {
  final bool isSelected = selectedStatus == status;
  return Transform.rotate(
    angle: rotationAngle,
    child: GestureDetector(
      onTap: () => sendStatus(status),
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 54, 58, 55) : color, // Usa el parámetro `color`
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color.fromARGB(255, 248, 244, 244),
          size: 32,
        ),
      ),
    ),
  );
}


// configuracion de la primera tabla donde se muestra el ultimo registro  mandado 
  Widget buildDataTable() {
  return Container(
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
    ),
    child: isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Colors.blue),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue.withOpacity(0.5);
                  }
                  return Colors.transparent; // Color por defecto de las filas
                },
              ),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Fecha', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('ID_Device', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('IP Cliente', style: TextStyle(color: Colors.white))),
              ],
              rows: _databaseRecords
                  .map(
                    (record) => DataRow(
                      cells: [
                        DataCell(Text(record['id'].toString(), style: TextStyle(color: Colors.black))),
                        DataCell(Text(record['name'] ?? '', style: TextStyle(color: Colors.black))),
                        DataCell(Text(record['status'].toString(), style: TextStyle(color: Colors.black))),
                        DataCell(Text(record['date'] ?? '', style: TextStyle(color: Colors.black))),
                        DataCell(Text(record['id_device'] ?? '', style: TextStyle(color: Colors.black))),
                        DataCell(Text(record['ip_client'] ?? '', style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
  );
}

// configuracion de la tabla donse se muestran todos los registros 

Widget buildExtraRecordsTable() {
  return Visibility(
    visible: showExtraRecords,
    child: Container(
      margin: EdgeInsets.only(top: 1, left: 8, right: 8), // Reducir margen superior
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 0, // Ocultar encabezado
          columnSpacing: 20,
          columns: const [
            DataColumn(label: SizedBox.shrink()),
            DataColumn(label: SizedBox.shrink()),
            DataColumn(label: SizedBox.shrink()),
            DataColumn(label: SizedBox.shrink()),
            DataColumn(label: SizedBox.shrink()),
            DataColumn(label: SizedBox.shrink()),
          ],
          rows: _extraRecords
              .map(
                (record) => DataRow(cells: [
                  DataCell(Text(record['id'].toString())),
                  DataCell(Text(record['name'] ?? '')),
                  DataCell(Text(record['status'].toString())),
                  DataCell(Text(record['date'] ?? '')),
                  DataCell(Text(record['id_device'] ?? '')),
                  DataCell(Text(record['ip_client'] ?? '')),
                ]),
              )
              .toList(),
        ),
      ),
    ),
  );
}



///////////////////////////////////////////////////////

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromRGBO(255, 255, 255, 1), Color(0xFFE1EBFF)],
        ),
      ),
      child: SingleChildScrollView( // Mantener esto
        child: Column(
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '      Ingrese su nombre para continuar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(fontSize: 16),
                  onChanged: (value) {
                    setState(() {
                      userName = value.isNotEmpty ? value : null;
                    });
                  },
                ),
              ),
            ),
            buildControlButtons(), // Remover Expanded aquí
            SizedBox(height: 20),
            Column( // Remover Expanded y usar un Column
              children: [
                buildDataTable(),
                buildExtraRecordsTable(),
              ],
            ),
          ],
        ),
      ),
    ),




    // botones y estado de los botones de recargar registros y de mostrar registros extras 
    floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: fetchDatabaseRecords,
          child: Icon(Icons.refresh),
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            setState(() {
              showExtraRecords = !showExtraRecords;
              if (showExtraRecords) {
                fetchExtraRecords();
              }
            });
          },
          child: Icon(showExtraRecords ? Icons.visibility_off : Icons.visibility),
        ),
      ],
    ),
  );
}

}

         
