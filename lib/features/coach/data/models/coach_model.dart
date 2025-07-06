class CoachModel {
  final int id;
  final String fullName;
  final String? imageUrl;
  final double rating;
  final String? email;
  final String? type;
  final String? gender;
  final String? bio;
  final List<Experience> experiences;
  final RecentPost? recentPost;

  CoachModel({
    required this.id,
    required this.fullName,
    this.imageUrl,
    required this.rating,
    this.email,
    this.type,
    this.gender,
    this.bio,
    required this.experiences,
    this.recentPost,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      email: json['email'] as String?,
      type: json['type'] as String?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      recentPost: json['recentPost'] != null
          ? RecentPost.fromJson(json['recentPost'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Experience {
  final int id;
  final String name;

  Experience({
    required this.id,
    required this.name,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class RecentPost {
  final int id;
  final String content;
  final DateTime createdAt;

  RecentPost({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory RecentPost.fromJson(Map<String, dynamic> json) {
    return RecentPost(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CoachPaginatedResponse {
  final int total;
  final int page;
  final int limit;
  final List<CoachModel> coaches;

  CoachPaginatedResponse({
    required this.total,
    required this.page,
    required this.limit,
    required this.coaches,
  });

  factory CoachPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CoachPaginatedResponse(
      total: data['total'] as int,
      page: int.parse(data['page'] as String),
      limit: int.parse(data['limit'] as String),
      coaches: (data['coaches'] as List<dynamic>)
          .map((coach) => CoachModel.fromJson(coach as Map<String, dynamic>))
          .toList(),
    );
  }
} 