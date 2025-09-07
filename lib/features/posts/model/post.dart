// lib/features/posts/data/post.dart
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}


/**
 * Generate code
 * dart run build_runner build --delete-conflicting-outputs
 * Dart tips used here:
 *  - part 'post.g.dart' glues the generated file
 *  - factory constructor creates from JSON
 *  - methods keep conversion symmetric
 */