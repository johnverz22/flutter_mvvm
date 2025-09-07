import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/post.dart';
import '../model/posts_repository.dart';

class PostsViewModel extends AsyncNotifier<List<Post>> {
  late final PostsRepository _repo = ref.read(postsRepositoryProvider);

  // build runs on first read. good place to load initial data.
  @override
  FutureOr<List<Post>> build() async {
    return _repo.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchPosts());
  }
}

final postsViewModelProvider =
    AsyncNotifierProvider<PostsViewModel, List<Post>>(() => PostsViewModel());

/**
 * ViewModel with Riverpod’s AsyncNotifier
 * Dart and Riverpod tips here:
 * AsyncNotifier<T> manages AsyncValue<T> for loading and error
 * build() is like init for the ViewModel
 * state holds AsyncValue<List<Post>>
 * AsyncValue.guard wraps errors for you
 * 
 * 
 * 
 * 1. Notifier = ViewModel
 * In MVVM, your ViewModel holds the app’s state.
 * In Riverpod, a Notifier (or AsyncNotifier) is that ViewModel.
 * It has a state property you control.
 * 2. Why AsyncNotifier?
 * Sometimes state isn’t just a number or string, but something from the network.
 * Network calls can be loading, success, or error.
 * Riverpod’s AsyncNotifier<T> is a helper that wraps your state into an AsyncValue<T>.
 * Example:
 * AsyncValue.loading() → still fetching
 * AsyncValue.data(value) → success with value
 * AsyncValue.error(err, stack) → error happened
 */
