import 'package:dio/dio.dart';
import 'package:dreamshare/models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _api = ApiClient();

  Future<User?> getUserDetail(String userId) async {
    try {
      final response = await _api.dio.get('users/$userId/');
      return User.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      await _api.dio.post('users/$userId/follow/');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<User>> getFollowers(String userId) async {
    try {
      final response = await _api.dio.get('users/$userId/followers/');
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => User.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<List<User>> getFollowing(String userId) async {
    try {
      final response = await _api.dio.get('users/$userId/following/');
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => User.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<List<User>> search(String query) async {
    try {
      final response = await _api.dio.get('search/', queryParameters: {
        'q': query,
      });
      final users = response.data['users'] as List? ?? [];
      return users.map((json) => User.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<List<User>> getSuggestedUsers() async {
    try {
      final response = await _api.dio.get('users/suggested/');
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => User.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }
}
