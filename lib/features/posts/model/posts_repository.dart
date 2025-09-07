import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import 'post.dart';

class PostsRepository {
  PostsRepository(this._dio);
  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final res = await _dio.get('/posts');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(Post.fromJson).toList();
  }
}

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PostsRepository(dio);
});


/**
 * Repository talks to HTTP and returns models
 * Repository hides HTTP details 
 * It returns typed models to your ViewModel
 */