class Question {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String userName;
  final int upvotes;
  final int downvotes;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.userName,
    this.upvotes = 0,
    this.downvotes = 0,
  });
}