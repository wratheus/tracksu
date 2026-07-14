class News{
  int? id;
  String? author;
  String? editURL;
  String? firstImage;
  String? publishedAt;
  String? updatedAt;
  String? slug;
  String? title;
  String? preview;

  News({
    required this.id,
    required this.author,
    required this.editURL,
    required this.firstImage,
    required this.publishedAt,
    required this.updatedAt,
    required this.slug,
    required this.title,
    required this.preview,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      author: json['author'],
      editURL: json['edit_url'],
      firstImage: json['first_image'],
      publishedAt: json['published_at'],
      updatedAt: json['updated_at'],
      slug: json['slug'],
      title: json['title'],
      preview: json['preview'],
    );
  }
}