import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nombre;
  final String correo;
  final String rol; // 'turista' o 'guia'
  final DateTime fechaRegistro;

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.fechaRegistro,
  });

  // Convierte el modelo a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  // Crea un modelo desde un documento de Firestore
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      rol: map['rol'] ?? 'turista',
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
    );
  }
}
