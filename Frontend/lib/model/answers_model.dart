class Answer {
  final String id;
  final String content;
  final String userName;
  int upvotes; // Made mutable for local voting
  int downvotes; // Made mutable for local voting
  bool isAccepted; // Made mutable for accepting answers
  final String userId; // User who posted the answer

  Answer({
    required this.id,
    required this.content,
    required this.userName,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isAccepted = false,
    required this.userId,
  });

  // Method to create a new instance with updated properties
  Answer copyWith({
    String? id,
    String? content,
    String? userName,
    int? upvotes,
    int? downvotes,
    bool? isAccepted,
    String? userId,
  }) {
    return Answer(
      id: id ?? this.id,
      content: content ?? this.content,
      userName: userName ?? this.userName,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      isAccepted: isAccepted ?? this.isAccepted,
      userId: userId ?? this.userId,
    );
  }
}