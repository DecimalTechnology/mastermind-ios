class SearchResult {
  final String? id;
  final String? name;
  final String? image;
  final String? profileId;
  final String? company;
  final String? chapter;
  final String? region;

  SearchResult({
    this.id,
    this.name,
    this.image,
    this.profileId,
    this.company,
    this.chapter,
    this.region,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      profileId: json['profileId'] as String?,
      company: json['company'] as String?,
      chapter: json['chapter'] as String?,
      region: json['region'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'profileId': profileId,
      'company': company,
      'chapter': chapter,
      'region': region,
    };
  }

  @override
  String toString() {
    return 'Data(id: $id, name: $name, image: $image, profileId: $profileId, company: $company, chapter: $chapter, region: $region)';
  }
}
