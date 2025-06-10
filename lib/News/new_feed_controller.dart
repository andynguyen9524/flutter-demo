import 'package:flutter_application_demo/Network/network.dart';
import 'package:flutter_application_demo/models/new_api_model.dart';

class NewFeedController {
  final List<Article> articles = []; // Danh sách các bài viết để hiển thị

  String? errorMessage; // Thông báo lỗi
  int _currentPage = 1; // Trang hiện tại đang tải

  Future resetNews() async {
    _currentPage = 1;
    articles.clear();
    await fetchNews();
  }

  // Hàm bất đồng bộ để lấy tin tức từ API
  // `page`: Trang muốn tải
  // `isInitialLoad`: True nếu đây là lần tải đầu tiên, False nếu là tải thêm
  Future<void> fetchNews() async {
    // Tránh gọi API nhiều lần cùng lúc

    final result = await Network().fetchNews(_currentPage);
    result.fold(
      (l) {
        errorMessage = l;
      },
      (r) {
        articles.addAll(r);
        _currentPage++;
      },
    );
  }
}
