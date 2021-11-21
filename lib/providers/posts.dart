import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/failure.dart';
import '../models/filters.dart';
import '../models/post.dart';

class Posts with ChangeNotifier {
  String token;
  List<Post> _posts;
  Post? _postData;
  Filters? _filters;

  Posts(this.token, this._posts, this._postData, this._filters);

  List<Post> get posts {
    return [..._posts];
  }

  Post? get postData {
    return _postData;
  }

  Filters? get filters {
    return _filters;
  }

  void initNewPost() {
    _postData = Post(
      id: 0,
      active: true,
      userType: UserType.owner,
      estateType: EstateType.house,
      dealType: DealType.sale,
      location: [],
      city: null,
      district: null,
      address: '',
      sqm: 0,
      renovation: Renovation.cosmetic,
      price: 0,
      rooms: 0,
      images: [],
      description: '',
      contact: '',
      username: '',
      updatedAt: DateTime.now(),
    );
  }

  void updatePost(Post? value, {bool notify = true}) {
    _postData = value;
    if (notify) {
      notifyListeners();
    }
  }

  void updateFilters(Filters value) {
    _filters = value;
    notifyListeners();
  }

  Future<void> fetchAndSetPosts({Map<String, dynamic>? queryParameters}) async {
    Map<String, dynamic> _parameters;

    if (queryParameters == null) {
      _parameters = _filters?.toQueryParameters() ?? {};
    } else {
      _parameters = queryParameters;
    }

    _parameters['limit'] = '15';

    final url = Uri(
        scheme: 'http',
        host: '192.168.1.9',
        port: 5000,
        path: 'api/posts',
        queryParameters: _parameters);

    try {
      final response = await http.get(url);

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
            data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
            '\n');
        throw Failure(buffer.toString(), response.statusCode);
      }

      final dynamic data = json.decode(response.body);
      final List<Post> loadedPosts = [];
      data['result'].forEach((element) {
        loadedPosts.add(Post.fromJson(element));
      });
      _posts = loadedPosts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> createPost(Post post) async {
    try {
      final url = Uri.parse('http://192.168.1.9:5000/api/posts');
      final response = await http.post(url,
          body: json.encode(post.toJson()),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'JWT $token'
          });

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
            data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
            '\n');
        throw Failure(buffer.toString(), response.statusCode);
      }
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getImageUploadId() async {
    final url = Uri(
      scheme: 'http',
      host: '192.168.1.9',
      port: 5000,
      path: 'api/posts/generate_upload_id',
    );

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'JWT $token'});

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
            data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
            '\n');
        throw Failure(buffer.toString(), response.statusCode);
      }

      final dynamic data = json.decode(response.body);
      return data['id'] as String;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> uploadImage(XFile file, String id) async {
    final url = Uri(
      scheme: 'http',
      host: '192.168.1.9',
      port: 5000,
      path: 'api/posts/upload_image',
    );

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'JWT $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['id'] = id;
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        await file.readAsBytes(),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
            data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
            '\n');
        throw Failure(buffer.toString(), response.statusCode);
      }

      return true;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteImage(String id) async {
    final url = Uri(
      scheme: 'http',
      host: '192.168.1.9',
      port: 5000,
      path: 'api/posts/delete_image/$id',
    );

    try {
      final response =
          await http.delete(url, headers: {'Authorization': 'JWT $token'});

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
            data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
            '\n');
        throw Failure(buffer.toString(), response.statusCode);
      }
    } catch (error) {
      rethrow;
    }
  }

  Post findById(int id) {
    return _posts.firstWhere((element) => element.id == id);
  }

  void clearPosts() {
    _posts = [];
  }
}
