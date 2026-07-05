import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(num value) => _rupiah.format(value);

String formatDate(DateTime d) =>
    DateFormat('dd MMM yyyy', 'id_ID').format(d);

String formatDateTime(DateTime d) =>
    DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d);

String formatTime(DateTime d) => DateFormat('HH:mm').format(d);
