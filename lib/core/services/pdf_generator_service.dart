// lib/core/services/pdf_generator_service.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../features/documents/models/asset_handover.dart';
import '../../features/documents/models/no_dues_certificate.dart';

class PdfGeneratorService {
  static const String companyName = 'EXPERIENCEFLOW SOFTWARE TECHNOLOGIES PVT LTD';
  static const String companyTagline = 'Digital Nervous System';

  // Generate Asset Handover Report PDF
  static Future<Uint8List> generateAssetHandoverPdf(AssetHandover handover) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            _buildAssetHandoverHeader(),
            pw.SizedBox(height: 30),
            _buildAssetHandoverContent(handover),
            pw.SizedBox(height: 30),
            _buildAssetHandoverTable(handover.assets),
            pw.SizedBox(height: 30),
            _buildAssetHandoverTerms(),
            pw.SizedBox(height: 30),
            _buildAssetHandoverSignatures(handover),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Generate No Dues Certificate PDF
  static Future<Uint8List> generateNoDuesCertificatePdf(NoDuesCertificate certificate) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            _buildNoDuesHeader(),
            pw.SizedBox(height: 30),
            _buildNoDuesContent(certificate),
            pw.SizedBox(height: 20),
            _buildNoDuesChecklist(certificate.checklist),
            pw.SizedBox(height: 30),
            _buildNoDuesSignatures(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Asset Handover PDF Components
  static pw.Widget _buildAssetHandoverHeader() {
    return pw.Column(
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Column(
            children: [
              pw.Text(
                'experienceflow',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.Text(
                companyTagline,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Asset Handover Report',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAssetHandoverContent(AssetHandover handover) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(120),
          1: const pw.FlexColumnWidth(),
          2: const pw.FixedColumnWidth(120),
          3: const pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              _buildTableCell('Employee Name:', true),
              _buildTableCell(handover.employeeName, false),
              _buildTableCell('Asset:', true),
              _buildTableCell('', false),
            ],
          ),
          pw.TableRow(
            children: [
              _buildTableCell('Employee Code:', true),
              _buildTableCell(handover.employeeCode, false),
              _buildTableCell('Handover Date:', true),
              _buildTableCell(DateFormat('dd/MM/yyyy').format(handover.handoverDate), false),
            ],
          ),
          pw.TableRow(
            children: [
              _buildTableCell('Role:', true),
              _buildTableCell(handover.role, false),
              _buildTableCell('Handover by:', true),
              _buildTableCell(handover.handoverBy, false),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAssetHandoverTable(List<HandoverAsset> assets) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Please find the assets below handed over to you, to support you in carrying out your assignment proficiently.',
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FixedColumnWidth(40),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: [
                _buildTableHeaderCell('Sl. No.'),
                _buildTableHeaderCell('Particulars'),
                _buildTableHeaderCell('Asset Code'),
                _buildTableHeaderCell('Serial No'),
                _buildTableHeaderCell('Condition'),
              ],
            ),
            // Asset rows
            ...assets.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final asset = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableDataCell(index.toString()),
                  _buildTableDataCell(asset.particulars),
                  _buildTableDataCell(asset.assetCode),
                  _buildTableDataCell(asset.serialNo),
                  _buildTableDataCell(asset.condition),
                ],
              );
            }),
            // Empty rows if needed
            ...List.generate(3 - assets.length > 0 ? 3 - assets.length : 0, (index) {
              return pw.TableRow(
                children: [
                  _buildTableDataCell((assets.length + index + 1).toString()),
                  _buildTableDataCell(''),
                  _buildTableDataCell(''),
                  _buildTableDataCell(''),
                  _buildTableDataCell(''),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAssetHandoverTerms() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Terms and Conditions:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        _buildTermItem('1.', 'The assets listed above remain the property of $companyName and are provided to employees for official purposes only.'),
        _buildTermItem('2.', 'Employees are responsible for the safekeeping and maintenance of assets assigned to them.'),
        _buildTermItem('3.', 'Any loss or damage to the assets, unless due to unforeseen circumstances, will be borne by the employee.'),
        _buildTermItem('4.', 'Assets should be returned in good condition upon the termination or resignation of the employee.'),
        _buildTermItem('5.', 'The Asset Management Officer may conduct periodic checks and audits to ensure the condition and whereabouts of the assets.'),
      ],
    );
  }

  static pw.Widget _buildAssetHandoverSignatures(AssetHandover handover) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Acknowledgement and Declaration by Employee:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'I, ${handover.employeeName} acknowledge that I have received the abovementioned assets and agree to the terms and conditions set by $companyName. I understand that these assets are the property of [$companyName] and I will use them for official purposes only.',
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Employee Signature: _______________________'),
                pw.SizedBox(height: 5),
                pw.Text('Date: _______________________'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('IT Signature: _______________________'),
                pw.SizedBox(height: 5),
                pw.Text('Date: ___________________'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // No Dues Certificate PDF Components
  static pw.Widget _buildNoDuesHeader() {
    return pw.Column(
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Column(
            children: [
              pw.Text(
                'experienceflow',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.Text(
                companyTagline,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'NO DUES CERTIFICATE',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildNoDuesContent(NoDuesCertificate certificate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            style: pw.TextStyle(fontSize: 12),
            children: [
              pw.TextSpan(text: 'This is to certify that '),
              pw.TextSpan(
                text: certificate.employeeName,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: ', Employee Code: '),
              pw.TextSpan(
                text: certificate.employeeCode,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: ' working as '),
              pw.TextSpan(
                text: certificate.role,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: ', has resigned on '),
              pw.TextSpan(
                text: DateFormat('dd/MM/yyyy').format(certificate.resignationDate),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: ' and will be relieved from service. His last working day is '),
              pw.TextSpan(
                text: DateFormat('dd/MM/yyyy').format(certificate.lastWorkingDay),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: ' at the office closing hours.'),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'The following checklist ensures all exit formalities are completed:',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildNoDuesChecklist(List<ExitChecklistItem> checklist) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        border: pw.Border.all(color: PdfColors.orange300),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(color: PdfColors.orange100),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Checklist',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FixedColumnWidth(40),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildTableHeaderCell('S. No'),
                  _buildTableHeaderCell('Particular'),
                  _buildTableHeaderCell('Status'),
                  _buildTableHeaderCell('Responsible Person'),
                ],
              ),
              ...checklist.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableDataCell(index.toString()),
                    _buildTableDataCell(item.particular + (item.details != null ? '\n${item.details}' : '')),
                    _buildTableDataCell(_getStatusDisplay(item.status)),
                    _buildTableDataCell(item.responsiblePerson),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNoDuesSignatures() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Signature of Employee: __________________________'),
                pw.SizedBox(height: 20),
              ],
            ),
            pw.Text('.'),
          ],
        ),
        pw.Row(
          children: [
            pw.Text('Signature of Responsible Person: _______________________'),
          ],
        ),
      ],
    );
  }

  // Helper methods
  static pw.Widget _buildTableCell(String text, bool isBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableDataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11),
      ),
    );
  }

  static pw.Widget _buildTermItem(String number, String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 20,
            child: pw.Text(number, style: pw.TextStyle(fontSize: 12)),
          ),
          pw.Expanded(
            child: pw.Text(text, style: pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  static String _getStatusDisplay(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.completed:
        return '✓ Completed';
      case ChecklistStatus.pending:
        return '○ Pending';
      case ChecklistStatus.notApplicable:
        return 'N/A';
    }
  }

  // Print or save PDF methods
  static Future<void> printAssetHandover(AssetHandover handover) async {
    final pdfData = await generateAssetHandoverPdf(handover);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Asset_Handover_${handover.employeeName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(handover.handoverDate)}',
    );
  }

  static Future<void> printNoDuesCertificate(NoDuesCertificate certificate) async {
    final pdfData = await generateNoDuesCertificatePdf(certificate);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'No_Dues_Certificate_${certificate.employeeName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(certificate.certificateDate)}',
    );
  }
}