import '../utils/media_url.dart';

class ProductCategory {
  ProductCategory({required this.id, required this.name, this.imageUrl});

  final int id;
  final String name;
  final String? imageUrl;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    final label = attributes?['name']?.toString() ?? json['name']?.toString();
    final rawImage = attributes?['image_url'] ??
        attributes?['imageUrl'] ??
        attributes?['image_path'] ??
        attributes?['image'] ??
        json['image_url'] ??
        json['imageUrl'] ??
        json['image_path'] ??
        json['image'];
    String? imageCandidate;
    if (rawImage is Map) {
      imageCandidate =
          rawImage['url']?.toString() ?? rawImage['image_url']?.toString();
    } else {
      imageCandidate = rawImage?.toString();
    }
    final imageUrl = normalizeMediaUrl(imageCandidate);
    return ProductCategory(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: label ?? 'Catégorie',
      imageUrl: imageUrl,
    );
  }
}
