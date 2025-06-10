import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_demo/models/new_api_model.dart';

class NewFeedController {
  final List<Article> articles = []; // Danh sách các bài viết để hiển thị

  String? errorMessage; // Thông báo lỗi
  int currentPage = 1; // Trang hiện tại đang tải

  // Khởi tạo Dio instance
  final Dio _dio = Dio();

  Future resetNews() async {
    currentPage = 1;
    articles.clear();
    await fetchNews();
  }

  // Hàm bất đồng bộ để lấy tin tức từ API
  // `page`: Trang muốn tải
  // `isInitialLoad`: True nếu đây là lần tải đầu tiên, False nếu là tải thêm
  Future<void> fetchNews() async {
    // Tránh gọi API nhiều lần cùng lúc

    try {
      final String apiUrl =
          'https://news-api14.p.rapidapi.com/v2/trendings?topic=World&language=en&page=$currentPage&limit=5';

      ///v2/trendings?topic=Sports&language=en
      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'X-RapidAPI-Host': 'news-api14.p.rapidapi.com',
            'X-RapidAPI-Key':
                '92c708b985mshf441688a08bbcc3p143eb1jsn420f130265f2', // <-- THAY THẾ BẰNG API KEY CỦA BẠN
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final NewsApiResponse newApiResponse = NewsApiResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
          // Thêm các bài viết mới vào danh sách hiện có
          articles.addAll(newApiResponse.data ?? []);

          // Chuẩn bị cho lần tải tiếp theo
          currentPage = (newApiResponse.page ?? 0) + 1;
        } else {
          errorMessage =
              'Phản hồi API có định dạng không mong muốn. Nhận được kiểu: ${response.data.runtimeType}';
        }
      } else {
        errorMessage =
            'Không thể tải tin tức: ${response.statusCode} - ${response.statusMessage}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        errorMessage = e.message;
      }
    } catch (e) {
      errorMessage = 'Loi khong xac dinh duoc';
    }
  }
}
