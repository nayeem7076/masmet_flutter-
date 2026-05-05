import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_download_stub.dart'
    if (dart.library.html) 'pdf_download_web.dart';

class ReportMemberRow {
  final String name;
  final double paid;
  final double share;
  final double balance;

  const ReportMemberRow({
    required this.name,
    required this.paid,
    required this.share,
    required this.balance,
  });
}

class PdfService {
  static Future<String> exportMonthlyReport({
    required double totalCost,
    required double totalPaid,
    required int totalMembers,
    required double totalReceivable,
    required double totalPayable,
    required List<ReportMemberRow> members,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final fileName =
        'messmate_monthly_report_${now.millisecondsSinceEpoch}.pdf';
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
                pw.Text('Total Joma: Tk ${totalPaid.toStringAsFixed(0)}'),
                pw.Text('Total Members: $totalMembers'),
                pw.Text(
                  'Per Member Dibe: Tk ${(totalMembers == 0 ? 0 : totalCost / totalMembers).toStringAsFixed(0)}',
                ),
                pw.Text(
                  'Total Pabe: Tk ${totalReceivable.toStringAsFixed(0)}',
                ),
                pw.Text(
                  'Total Dibe: Tk ${totalPayable.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: const ['Name', 'Paid (Tk)', 'Share (Tk)', 'Settlement'],
            data: members
                .map(
                  (m) => [
                    m.name,
                    m.paid.toStringAsFixed(0),
                    m.share.toStringAsFixed(0),
                    m.balance >= 0
                        ? 'Will Receive ${m.balance.toStringAsFixed(0)}'
                        : 'Will Pay ${m.balance.abs().toStringAsFixed(0)}',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await doc.save();

    if (kIsWeb) {
      await triggerPdfDownload(bytes, fileName);
      return fileName;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/$fileName',
    );
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
    return file.path;
  }
}
