import 'package:dio/dio.dart';
import '../network/dio_provider.dart';

class IPLocationService {
String? _cachedLocation;
Future<String> fetchLocation() async {
  if (_cachedLocation != null) return _cachedLocation!;
    try {
    final dio = getDio();
    dio.options.headers['Accept'] = 'application/json';

    final response = await dio.get('https://ifconfig.io/all.json');
    if (response.statusCode == 200) {
        final data = response.data;
        final ip = data['ip'] ?? 'Unknown IP';
        final countryCode = data['country_code'] ?? 'Unknown Country';
        _cachedLocation = "$ip — $countryCode";
        return _cachedLocation!;
    } else {
        return "Failed to get location";
    }
    } catch (e) {
    return "Error: $e";
    }


}


}
