import 'dart:io';
import 'package:excel/excel.dart';

class ExcelHandler {
  static Future<List<List<dynamic>>> readExcel(String path) async {
    var file = File(path);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    List<List<dynamic>> data = [];
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        data.add(row.map((cell) => cell?.value ?? "").toList());
      }
    }
    return data;
  }

  static Future<void> saveExcel(String path, List<List<dynamic>> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].length; j++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i)).value = TextCellValue(data[i][j].toString());
      }
    }

    List<int>? fileBytes = excel.encode();
    if (fileBytes != null) {
      File(path).writeAsBytesSync(fileBytes);
    }
  }
}
