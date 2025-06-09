import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_application_demo/models/new_api_model.dart'; // Import model tin tức
import 'package:url_launcher/url_launcher.dart'; // Để mở link bài viết

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  NewsApiResponse? _newsData; // Biến để lưu trữ dữ liệu tin tức
  bool _isLoading = false; // Cờ trạng thái tải
  String? _errorMessage; // Thông báo lỗi

  // Khởi tạo Dio instance
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchNews(); // Tải tin tức khi màn hình được tạo
  }

  // Hàm bất đồng bộ để lấy tin tức từ API
  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      const String apiUrl =
          'https://news-api14.p.rapidapi.com/v2/trendings?topic=Sports&language=en';

      final response = await _dio.get(
        apiUrl,
        queryParameters: {
          'q':
              'technology', // Ví dụ: Tìm kiếm tin tức về công nghệ. Bạn có thể thay đổi chủ đề.
          'lang': 'en', // Ngôn ngữ tiếng Anh
          'country': 'us', // Quốc gia Hoa Kỳ
          'media': 'True', // Bao gồm các bài viết có ảnh
          'page_size': 10, // Lấy 10 bài viết mỗi lần
        },
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
          setState(() {
            _newsData = NewsApiResponse.fromJson(
              response.data as Map<String, dynamic>,
            );
          });
        } else {
          setState(() {
            _errorMessage =
                'Phản hồi API có định dạng không mong muốn. Nhận được kiểu: ${response.data.runtimeType}';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Không thể tải tin tức: ${response.statusCode} - ${response.statusMessage}';
        });
      }
    } on DioError catch (e) {
      if (e.response != null) {
        _errorMessage =
            'Lỗi API: ${e.response!.statusCode} - ${e.response!.statusMessage ?? 'Không có thông báo'}';
        if (e.response!.statusCode == 403) {
          _errorMessage =
              'Lỗi 403: Có thể do API Key không hợp lệ hoặc giới hạn truy cập. Vui lòng kiểm tra lại API Key và gói RapidAPI của bạn.';
        } else if (e.response!.statusCode == 429) {
          _errorMessage =
              'Lỗi 429: Vượt quá giới hạn số lượt gọi API. Vui lòng thử lại sau.';
        }
      } else {
        _errorMessage =
            'Lỗi mạng hoặc kết nối: ${e.message ?? 'Không có thông báo'}';
      }
      setState(() {
        _errorMessage = _errorMessage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi không xác định: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm mở URL trong trình duyệt
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Không thể mở $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Tức Công Nghệ'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchNews,
            tooltip: 'Làm mới tin tức',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueGrey),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchNews,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
              : _newsData == null || _newsData!.data!.isEmpty
              ? const Center(
                child: Text(
                  'Không có tin tức để hiển thị. Vui lòng thử lại.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _newsData!.data!.length,
                itemBuilder: (context, index) {
                  final article = _newsData!.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      // Dùng InkWell để tạo hiệu ứng nhấp
                      onTap: () => _launchUrl(article.url), // Mở link bài viết
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.thumbnail != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  article.thumbnail!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.excerpt,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  article
                                      .publisher
                                      .name, // Hiển thị tên nhà xuất bản
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(
                                    article.date,
                                  ), // Định dạng ngày giờ
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (article.authors.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Tác giả: ${article.authors.join(', ')}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            if (article.keywords.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Từ khóa: ${article.keywords.join(', ')}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // Hàm để định dạng thời gian đọc được hơn
  String _formatDateTime(String datetimeString) {
    try {
      final DateTime dateTime = DateTime.parse(datetimeString);
      // Đã loại bỏ timeago.format(dateTime)
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return datetimeString; // Trả về nguyên bản nếu parse lỗi
    }
  }
}
