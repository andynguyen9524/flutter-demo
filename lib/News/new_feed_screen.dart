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
  final List<Article> _articles = []; // Danh sách các bài viết để hiển thị
  bool _isLoading = false; // Cờ trạng thái tải ban đầu
  String? _errorMessage; // Thông báo lỗi
  int _currentPage = 1; // Trang hiện tại đang tải

  // Khởi tạo ScrollController để theo dõi vị trí cuộn
  final ScrollController _scrollController = ScrollController();

  // Khởi tạo Dio instance
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();

    _fetchNews(page: _currentPage); // Tải tin tức ban đầu khi màn hình được tạo
    // Thêm listener để bắt sự kiện cuộn
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm listener cho ScrollController
  void _onScroll() {
    // Kiểm tra nếu đã cuộn gần đến cuối danh sách (ví dụ: 90% chiều dài)
    // và không đang tải, và còn trang để tải
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading) {
      print('Đã cuộn gần cuối, tải thêm dữ liệu...');
      _fetchNews(page: _currentPage);
    }
  }

  // Hàm bất đồng bộ để lấy tin tức từ API
  // `page`: Trang muốn tải
  // `isInitialLoad`: True nếu đây là lần tải đầu tiên, False nếu là tải thêm
  Future<void> _fetchNews({required int page}) async {
    // Tránh gọi API nhiều lần cùng lúc
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl =
          'https://news-api14.p.rapidapi.com/v2/trendings?topic=World&language=en&page=$page&limit=5';

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
          setState(() {
            // Thêm các bài viết mới vào danh sách hiện có
            _articles.addAll(newApiResponse.data ?? []);

            // Chuẩn bị cho lần tải tiếp theo
            _currentPage = (newApiResponse.page ?? 0) + 1;
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
    } on DioException catch (e) {
      if (e.response != null) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Loi khong xac dinh duoc';
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
        title: const Text('Tin Tức Thời Gian Thực'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // ĐÃ SỬA: Thêm page: 1 vào lời gọi hàm _fetchNews
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      _currentPage = 1;
                      _articles.clear();
                      await _fetchNews(page: _currentPage);
                      setState(() {});
                    }, // Vô hiệu hóa khi đang tải
            tooltip: 'Làm mới tin tức',
          ),
        ],
      ),
      body:
          _isLoading &&
                  _articles
                      .isEmpty // Chỉ hiển thị loading ban đầu nếu chưa có bài viết nào
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
                        // ĐÃ SỬA: Thêm page: 1 vào lời gọi hàm _fetchNews
                        onPressed:
                            _isLoading ? null : () => _fetchNews(page: 1),
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
              : _articles.isEmpty && !_isLoading && _errorMessage == null
              ? const Center(
                // Trường hợp không có dữ liệu sau khi tải
                child: Text(
                  'Không có tin tức để hiển thị.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  _currentPage = 1;
                  _articles.clear();
                  await _fetchNews(page: _currentPage);
                  setState(() {});
                },
                child: ListView.builder(
                  controller: _scrollController, // Gán controller vào ListView
                  padding: const EdgeInsets.all(8.0),
                  itemCount:
                      _articles.length +
                      1, // Thêm 1 item cho loading hoặc thông báo hết dữ liệu
                  itemBuilder: (context, index) {
                    // Hiển thị loading indicator ở cuối danh sách
                    if (index == _articles.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Colors.blueGrey,
                          ),
                        ),
                      );
                    }

                    final article = _articles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: () => _launchUrl(article.url),
                        borderRadius: BorderRadius.circular(12.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article.thumbnail != null &&
                                  article
                                      .thumbnail!
                                      .isNotEmpty) // Kiểm tra cả isNotEmpty
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    article.thumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
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
                                article.excerpt, // Đã đổi từ snippet
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    article.publisher.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(
                                      article.date,
                                    ), // Đã đổi từ publishedDatetimeUtc
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
              ),
    );
  }

  // Hàm để định dạng thời gian đọc được hơn
  String _formatDateTime(String datetimeString) {
    try {
      final DateTime dateTime = DateTime.parse(datetimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return datetimeString; // Trả về nguyên bản nếu parse lỗi
    }
  }
}
