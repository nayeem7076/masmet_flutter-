import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_download_stub.dart' if (dart.library.html) 'pdf_download_web.dart';

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
    required double gasBill,
    required double currentBill,
    required List<ReportMemberRow> members,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final utilityTotal = gasBill + currentBill;
    final perMemberShare = totalMembers == 0 ? 0 : totalCost / totalMembers;
    final perMemberUtility = totalMembers == 0 ? 0 : utilityTotal / totalMembers;
    final fileName =
        'messmate_monthly_report_${now.millisecondsSinceEpoch}.pdf';
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0D47A1),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MessMate Monthly Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard('Total Cost', 'Tk ${totalCost.toStringAsFixed(0)}'),
              _metricCard('Total Joma', 'Tk ${totalPaid.toStringAsFixed(0)}'),
              _metricCard('Members', '$totalMembers'),
              _metricCard('Per Member', 'Tk ${perMemberShare.toStringAsFixed(0)}'),
              _metricCard('Total Pabe', 'Tk ${totalReceivable.toStringAsFixed(0)}'),
              _metricCard('Total Dibe', 'Tk ${totalPayable.toStringAsFixed(0)}'),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE8F1FF),
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColor.fromInt(0xFFB7D2FF)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Utility Split',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                    color: PdfColor.fromInt(0xFF0D47A1),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Gas Bill: Tk ${gasBill.toStringAsFixed(0)}'),
                pw.Text('Current Bill: Tk ${currentBill.toStringAsFixed(0)}'),
                pw.Text('Utility Total: Tk ${utilityTotal.toStringAsFixed(0)}'),
                pw.Text(
                  'Per Member Utility: Tk ${perMemberUtility.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Member Settlement',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1565C0),
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF6F9FF),
            ),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
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

    final file = await _savePdfForMobile(bytes, fileName);
    // Launch file open in background so UI loader can close immediately.
    unawaited(OpenFilex.open(file.path));
    return file.path;
  }

  static Future<File> _savePdfForMobile(List<int> bytes, String fileName) async {
    // Always keep a private copy as fallback.
    final appDir = await getApplicationDocumentsDirectory();
    final privateFile = File('${appDir.path}/$fileName');
    await privateFile.writeAsBytes(bytes, flush: true);

    // Try saving to public Download so user can access it after app closes.
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return privateFile;
      final rootPath = externalDir.path.split('/Android').first;
      final downloadDir = Directory('$rootPath/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      final publicFile = File('${downloadDir.path}/$fileName');
      await publicFile.writeAsBytes(bytes, flush: true);
      return publicFile;
    } catch (_) {
      // If public save fails on some Android versions, keep private file.
      return privateFile;
    }
  }

  static pw.Widget _metricCard(String label, String value) {
    return pw.Container(
      width: 124,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F8FF),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD6E4FF)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }
}
