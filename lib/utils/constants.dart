import 'package:intl/intl.dart';

// const String baseUrl = 'http://192.168.221.22:8000/api';
const String baseUrl = 'http://api.safetynecessary.com/api';
// const String baseUrl = 'http://10.0.2.2:8000/api';
// const String baseUrl = 'http://smart_parking.test/api';

const String loginEndpoint = '$baseUrl/login';
// Add other endpoints here as needed

const defaultButtonBorderRadius = 12.0;

class Globals {
  static numberFormat(number) {
    final currencyFormatter = NumberFormat("#,##0", "en_US");
    return currencyFormatter.format(number);
  }
}
