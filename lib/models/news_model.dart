class News {
  final String? id;
  final String title;
  final String summary;
  final String content;
  final String? featuredImageUrl;
  final String category;
  final List<String> tags;
  final bool isPublished;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final int? viewCount;

  News({
    this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.featuredImageUrl,
    required this.category,
    required this.tags,
    required this.isPublished,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.viewCount,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    try {
      return News(
        id: json['id']?.toString(),
        title: json['title']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        featuredImageUrl: json['featured_image_url']?.toString(),
        category: json['category']?.toString() ?? '',
        tags: json['tags'] != null 
            ? List<String>.from(json['tags'].map((tag) => tag.toString()))
            : [],
        isPublished: json['is_published'] == true,
        slug: json['slug']?.toString(),
        createdAt: json['created_at'] != null 
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null 
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'].toString())
            : null,
        viewCount: json['view_count'] != null
            ? int.tryParse(json['view_count'].toString())
            : 0,
      );
    } catch (e) {
      return News(
        id: json['id']?.toString(),
        title: json['title']?.toString() ?? 'Untitled',
        summary: json['summary']?.toString() ?? 'No summary',
        content: json['content']?.toString() ?? 'No content',
        category: json['category']?.toString() ?? 'General',
        tags: [],
        isPublished: false,
        viewCount: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'featuredImageUrl': featuredImageUrl,
      'category': category,
      'tags': tags,
      'isPublished': isPublished,
    };
  }

  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'featured_image_url': featuredImageUrl,
      'category': category,
      'tags': tags,
      'is_published': isPublished,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'view_count': viewCount,
    };
  }

  News copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? featuredImageUrl,
    String? category,
    List<String>? tags,
    bool? isPublished,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? viewCount,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}