class Rates {
  final double xau; // Gold
  final double xag; // Silver
  final double pa; // Palladium
  final double pl; // Platinum
  final double gbp; // British Pound (tỷ giá)
  final double eur; // Euro (tỷ giá)

  Rates({
    required this.xau,
    required this.xag,
    required this.pa,
    required this.pl,
    required this.gbp,
    required this.eur,
  });

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      xau: (json['XAU'] as num).toDouble(),
      xag: (json['XAG'] as num).toDouble(),
      pa: (json['PA'] as num).toDouble(),
      pl: (json['PL'] as num).toDouble(),
      gbp: (json['GBP'] as num).toDouble(),
      eur: (json['EUR'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'XAU': xau, 'XAG': xag, 'PA': pa, 'PL': pl, 'GBP': gbp, 'EUR': eur};
  }
}

class MetalPrices {
  final bool success;
  final String? validationMessage; // Giữ nguyên là String?
  final String baseCurrency;
  final String unit;
  final Rates rates;

  MetalPrices({
    required this.success,
    this.validationMessage,
    required this.baseCurrency,
    required this.unit,
    required this.rates,
  });

  // Factory constructor để parse từ Map<String, dynamic> (từ JSON)
  factory MetalPrices.fromJson(Map<String, dynamic> json) {
    // Xử lý validationMessage an toàn: chỉ gán nếu nó là String, ngược lại là null
    final dynamic rawValidationMessage = json['validationMessage'];
    String? parsedValidationMessage;
    if (rawValidationMessage is String) {
      parsedValidationMessage = rawValidationMessage;
    } else if (rawValidationMessage is List && rawValidationMessage.isEmpty) {
      // Nếu là List rỗng, coi như không có thông báo
      parsedValidationMessage = null;
    }
    // Trường hợp khác (ví dụ: List không rỗng, số, v.v.) cũng sẽ thành null

    return MetalPrices(
      success: json['success'] as bool,
      validationMessage: parsedValidationMessage, // Gán giá trị đã được xử lý
      baseCurrency: json['baseCurrency'] as String,
      unit: json['unit'] as String,
      rates: Rates.fromJson(json['rates'] as Map<String, dynamic>),
    );
  }

  // Tùy chọn: Chuyển đổi đối tượng sang Map để dễ debug hoặc gửi đi
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'validationMessage': validationMessage,
      'baseCurrency': baseCurrency,
      'unit': unit,
      'rates': rates.toJson(),
    };
  }
}
