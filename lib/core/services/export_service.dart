import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class ExportService {
  /// Procesa las listas de transacciones y abre el menú nativo para compartir el archivo CSV
  static Future<bool> exportTransactionsToCSV({
    required List<dynamic> expenses,
    required List<dynamic> incomes,
  }) async {
    // 1. Definir los encabezados de las columnas del reporte
    final List<List<dynamic>> rows = [
      ['Tipo', 'Fecha', 'Nombre/Concepto', 'Categoría', 'Monto (\$)']
    ];

    // 2. Mapear e inyectar los Ingresos
    for (final inc in incomes) {
      rows.add([
        'INGRESO',
        '${inc.date.day}/${inc.date.month}/${inc.date.year}',
        inc.name,
        inc.category.displayName,
        inc.amount,
      ]);
    }

    // 3. Mapear e inyectar los Gastos
    for (final exp in expenses) {
      rows.add([
        'GASTO',
        '${exp.date.day}/${exp.date.month}/${exp.date.year}',
        exp.name,
        exp.category.displayName,
        exp.amount,
      ]);
    }

    final String csvContent = csv.encode(rows);

    // final List<int> bytes = csvContent.codeUnits;
    final Uint8List fileBytes = Uint8List.fromList(csvContent.codeUnits);
    final String fileName = 'reporte_financiero_${DateTime.now().millisecondsSinceEpoch}.csv';

    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Selecciona dónde guardar tu reporte:',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: fileBytes
    );

    return outputFile != null;
  }
}