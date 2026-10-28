import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:gymtrainee/Model/extramodels.dart';
import 'package:gymtrainee/widgets/date_calc.dart';
import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';

/// Builds a fee receipt (or invoice, while unpaid) as a PDF from the data the
/// fees API already returns, so no extra backend call is needed.
class FeeReceipt {
  FeeReceipt._();

  static const _purple = PdfColor.fromInt(0xFF6B21A8);
  static const _dark = PdfColor.fromInt(0xFF12081E);
  static const _muted = PdfColor.fromInt(0xFF6B7280);
  static const _line = PdfColor.fromInt(0xFFE5E7EB);
  static const _green = PdfColor.fromInt(0xFF16A34A);
  static const _amber = PdfColor.fromInt(0xFFD97706);
  static const _red = PdfColor.fromInt(0xFFDC2626);

  /// Built-in PDF fonts have no ₹ glyph, so amounts use "Rs.".
  static String _money(num v) =>
      'Rs. ${NumberFormat('#,##,##0.##', 'en_IN').format(v)}';

  static String _date(String? raw) {
    final d = DateCalc.parse(raw);
    return d == null ? '-' : DateFormat('dd MMM yyyy').format(d);
  }

  static String _number(FeeItem f) =>
      f.invoiceNumber ?? 'FD-${(f.id ?? 0).toString().padLeft(5, '0')}';

  /// Generates the PDF and opens it in the phone's PDF viewer.
  static Future<void> open(FeeItem f) => _run(f, (file) async {
        final res = await OpenFilex.open(file.path, type: 'application/pdf');
        if (res.type != ResultType.done) {
          // No PDF viewer installed: fall back to the share sheet.
          await _share(f, file);
        }
      });

  /// Generates the PDF and opens the share sheet (WhatsApp, email, Drive...).
  static Future<void> share(FeeItem f) => _run(f, (file) => _share(f, file));

  static Future<void> _share(FeeItem f, File file) => SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: '${f.isPaid ? 'Receipt' : 'Invoice'} ${_number(f)}',
          text: '${f.isPaid ? 'Payment receipt' : 'Invoice'} ${_number(f)} – ${_money(f.amount)}',
        ),
      );

  static Future<void> _run(FeeItem f, Future<void> Function(File) then) async {
    try {
      final file = await _build(f);
      await then(file);
    } catch (e) {
      Get.snackbar('Could not create receipt', 'Please try again.\n$e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<File> _build(FeeItem f) async {
    final store = GetStorage();
    final name = (store.read(PrefConst.userName) ?? '').toString();
    final email = (store.read(PrefConst.userEmail) ?? '').toString();
    final phone = (store.read(PrefConst.userPhone) ?? '').toString();

    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/images/icon_logo.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final paidDoc = f.isPaid || f.isPartial;
    final title = paidDoc ? 'PAYMENT RECEIPT' : 'INVOICE';
    final (statusText, statusColor) = f.isPaid
        ? ('PAID', _green)
        : f.isPartial
            ? ('PARTIALLY PAID', _amber)
            : ((f.status ?? 'DUE').toUpperCase(), _red);
    final period = [
      if (f.durationType != null) f.durationType!,
      if (f.monthNumber != null) 'Month ${f.monthNumber}',
    ].join(' • ');
    final balance = f.balanceAmount < 0 ? 0 : f.balanceAmount;

    pw.TextStyle t(double size, {bool bold = false, PdfColor color = _dark}) =>
        pw.TextStyle(fontSize: size, color: color, fontWeight: bold ? pw.FontWeight.bold : null);

    pw.Widget kv(String k, String v) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(children: [
            pw.SizedBox(width: 90, child: pw.Text(k, style: t(10, color: _muted))),
            pw.Expanded(child: pw.Text(v, style: t(10))),
          ]),
        );

    pw.Widget cell(String s, {bool head = false, bool right = false, PdfColor? color}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: pw.Text(s,
              textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
              style: t(head ? 9.5 : 10.5,
                  bold: head, color: head ? PdfColors.white : (color ?? _dark))),
        );

    final doc = pw.Document(title: '$title ${_number(f)}', author: 'FitDesk');
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header band — black into purple, like the app.
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(colors: [_dark, _purple]),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Row(
                children: [
                  if (logo != null) ...[
                    pw.Container(
                      width: 46,
                      height: 46,
                      child: pw.ClipRRect(
                          horizontalRadius: 8, verticalRadius: 8, child: pw.Image(logo)),
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('FitDesk', style: t(20, bold: true, color: PdfColors.white)),
                        pw.Text('Gym membership', style: t(10, color: PdfColors.grey300)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(title, style: t(13, bold: true, color: PdfColors.white)),
                      pw.SizedBox(height: 2),
                      pw.Text('# ${_number(f)}', style: t(10, color: PdfColors.grey300)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 22),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILLED TO', style: t(9, bold: true, color: _muted)),
                      pw.SizedBox(height: 6),
                      pw.Text(name.isEmpty ? 'Member' : name, style: t(13, bold: true)),
                      if (email.isNotEmpty) pw.Text(email, style: t(10, color: _muted)),
                      if (phone.isNotEmpty) pw.Text(phone, style: t(10, color: _muted)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      kv('Issued on', DateFormat('dd MMM yyyy').format(DateTime.now())),
                      kv('Due date', _date(f.dueDate)),
                      if (f.paidDate != null) kv('Paid on', _date(f.paidDate)),
                      if (f.paymentMethod != null) kv('Payment mode', f.paymentMethod!.toUpperCase()),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 22),

            pw.Table(
              border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: _line),
                  bottom: pw.BorderSide(color: _line)),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1.4),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(1.4),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _purple),
                  children: [
                    cell('DESCRIPTION', head: true),
                    cell('AMOUNT', head: true, right: true),
                    cell('PAID', head: true, right: true),
                    cell('BALANCE', head: true, right: true),
                  ],
                ),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(f.title ?? 'Membership fee', style: t(10.5, bold: true)),
                        if (period.isNotEmpty) pw.Text(period, style: t(9, color: _muted)),
                      ],
                    ),
                  ),
                  cell(_money(f.amount), right: true),
                  cell(_money(f.paidAmount), right: true, color: _green),
                  cell(_money(balance), right: true, color: balance > 0 ? _amber : _dark),
                ]),
              ],
            ),
            pw.SizedBox(height: 18),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: statusColor, width: 1.5),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(statusText, style: t(11, bold: true, color: statusColor)),
                ),
                pw.Spacer(),
                pw.SizedBox(
                  width: 210,
                  child: pw.Column(children: [
                    _totalRow('Total', _money(f.amount), t(10.5)),
                    _totalRow('Amount paid', _money(f.paidAmount), t(10.5, color: _green)),
                    pw.Divider(color: _line),
                    _totalRow('Balance due', _money(balance), t(13, bold: true)),
                  ]),
                ),
              ],
            ),

            if (f.notes != null) ...[
              pw.SizedBox(height: 18),
              pw.Text('NOTES', style: t(9, bold: true, color: _muted)),
              pw.SizedBox(height: 4),
              pw.Text(f.notes!, style: t(10)),
            ],

            pw.Spacer(),
            pw.Divider(color: _line),
            pw.Center(
              child: pw.Text(
                'This is a computer-generated ${paidDoc ? 'receipt' : 'invoice'} and does not need a signature.',
                style: t(8.5, color: _muted),
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final safe = _number(f).replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final file = File('${dir.path}/${paidDoc ? 'Receipt' : 'Invoice'}_$safe.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _totalRow(String k, String v, pw.TextStyle style) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(children: [
          pw.Expanded(child: pw.Text(k, style: style)),
          pw.Text(v, style: style),
        ]),
      );
}
