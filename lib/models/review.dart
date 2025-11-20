class Review {
  final String id;
  final String author;
  final String content;
  final String? url;

  Review(
      {required this.id,
      required this.author,
      required this.content,
      this.url});

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      author: map['author'] ?? 'Anonymous',
      content: map['content'] ?? '',
      url: map['url'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'author': author,
        'content': content,
        'url': url,
      };
}
