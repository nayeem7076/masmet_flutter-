// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

Future<void> triggerPdfDownload(List<int> bytes, String fileName) async {
  final base64Data = base64Encode(bytes);
  final dataUrl = 'data:application/pdf;base64,$base64Data';

  final anchor = html.AnchorElement(href: dataUrl)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
