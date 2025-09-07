# Flutter MVVM with Riverpod, Dio, and JSON — Beginner Wiki

---

## 1. What is MVVM?

* **Model–View–ViewModel** (MVVM) is a way to organize code.
* **Model** → data classes (like `Post`).
* **View** → widgets the user sees (`PostsPage`).
* **ViewModel** → the “middleman” that talks to APIs and prepares data for the View.

---

## 2. What is Riverpod?

* Riverpod is a **state management tool** for Flutter.
* It lets you create **providers**.
* A provider is like a “box” that stores your state or logic.
* Your UI can `watch` a provider and rebuild automatically when the state changes.

---

## 3. What is Dio?

* Dio is a popular **HTTP client** in Dart.
* It helps you make API calls (`GET`, `POST`, etc.) and handles headers, timeouts, and errors.

Example:

```dart
final dio = Dio();
final response = await dio.get('https://jsonplaceholder.typicode.com/posts');
print(response.data);
```

---

## 4. What is JSON serialization?

* APIs send data as **JSON** (text like `{ "id": 1, "title": "hello" }`).
* In Dart, you want **typed classes** instead of raw maps.
* `json_serializable` generates code to turn JSON into Dart objects and back.

Example:

```dart
@JsonSerializable()
class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
```

---

## 5. Folder structure (clean MVVM)

```
lib/
  core/
    networking/
      dio_provider.dart
  features/
    posts/
      model/
        post.dart
        posts_repository.dart
      viewmodel/
        posts_viewmodel.dart
      view/
        posts_page.dart
  app.dart
  main.dart
```

* Keep everything for one feature together.
* Core stuff (like Dio setup) goes into `core/`.

---

## 6. Setting up Dio with Riverpod

```dart
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'Flutter-Dio',
    },
  ));
});
```

* This creates one Dio instance for the whole app.
* Other parts of the app can use it via `ref.read(dioProvider)`.

---

## 7. Repository (Model side)

```dart
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
  return PostsRepository(ref.read(dioProvider));
});
```

* Talks to Dio.
* Converts JSON → `Post` objects.
* Exposed as a provider.

---

## 8. ViewModel with Riverpod

```dart
class PostsViewModel extends AsyncNotifier<List<Post>> {
  late final PostsRepository _repo = ref.read(postsRepositoryProvider);

  @override
  Future<List<Post>> build() async {
    return _repo.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchPosts());
  }
}

final postsViewModelProvider =
    AsyncNotifierProvider<PostsViewModel, List<Post>>(
  () => PostsViewModel(),
);
```

* ViewModel = `PostsViewModel`.
* Provider = `postsViewModelProvider`.
* The View can now watch it.

---

## 9. View (Flutter widget)

```dart
class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final post = items[i];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.body),
            );
          },
        ),
      ),
    );
  }
}
```

* `ref.watch(provider)` subscribes to ViewModel state.
* `when()` handles loading, error, data cases.

---

## 10. Flow summary

1. View (`PostsPage`) asks Riverpod for `postsViewModelProvider`.
2. Provider creates `PostsViewModel`.
3. `PostsViewModel.build()` calls `PostsRepository.fetchPosts()`.
4. Repository uses Dio to fetch JSON.
5. JSON is converted into a list of `Post`.
6. Riverpod updates state.
7. UI rebuilds with the new posts.

---

## 11. Key Dart syntax reminders (for Java devs)

* `final` = set once, like `final` in Java.
* `const` = compile-time constant.
* `?` = nullable type (`String?`).
* `!` = trust me, not null.
* `async/await` similar to Java’s `CompletableFuture`.
* `_name` = private to the file.
* Arrow function: `() => expr` is shorthand.
