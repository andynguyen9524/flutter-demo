// Hàm trợ giúp để parse một giá trị động (dynamic value) thành String? một cách an toàn.
// Nếu giá trị là null, là String, hoặc là List rỗng, nó sẽ trả về String? hoặc null.
// Bất kỳ kiểu nào khác sẽ được coi là null để tránh lỗi.
String? _parseNullableString(dynamic jsonValue) {
  if (jsonValue == null) {
    return null;
  }
  if (jsonValue is String) {
    return jsonValue;
  }
  // Nếu là List (ví dụ: [] ), chúng ta có thể kiểm tra xem nó có rỗng không.
  // Nếu rỗng, coi như null. Nếu không rỗng và không phải String, vẫn coi là null để tránh lỗi.
  if (jsonValue is List && jsonValue.isEmpty) {
    return null;
  }
  // Nếu là bất kỳ kiểu nào khác không phải String và không null/List rỗng,
  // chúng ta cũng trả về null để đảm bảo an toàn kiểu.
  return null;
}

class NewsApiResponse {
  // Đã thay đổi các trường từ required thành nullable (có thể null)
  final String? status;
  final String? requestId;
  final int? size;
  final int? totalHits;
  final int? hitsPerPage;
  final int? page;
  final int? totalPages;
  final int? timeMs;
  final List<Article>? data; // Danh sách các bài viết cũng có thể null

  NewsApiResponse({
    this.status, // Không còn required
    this.requestId, // Không còn required
    this.size, // Không còn required
    this.totalHits, // Không còn required
    this.hitsPerPage, // Không còn required
    this.page, // Không còn required
    this.totalPages, // Không còn required
    this.timeMs, // Không còn required
    this.data, // Không còn required
  });

  factory NewsApiResponse.fromJson(Map<String, dynamic> json) {
    return NewsApiResponse(
      // Parse các trường int? và String?
      status: json['status'] as String?,
      requestId: json['request_id'] as String?,
      size: json['size'] as int?,
      totalHits: json['totalHits'] as int?,
      hitsPerPage: json['hitsPerPage'] as int?,
      page: json['page'] as int?,
      totalPages: json['totalPages'] as int?,
      timeMs: json['timeMs'] as int?,
      // Xử lý List<Article>? : nếu 'data' null, thì 'data' trong model cũng sẽ null.
      // Nếu không muốn nó là null mà muốn là List rỗng, hãy dùng:
      // data: (json['data'] as List<dynamic>?)?.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      // Nhưng theo yêu cầu là "có thể là null", nên tôi để nó là List<Article>?
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'request_id': requestId,
      'size': size,
      'totalHits': totalHits,
      'hitsPerPage': hitsPerPage,
      'page': page,
      'totalPages': totalPages,
      'timeMs': timeMs,
      'data':
          data
              ?.map((e) => e.toJson())
              .toList(), // Dùng ?.map để an toàn nếu data là null
    };
  }
}

// Class đại diện cho một bài viết tin tức
class Article {
  final String title;
  final String url;
  final String excerpt; // ĐÃ THAY ĐỔI: từ 'snippet' thành 'excerpt'
  final String?
  thumbnail; // ĐÃ THAY ĐỔI: từ 'photoUrl'/'thumbnailUrl' thành 'thumbnail'
  final String language;
  final bool paywall;
  final int contentLength;
  final String date; // ĐÃ THAY ĐỔI: từ 'publishedDatetimeUtc' thành 'date'
  final List<String> authors; // Danh sách tác giả
  final List<String> keywords; // Danh sách từ khóa
  final Publisher publisher; // Thông tin nhà xuất bản

  Article({
    required this.title,
    required this.url,
    required this.excerpt,
    this.thumbnail,
    required this.language,
    required this.paywall,
    required this.contentLength,
    required this.date,
    required this.authors,
    required this.keywords,
    required this.publisher,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      // Áp dụng (json['key'] as String?) ?? '' cho tất cả các chuỗi không nullable
      title: (json['title'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      excerpt: (json['excerpt'] as String?) ?? '', // ĐÃ THAY ĐỔI
      thumbnail: _parseNullableString(json['thumbnail']), // ĐÃ THAY ĐỔI
      language: (json['language'] as String?) ?? '',
      paywall: (json['paywall'] as bool?) ?? false, // Xử lý bool có thể null
      contentLength:
          (json['contentLength'] as int?) ?? 0, // Xử lý int có thể null
      date: (json['date'] as String?) ?? '', // ĐÃ THAY ĐỔI
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
      publisher: Publisher.fromJson(json['publisher'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'excerpt': excerpt, // ĐÃ THAY ĐỔI
      'thumbnail': thumbnail, // ĐÃ THAY ĐỔI
      'language': language,
      'paywall': paywall,
      'contentLength': contentLength,
      'date': date, // ĐÃ THAY ĐỔI
      'authors': authors,
      'keywords': keywords,
      'publisher': publisher.toJson(),
    };
  }
}

// Class đại diện cho thông tin nhà xuất bản
class Publisher {
  final String name;
  final String url;
  final String? favicon; // ĐÃ THAY ĐỔI: từ 'sourceFaviconUrl' thành 'favicon'

  Publisher({required this.name, required this.url, this.favicon});

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      // Áp dụng (json['key'] as String?) ?? '' cho tất cả các chuỗi không nullable
      name: (json['name'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      favicon: _parseNullableString(json['favicon']), // ĐÃ THAY ĐỔI
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'favicon': favicon};
  }
}
