import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportMemberRow {
  final String name;
  final double paid;
  final double balance;

  const ReportMemberRow({
    required this.name,
    required this.paid,
    required this.balance,
  });
}

class PdfService {
  static Future<File> exportMonthlyReport({
    required double totalCost,
    required double totalPaid,
    required int totalMembers,
    required List<ReportMemberRow> members,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'MessMate Monthly Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Total Cost: Tk ${totalCost.toStringAsFixed(0)}'),
                pw.Text('Total Paid: Tk ${totalPaid.toStringAsFixed(0)}'),
                pw.Text('Total Members: $totalMembers'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: const ['Name', 'Paid (Tk)', 'Balance'],
            data: members
                .map(
                  (m) => [
                    m.name,
                    m.paid.toStringAsFixed(0),
                    m.balance >= 0
                        ? 'Advance ${m.balance.toStringAsFixed(0)}'
                        : 'Due ${m.balance.abs().toStringAsFixed(0)}',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/messmate_monthly_report_${now.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Future<void> openFile(File file) async {
    await OpenFilex.open(file.path);
  }
}
