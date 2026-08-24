import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pdf_service.dart';

final pdfServiceProvider = Provider(
  (ref) => PdfService(),
);