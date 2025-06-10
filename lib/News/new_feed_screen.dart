import 'package:flutter/material.dart';
import 'package:flutter_application_demo/News/new_feed_controller.dart';
import 'package:flutter_application_demo/News/new_feed_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // Để mở link bài viết

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  // Khởi tạo ScrollController để theo dõi vị trí cuộn
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Thêm listener để bắt sự kiện cuộn
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchNews(BuildContext context, {bool isRefesh = false}) {
    if (isRefesh) {
      context.read<NewFeedController>().resetNews();
    } else {
      context.read<NewFeedController>().fetchNews();
    }
  }

  // Hàm listener cho ScrollController
  void _onScroll() async {
    // Kiểm tra nếu đã cuộn gần đến cuối danh sách (ví dụ: 90% chiều dài)
    // và không đang tải, và còn trang để tải
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // fetchNews();
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
      ),
      body: BlocProvider(
        create: (context) {
          return NewFeedController()..fetchNews();
        },
        child: BlocBuilder<NewFeedController, NewFeedState>(
          builder: (context, state) {
            if (state is LoadingState) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blueGrey),
              );
            } else if (state is NoDataState) {
              return Text('No data!');
            } else if (state is ErrorState) {
              return Text(state.message);
            } else if (state is DataState) {
              return RefreshIndicator(
                onRefresh: () async {
                  fetchNews(context, isRefesh: true);
                },
                child: ListView.builder(
                  controller: _scrollController, // Gán controller vào ListView
                  padding: const EdgeInsets.all(8.0),
                  itemCount:
                      state.data.length +
                      1, // Thêm 1 item cho loading hoặc thông báo hết dữ liệu
                  itemBuilder: (context, index) {
                    // Hiển thị loading indicator ở cuối danh sách
                    if (index == state.data.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Colors.blueGrey,
                          ),
                        ),
                      );
                    }

                    final article = state.data[index];
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
              );
            }

            return SizedBox.shrink();
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
