class CommunityPost {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final String createdAt;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? 'Ẩn danh',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
