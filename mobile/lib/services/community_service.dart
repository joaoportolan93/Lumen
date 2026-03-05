import 'package:dio/dio.dart';
import 'package:dreamshare/models/community.dart';
import 'package:dreamshare/models/dream.dart';
import 'api_client.dart';

class CommunityService {
  final ApiClient _api = ApiClient();

  Future<List<Community>> getCommunities() async {
    try {
      final response = await _api.dio.get('communities/');
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => Community.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<Community?> getCommunityDetail(String communityId) async {
    try {
      final response = await _api.dio.get('communities/$communityId/');
      return Community.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<List<Dream>> getCommunityPosts(String communityId) async {
    try {
      final response = await _api.dio.get('dreams/', queryParameters: {
        'comunidade': communityId,
      });
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => Dream.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<bool> joinCommunity(String communityId) async {
    try {
      await _api.dio.post('communities/$communityId/join/');
      return true;
    } on DioException {
      return false;
    }
  }
}
