import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/excel_handler.dart';
import 'table_editor_screen.dart';

class FilePickerScreen extends StatefulWidget {
  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  String? filePath;
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        filePath = result.files.single.path;
      });

      // Leer y pasar datos
      var data = await ExcelHandler.readExcel(filePath!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TableEditorScreen(data: data)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/images/wpp.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: pickFile,
                  child: const Text("Seleccionar Archivo Excel"),
                ),
                const SizedBox(height: 20),
                if (filePath != null)
                  Text(
                    "Archivo seleccionado: ${filePath!.split('/').last}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
