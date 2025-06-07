import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio

import '../models/metal_prices.dart';

class MetalPricesScreen extends StatefulWidget {
  const MetalPricesScreen({super.key});

  @override
  State<MetalPricesScreen> createState() => _MetalPricesScreenState();
}

class _MetalPricesScreenState extends State<MetalPricesScreen> {
  MetalPrices? _metalPrices; // Biến để lưu trữ dữ liệu giá kim loại
  bool _isLoading = false; // Cờ trạng thái tải
  String? _errorMessage; // Thông báo lỗi

  // Khởi tạo Dio instance
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchMetalPrices(); // Tải giá khi màn hình được tạo
  }

  // Hàm bất đồng bộ để lấy giá kim loại từ API
  Future<void> _fetchMetalPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // URL của API "Live Metal Prices" trên RapidAPI
      const String apiUrl =
          'https://live-metal-prices.p.rapidapi.com/v1/latest/XAU,XAG,PA,PL,GBP,EUR/USD';

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'X-RapidAPI-Host': 'live-metal-prices.p.rapidapi.com',
            'X-RapidAPI-Key':
                '92c708b985mshf441688a08bbcc3p143eb1jsn420f130265f2', // <-- THAY THẾ BẰNG API KEY CỦA BẠN
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // KIỂM TRA KIỂU DỮ LIỆU CỦA response.data TRƯỚC KHI PARSE
        if (response.data is Map<String, dynamic>) {
          setState(() {
            _metalPrices = MetalPrices.fromJson(
              response.data as Map<String, dynamic>,
            );
          });
        } else {
          // Xử lý trường hợp response.data không phải là Map
          setState(() {
            _errorMessage =
                'Phản hồi API có định dạng không mong muốn. Nhận được kiểu: ${response.data.runtimeType}';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Không thể tải giá: ${response.statusCode} - ${response.statusMessage}';
        });
      }
    } on DioError catch (e) {
      if (e.response != null) {
        // Lỗi từ server (4xx, 5xx)
        _errorMessage =
            'Lỗi API: ${e.response!.statusCode} - ${e.response!.statusMessage ?? 'Không có thông báo'}';
        if (e.response!.statusCode == 403) {
          _errorMessage =
              'Lỗi 403: Có thể do API Key hoặc giới hạn truy cập. Vui lòng kiểm tra lại API Key và gói RapidAPI của bạn.';
        } else if (e.response!.statusCode == 429) {
          _errorMessage =
              'Lỗi 429: Vượt quá giới hạn số lượt gọi API. Vui lòng thử lại sau.';
        }
      } else {
        // Lỗi mạng hoặc các lỗi khác không có phản hồi HTTP
        _errorMessage =
            'Lỗi mạng: ${e.message ?? 'Không thể kết nối tới máy chủ.'}';
      }
      setState(() {
        _errorMessage = _errorMessage; // Cập nhật state với thông báo lỗi
      });
    } catch (e) {
      // Bắt các lỗi không xác định, đảm bảo chuyển đối tượng lỗi thành chuỗi một cách an toàn
      String finalErrorMessage;
      if (e is String) {
        // Nếu lỗi đã là một chuỗi
        finalErrorMessage = 'Lỗi không xác định: $e';
      } else if (e is List) {
        // Nếu lỗi là một List (như JSArray<dynamic>)
        finalErrorMessage =
            'Lỗi không xác định (định dạng List): ${e.toString()}';
      } else {
        // Trường hợp còn lại (Exception, Object, v.v.)
        finalErrorMessage = 'Lỗi không xác định: ${e.toString()}';
      }
      setState(() {
        _errorMessage = finalErrorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget hiển thị giá của một kim loại
  Widget _buildMetalPriceRow(
    String metalName,
    double? price,
    String currency,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$metalName:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            price != null
                ? '${price.toStringAsFixed(2)} $currency/$unit'
                : 'N/A',
            style: TextStyle(
              fontSize: 18,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị tỷ giá tiền tệ (tùy chọn)
  Widget _buildCurrencyRateRow(
    String currencyCode,
    double? rate,
    String baseCurrency,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$currencyCode / $baseCurrency:',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            rate != null ? rate.toStringAsFixed(4) : 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá Kim Loại Trực Tiếp'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                _isLoading
                    ? null
                    : _fetchMetalPrices, // Vô hiệu hóa khi đang tải
            tooltip: 'Làm mới giá',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
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
                        onPressed: _fetchMetalPrices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
              : _metalPrices == null
              ? const Center(
                child: Text(
                  'Không có dữ liệu giá. Vui lòng thử lại.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cập nhật gần nhất:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tiền tệ cơ sở: ${_metalPrices!.baseCurrency}, Đơn vị: ${_metalPrices!.unit}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 30),

                    // THAY ĐỔI: Truy cập giá trị thông qua _metalPrices!.rates!
                    _buildMetalPriceRow(
                      'Vàng (XAU)',
                      _metalPrices!.rates.xau,
                      _metalPrices!.baseCurrency,
                      _metalPrices!.unit,
                    ),
                    _buildMetalPriceRow(
                      'Bạc (XAG)',
                      _metalPrices!.rates.xag,
                      _metalPrices!.baseCurrency,
                      _metalPrices!.unit,
                    ),
                    _buildMetalPriceRow(
                      'Palladium (PA)',
                      _metalPrices!.rates.pa,
                      _metalPrices!.baseCurrency,
                      _metalPrices!.unit,
                    ),
                    _buildMetalPriceRow(
                      'Bạch kim (PL)',
                      _metalPrices!.rates.pl,
                      _metalPrices!.baseCurrency,
                      _metalPrices!.unit,
                    ),

                    const Divider(height: 30),
                    const Text(
                      'Tỷ giá ngoại tệ (liên quan):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // THAY ĐỔI: Truy cập tỷ giá thông qua _metalPrices!.rates!
                    _buildCurrencyRateRow(
                      'GBP',
                      _metalPrices!.rates.gbp,
                      _metalPrices!.baseCurrency,
                    ),
                    _buildCurrencyRateRow(
                      'EUR',
                      _metalPrices!.rates.eur,
                      _metalPrices!.baseCurrency,
                    ),

                    if (_metalPrices!.validationMessage != null &&
                        _metalPrices!.validationMessage!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Thông báo từ API: ${_metalPrices!.validationMessage!}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
