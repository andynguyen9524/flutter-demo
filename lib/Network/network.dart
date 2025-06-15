import 'package:dio/dio.dart';
import 'package:flutter_application_demo/models/new_api_model.dart';
import 'package:dartz/dartz.dart';

class Network {
  // Singleton instance
  static final Network _instance = Network._internal();

  // Private constructor
  Network._internal();

  // Factory constructor
  factory Network() => _instance;

  final Dio _dio = Dio();

  Future<Either<String, List<Article>>> fetchNews(int currentPage) async {
    try {
      final String apiUrl =
          'https://news-api14.p.rapidapi.com/v2/trendings?topic=World&language=en&page=$currentPage&limit=5';

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'X-RapidAPI-Host': 'news-api14.p.rapidapi.com',
            'X-RapidAPI-Key':
                '92c708b985mshf441688a08bbcc3p143eb1jsn420f130265f2',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final NewsApiResponse newApiResponse = NewsApiResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
          return Right(newApiResponse.data ?? []);
        } else {
          return Left(
            'Phản hồi API có định dạng không mong muốn. Nhận được kiểu: ${response.data.runtimeType}',
          );
        }
      } else {
        return Left(
          'Không thể tải tin tức: ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.message!);
      }
      return Left('Lỗi kết nối mạng hoặc không nhận được phản hồi từ máy chủ.');
    } catch (e) {
      return Left('Loi khong xac dinh duoc');
    }
  }
}


