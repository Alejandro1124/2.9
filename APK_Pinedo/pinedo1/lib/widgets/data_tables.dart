import 'package:flutter/material.dart';

Widget buildDataTable(List<Map<String, dynamic>> records, bool isLoading) {
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
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Fecha', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('ID_Device', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('IP Cliente', style: TextStyle(color: Colors.white))),
              ],
              rows: records.map((record) {
                return DataRow(
                  cells: [
                    DataCell(Text(record['id'].toString(), style: TextStyle(color: Colors.black))),
                    DataCell(Text(record['name'] ?? '', style: TextStyle(color: Colors.black))),
                    DataCell(Text(record['status'].toString(), style: TextStyle(color: Colors.black))),
                    DataCell(Text(record['date'] ?? '', style: TextStyle(color: Colors.black))),
                    DataCell(Text(record['id_device'] ?? '', style: TextStyle(color: Colors.black))),
                    DataCell(Text(record['ip_client'] ?? '', style: TextStyle(color: Colors.black))),
                  ],
                );
              }).toList(),
            ),
          ),
  );
}

Widget buildExtraRecordsTable(List<Map<String, dynamic>> extraRecords, bool showExtraRecords) {
  if (!showExtraRecords) return SizedBox.shrink();
  return Container(
    margin: EdgeInsets.only(left: 16, right: 16, bottom: 5),
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Fecha')),
        ],
        rows: extraRecords.map((record) {
          return DataRow(
            cells: [
              DataCell(Text(record['id'].toString())),
              DataCell(Text(record['status'].toString())),
              DataCell(Text(record['date'] ?? '')),
            ],
          );
        }).toList(),
      ),
    ),
  );
}
