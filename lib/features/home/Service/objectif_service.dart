// 📁 lib/services/objectif_service.dart
import 'package:dio/dio.dart';
import 'package:pfe/core/utils/app_services.dart';
import '../models/objectif_model.dart';


class ObjectifService {
  final Dio _dio = ApiService().dio;

  Future<Map<int, List<ObjectifModel>>> getGroupedByYear() async {
    print('ObjectifService: Starting getGroupedByYear API call...'); // Log start
    try {
      final response = await _dio.get('/objectifs/me/by-year');
      print('ObjectifService: API call /objectifs/me/by-year finished.'); // Log after call
      print('ObjectifService: Status Code: ${response.statusCode}'); // Log status code
      print('ObjectifService: Response Data Type: ${response.data.runtimeType}'); // Log data type
      print('ObjectifService: Response Data (first 500 chars): ${response.data.toString().substring(0, (response.data.toString().length > 500 ? 500 : response.data.toString().length))}'); // Log data (partial)

      if (response.statusCode == 200) {
        print('ObjectifService: Processing response data...'); // Log before processing
        final data = response.data as List;
        print('ObjectifService: Data cast to List. Items count: ${data.length}'); // Log data count

        Map<int, List<ObjectifModel>> grouped = {};
        for (var item in data) {
          // print('ObjectifService: Processing item: $item'); // Uncomment for detailed item logging
          try {
             final model = ObjectifModel.fromJson(item);
             grouped.putIfAbsent(model.annee, () => []).add(model);
             // print('ObjectifService: Processed item for year ${model.annee}'); // Uncomment for detailed item logging
          } catch (e) {
             print('ObjectifService: Error processing item $item: $e'); // Log item processing error
          }
        }
        print('ObjectifService: Data processing complete. Grouped years count: ${grouped.length}'); // Log processing complete
        return grouped;
      } else {
         print('ObjectifService: API call failed with status ${response.statusCode}'); // Log non-200 status
         // Depending on how you want to handle API errors, you might throw an exception
         // throw Exception('API call failed with status ${response.statusCode}');
         return {}; // Return empty map on failure
      }
    } catch (e) {
      print("❌ ObjectifService: Exception caught in getGroupedByYear: $e"); // Log caught exception
      // Re-throw or handle the exception as needed
      // throw e;
      return {}; // Return empty map on error
    } finally {
      print('ObjectifService: getGroupedByYear finished.'); // Log finish
    }
  }

  Future<List<Map<String, dynamic>>> getSalesByCategory() async {
     print('ObjectifService: Starting getSalesByCategory API call...'); // Log start
     try {
        final response = await _dio.get('/objectifs/me/sales-by-category');
        print('ObjectifService: API call /objectifs/me/sales-by-category finished.'); // Log after call
        print('ObjectifService: Status Code: ${response.statusCode}'); // Log status code
        print('ObjectifService: Response Data Type: ${response.data.runtimeType}'); // Log data type
        print('ObjectifService: Response Data (first 500 chars): ${response.data.toString().substring(0, (response.data.toString().length > 500 ? 500 : response.data.toString().length))}'); // Log data (partial)

        if (response.statusCode == 200) {
          print('ObjectifService: Processing sales data...'); // Log before processing
          final salesData = List<Map<String, dynamic>>.from(response.data);
          print('ObjectifService: Sales data processing complete. Items count: ${salesData.length}'); // Log processing complete
          return salesData;
        } else {
           print('ObjectifService: API call failed with status ${response.statusCode}'); // Log non-200 status
           return []; // Return empty list on failure
        }
     } catch (e) {
        print("❌ ObjectifService: Exception caught in getSalesByCategory: $e"); // Log caught exception
        return []; // Return empty list on error
     } finally {
        print('ObjectifService: getSalesByCategory finished.'); // Log finish
     }
  }
}
