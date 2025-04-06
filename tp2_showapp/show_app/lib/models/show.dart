class Show {
  final String id;
  final String title;
  final String description;
  final String image;

  Show({required this.id, required this.title, required this.description, required this.image});

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
    };
  }
}