class GemstoneScanResult {
  final bool success;
  final String gemstoneName;
  final String? scientificName;
  final String confidence;
  final GemstoneProperties? properties;
  final String? description;
  final String? careInstructions;
  final List<ExpertKnowledge>? expertKnowledge;
  final List<String>? knowledgeSources;
  final bool ragEnhanced;
  final List<ScanProduct>? matchingProducts;
  final String? error;

  GemstoneScanResult({
    required this.success,
    required this.gemstoneName,
    this.scientificName,
    required this.confidence,
    this.properties,
    this.description,
    this.careInstructions,
    this.expertKnowledge,
    this.knowledgeSources,
    this.ragEnhanced = false,
    this.matchingProducts,
    this.error,
  });

  factory GemstoneScanResult.fromJson(Map<String, dynamic> json) {
    return GemstoneScanResult(
      success: json['success'] ?? false,
      gemstoneName: json['gemstone_name'] ?? 'Unknown',
      scientificName: json['scientific_name'],
      confidence: json['confidence'] ?? 'Low',
      properties: json['properties'] != null
          ? GemstoneProperties.fromJson(json['properties'])
          : null,
      description: json['description'],
      careInstructions: json['care_instructions'],
      expertKnowledge: json['expert_knowledge'] != null
          ? (json['expert_knowledge'] as List)
                .map((e) => ExpertKnowledge.fromJson(e))
                .toList()
          : null,
      knowledgeSources: json['knowledge_sources'] != null
          ? List<String>.from(json['knowledge_sources'])
          : null,
      ragEnhanced: json['rag_enhanced'] ?? false,
      matchingProducts: json['matching_products'] != null
          ? (json['matching_products'] as List)
                .map((e) => ScanProduct.fromJson(e))
                .toList()
          : null,
      error: json['error'],
    );
  }
}

class GemstoneProperties {
  final String? color;
  final String? cut;
  final String? clarity;
  final String? caratEstimate;

  GemstoneProperties({this.color, this.cut, this.clarity, this.caratEstimate});

  factory GemstoneProperties.fromJson(Map<String, dynamic> json) {
    return GemstoneProperties(
      color: json['color'],
      cut: json['cut'],
      clarity: json['clarity'],
      caratEstimate: json['carat_estimate'],
    );
  }
}

class ExpertKnowledge {
  final String content;
  final String title;
  final double relevanceScore;

  ExpertKnowledge({
    required this.content,
    required this.title,
    required this.relevanceScore,
  });

  factory ExpertKnowledge.fromJson(Map<String, dynamic> json) {
    return ExpertKnowledge(
      content: json['content'] ?? '',
      title: json['title'] ?? '',
      relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
    );
  }
}

class ScanProduct {
  final int id;
  final String name;
  final String? description;
  final String? stoneType;
  final double? caratWeight;
  final String? color;
  final String? clarity;
  final String? cutType;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final double avgRating;

  ScanProduct({
    required this.id,
    required this.name,
    this.description,
    this.stoneType,
    this.caratWeight,
    this.color,
    this.clarity,
    this.cutType,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.avgRating = 0.0,
  });

  factory ScanProduct.fromJson(Map<String, dynamic> json) {
    return ScanProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      stoneType: json['stone_type'],
      caratWeight: json['carat_weight'] != null
          ? (json['carat_weight'] as num).toDouble()
          : null,
      color: json['color'],
      clarity: json['clarity'],
      cutType: json['cut_type'],
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'],
      imageUrl: json['image_url'],
      avgRating: json['avg_rating'] != null
          ? (json['avg_rating'] as num).toDouble()
          : 0.0,
    );
  }
}
