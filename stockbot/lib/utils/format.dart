import 'package:intl/intl.dart';

class Format {
  static const _format = "'\$'#,##0.00";
  static const _growthPercentFormat = "'+'#,##0.00%;'-'#,##0.00%";
  static const _percentFormat = "#,##0.0%";
  static const _locale = "en_US";

  static final currency = new NumberFormat(_format, _locale);
  static final growthPercentage =
      new NumberFormat(_growthPercentFormat, _locale);
  static final percentage = new NumberFormat(_percentFormat, _locale);
}
