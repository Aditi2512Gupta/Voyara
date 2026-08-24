import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> exportTrip({
    required String destination,
    required String itinerary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              destination,
              style: pw.TextStyle(fontSize: 24),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(itinerary),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}