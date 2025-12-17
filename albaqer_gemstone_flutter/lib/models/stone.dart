class Stone {
  final int? id;
  final String name;
  final String? color;
  final String? cut;
  final String? origin;
  final double? caratWeight;
  final String? sizeMm;
  final String? clarity;
  final double price;
  final String? imageUrl;
  final double rating;

  Stone({
    this.id,
    required this.name,
    this.color,
    this.cut,
    this.origin,
    this.caratWeight,
    this.sizeMm,
    this.clarity,
    required this.price,
    this.imageUrl,
    this.rating = 0.0,
  });

  Map<String, dynamic> get stoneMap {
    return {
      'id': id,
      'name': name,
      'color': color,
      'cut': cut,
      'origin': origin,
      'carat_weight': caratWeight,
      'size_mm': sizeMm,
      'clarity': clarity,
      'price': price,
      'image_url': imageUrl,
      'rating': rating,
    };
  }
}
