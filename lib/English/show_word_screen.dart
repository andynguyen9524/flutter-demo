import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import package dio
// Import để sử dụng json.decode (vẫn cần cho một số trường hợp)

class RandomWordScreen extends StatefulWidget {
  const RandomWordScreen({super.key});

  @override
  State<RandomWordScreen> createState() => _RandomWordScreenState();
}

class _RandomWordScreenState extends State<RandomWordScreen> {
  String _currentWord =
      'Nhấp vào màn hình để lấy từ mới'; // Từ hiện tại hiển thị
  bool _isLoading = false; // Trạng thái đang tải
  String? _errorMessage; // Thông báo lỗi nếu có

  // Tạo một instance của Dio
  final Dio _dio = Dio();

  // Hàm bất đồng bộ để lấy từ ngẫu nhiên từ API
  Future<void> _fetchRandomWord() async {
    if (_isLoading) return; // Tránh gọi API nhiều lần cùng lúc

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Xóa lỗi cũ
    });

    try {
      final String apiUrl = 'https://random-word-api.p.rapidapi.com/get_word';

      final response = await _dio.get(
        apiUrl,
        options: Options(
          // Cấu hình headers cho Dio
          headers: {
            'X-RapidAPI-Host': 'random-word-api.p.rapidapi.com',
            'X-RapidAPI-Key':
                '92c708b985mshf441688a08bbcc3p143eb1jsn420f130265f2', // <-- THAY THẾ BẰNG API KEY CỦA BẠN
          },
        ),
      );

      if (response.statusCode == 200) {
        // Thay đổi cách xử lý phản hồi:
        // Giả định API trả về một MẢNG chứa một chuỗi, ví dụ: ["word"]
        // Hoặc một ĐỐI TƯỢNG JSON, ví dụ: {"word": "hello"}
        // API này (random-word-api.p.rapidapi.com/random) thực tế trả về một MẢNG CHUỖI.
        // Tuy nhiên, lỗi bạn gặp cho thấy có thể API đã thay đổi hoặc bạn đang gọi nhầm API khác.
        // Tôi sẽ sửa theo hướng API trả về MẢNG CHUỖI, nhưng nếu vẫn lỗi, bạn cần kiểm tra lại cấu trúc JSON thực tế.

        if (response.data is List && (response.data as List).isNotEmpty) {
          // Trường hợp API trả về mảng chuỗi (ví dụ: ["word"])
          final List<dynamic> jsonResponse = response.data;
          setState(() {
            _currentWord = jsonResponse[0].toString().toUpperCase();
          });
        } else if (response.data is Map &&
            (response.data as Map).containsKey('word')) {
          // Trường hợp API trả về đối tượng JSON với key 'word' (ví dụ: {"word": "hello"})
          final Map<String, dynamic> jsonResponse = response.data;
          setState(() {
            _currentWord = jsonResponse['word'].toString().toUpperCase();
          });
        } else {
          // Trường hợp phản hồi không đúng định dạng mong muốn
          setState(() {
            _errorMessage =
                'Phản hồi API không đúng định dạng: ${response.data}';
          });
        }
      } else {
        // Dio thường ném DioError cho các mã trạng thái lỗi (4xx, 5xx)
        // Nhưng nếu không, chúng ta vẫn xử lý ở đây
        setState(() {
          _errorMessage =
              'Lỗi khi lấy từ: ${response.statusCode} - ${response.statusMessage}';
        });
      }
    } on DioException catch (e) {
      // Bắt lỗi cụ thể của Dio
      if (e.response != null) {
        setState(() {
          _errorMessage =
              'Lỗi API: ${e.response!.statusCode} - ${e.response!.statusMessage ?? 'Không có thông báo'}';
        });
      } else {
        setState(() {
          _errorMessage =
              'Lỗi mạng hoặc kết nối: ${e.message ?? 'Không có thông báo'}';
        });
      }
    } catch (e) {
      // Bắt các lỗi khác
      setState(() {
        _errorMessage = 'Lỗi không xác định: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random word'), // Đổi tiêu đề để phân biệt
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GestureDetector(
        // Sử dụng GestureDetector để bắt sự kiện nhấp vào bất kỳ đâu trên màn hình
        onTap:
            _isLoading ? null : _fetchRandomWord, // Không cho nhấp khi đang tải
        child: Container(
          // Container này giúp GestureDetector chiếm toàn bộ không gian
          color:
              Colors.transparent, // Màu trong suốt để không che mất background
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child:
                _isLoading
                    ? const CircularProgressIndicator(
                      color: Colors.deepOrange,
                    ) // Hiển thị loading khi đang tải
                    : _errorMessage != null
                    ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 46,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchRandomWord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Text(
                        //   'Từ của bạn:',
                        //   style: TextStyle(fontSize: 24, color: Colors.grey),
                        // ),
                        // const SizedBox(height: 20),
                        Text(
                          _currentWord,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // const Text(
                        //   '(Nhấp vào màn hình để lấy từ mới)',
                        //   style: TextStyle(fontSize: 16, color: Colors.grey),
                        // ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
