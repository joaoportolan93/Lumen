import 'user.dart';

class Comment {
  final String id;
  final User? usuario;
  final String conteudoTexto;
  final String? parentId;
  final int curtidasCount;
  final DateTime dataCriacao;

  Comment({
    required this.id,
    this.usuario,
    required this.conteudoTexto,
    this.parentId,
    this.curtidasCount = 0,
    required this.dataCriacao,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id_comentario'] ?? json['id'] ?? '',
      usuario: json['usuario'] != null
          ? (json['usuario'] is Map<String, dynamic>
              ? User.fromJson(json['usuario'])
              : null)
          : null,
      conteudoTexto: json['conteudo_texto'] ?? '',
      parentId: json['parent']?.toString(),
      curtidasCount: json['curtidas_count'] ?? json['reacoes_count'] ?? 0,
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : DateTime.now(),
    );
  }
}
