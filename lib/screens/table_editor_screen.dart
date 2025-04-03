import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/excel_handler.dart';
import 'package:share_plus/share_plus.dart';

class TableEditorScreen extends StatefulWidget {
  final List<List<dynamic>> data;
  TableEditorScreen({required this.data});

  @override
  _TableEditorScreenState createState() => _TableEditorScreenState();
}

class _TableEditorScreenState extends State<TableEditorScreen> {
  late List<List<dynamic>> editedData;
  @override
  void initState() {
    super.initState();
    //Copia de datos para tabla
    editedData = List.generate(widget.data.length, (i) => List.from(widget.data[i]));
  }

  // Solo editables las últimas 2 columnas
  bool isEditable(int colIndex) {
    int totalColumns = widget.data[0].length;
    return colIndex == totalColumns - 2 || colIndex == totalColumns - 1;
  }

  // Construcción de celdas
  Widget buildCell(int rowIndex, int colIndex) {
    var cellValue = editedData[rowIndex][colIndex]?.toString() ?? "";
    if (isEditable(colIndex)) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cellValue.isEmpty ? Colors.yellow[100] : Colors.transparent,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextFormField(
          initialValue: cellValue,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            setState(() {
              editedData[rowIndex][colIndex] = value;
            });
          },
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(cellValue),
      );
    }
  }

  // Función guardar Excel añadiendo columna total
  Future<void> saveExcel() async {
    try {
      List<List<dynamic>> exportData = List.generate(
        editedData.length,
        (i) => List.from(editedData[i]),
      );
      // Agregado de total
      int totalColumns = exportData[0].length;
      exportData[0].add("total");
      // Sumatoria de stocks
      for (int i = 1; i < exportData.length; i++) {
        double value1 = double.tryParse(exportData[i][totalColumns - 2].toString()) ?? 0;
        double value2 = double.tryParse(exportData[i][totalColumns - 1].toString()) ?? 0;
        double sum = value1 + value2;
        exportData[i].add(sum);
      }

      final directory = await getExternalStorageDirectory();
      String filePath = '${directory!.path}/ajuste_stock.xlsx';

      await ExcelHandler.saveExcel(filePath, exportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Archivo guardado en: $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    }
  }
  // Compartir excel
  Future<void> shareExcel() async {
    try {
      final directory = await getExternalStorageDirectory();
      String filePath = '${directory!.path}/ajuste_stock.xlsx';
      if (await File(filePath).exists()) {
        Share.shareXFiles([XFile(filePath)], text: "Ajuste de stock generado");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("El archivo no existe")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al compartir: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalColumns = widget.data[0].length;
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Ajustes de Stock")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              // Fila cabecera
              TableRow(
                decoration: BoxDecoration(color: Colors.blue[100]),
                children: List.generate(totalColumns, (colIndex) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      widget.data[0][colIndex].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
              // Filas de datos
              ...List.generate(editedData.length - 1, (rowIndex) {
                int realRowIndex = rowIndex + 1; 
                return TableRow(
                  children: List.generate(totalColumns, (colIndex) {
                    return buildCell(realRowIndex, colIndex);
                  }),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "save",
            onPressed: saveExcel,
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "share",
            onPressed: shareExcel,
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}
