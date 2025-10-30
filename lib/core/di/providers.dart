import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';

// Expose Dio for repositories
final dioProvider = Provider((ref) => DioClient().dio);
