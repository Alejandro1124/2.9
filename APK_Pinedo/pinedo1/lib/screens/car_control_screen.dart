import 'package:flutter/material.dart';
import '../widgets/control_buttons.dart';
import '../widgets/data_tables.dart';
import '../services/api_service.dart';

class CarControlScreen extends StatefulWidget {
  @override
  _CarControlScreenState createState() => _CarControlScreenState();
}

class _CarControlScreenState extends State<CarControlScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? userName;
  List<Map<String, dynamic>> _databaseRecords = [];
  List<Map<String, dynamic>> _extraRecords = [];
  int? selectedStatus;
  bool isLoading = false;
  bool showExtraRecords = false;

  @override
  void initState() {
    super.initState();
    fetchDatabaseRecords();
  }

  Future<void> fetchDatabaseRecords() async {
    setState(() => isLoading = true);
    _databaseRecords = await ApiService.fetchDatabaseRecords();
    _extraRecords = await ApiService.fetchExtraRecords();
    setState(() => isLoading = false);
  }

  Future<void> sendStatus(int status) async {
    if (userName == null || userName!.isEmpty) {
      print("Debe ingresar un nombre.");
      return;
    }
    await ApiService.sendStatus(status, userName!);
    setState(() => selectedStatus = status);
  }

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                    setState(() => userName = value.isNotEmpty ? value : null);
                  },
                ),
              ),
              buildControlButtons(sendStatus, selectedStatus),
              SizedBox(height: 20),
              Column(
                children: [
                  buildDataTable(_databaseRecords, isLoading),
                  buildExtraRecordsTable(_extraRecords, showExtraRecords),
                ],
              ),
            ],
          ),
        ),
      ),
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
              setState(() => showExtraRecords = !showExtraRecords);
            },
            child: Icon(showExtraRecords ? Icons.visibility_off : Icons.visibility),
          ),
        ],
      ),
    );
  }
}
