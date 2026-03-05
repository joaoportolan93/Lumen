import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dreamshare/models/dream.dart';
import 'package:dreamshare/models/comment.dart';
import 'api_client.dart';

class DreamService {
  final ApiClient _api = ApiClient();

  Future<List<Dream>> getFeed({int page = 1}) async {
    try {
      final response = await _api.dio.get('dreams/', queryParameters: {
        'page': page,
      });

      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);

      return results.map((json) => Dream.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<Dream?> getDreamDetail(String dreamId) async {
    try {
      final response = await _api.dio.get('dreams/$dreamId/');
      return Dream.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<Dream?> createDream({
    required String conteudoTexto,
    List<String>? hashtags,
    File? imagem,
  }) async {
    try {
      final formData = FormData.fromMap({
        'conteudo_texto': conteudoTexto,
        if (hashtags != null && hashtags.isNotEmpty)
          'hashtags': hashtags.join(','),
        if (imagem != null)
          'imagem': await MultipartFile.fromFile(
            imagem.path,
            filename: imagem.path.split('/').last,
          ),
      });

      final response = await _api.dio.post('dreams/', data: formData);
      return Dream.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<bool> likeDream(String dreamId) async {
    try {
      await _api.dio.post('dreams/$dreamId/react/');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> saveDream(String dreamId) async {
    try {
      await _api.dio.post('dreams/$dreamId/save/');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<Comment>> getComments(String dreamId) async {
    try {
      final response = await _api.dio.get('dreams/$dreamId/comments/');
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => Comment.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<Comment?> createComment(String dreamId, String texto) async {
    try {
      final response = await _api.dio.post(
        'dreams/$dreamId/comments/',
        data: {'conteudo_texto': texto},
      );
      return Comment.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<List<Dream>> getUserDreams(String userId) async {
    try {
      final response = await _api.dio.get('dreams/', queryParameters: {
        'usuario': userId,
      });
      final results = response.data is Map
          ? (response.data['results'] as List? ?? [])
          : (response.data as List? ?? []);
      return results.map((json) => Dream.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }
}
