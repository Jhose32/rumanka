import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/usuario_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';

  // Cuenta de Google pendiente entre paso 1 y paso 2 del registro
  GoogleSignInAccount? _pendingGoogleAccount;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;

  // ── Helpers privados ─────────────────────────────────

  Future<void> _guardarUsuarioEnFirestore(UsuarioModel usuario) async {
    await _firestore.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }

  Future<bool> _usuarioExiste(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    return doc.exists;
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  // ── Registro con correo y contraseña ─────────────────

  Future<bool> register(
      String name, String email, String password, bool isGuide) async {
    _setStatus(AuthStatus.loading);
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await result.user?.updateDisplayName(name.trim());

      final usuario = UsuarioModel(
        uid: result.user!.uid,
        nombre: name.trim(),
        correo: email.trim(),
        rol: isGuide ? 'guia' : 'turista',
        fechaRegistro: DateTime.now(),
      );
      await _guardarUsuarioEnFirestore(usuario);

      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getRegisterErrorMessage(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Login con correo y contraseña ─────────────────────

  Future<bool> loginWithEmail(String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getLoginErrorMessage(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Login con Google (solo usuarios ya registrados) ───

  Future<bool> loginWithGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setStatus(AuthStatus.idle);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);

      // Validar que el usuario ya existe en Firestore
      final existe = await _usuarioExiste(result.user!.uid);
      if (!existe) {
        await _googleSignIn.signOut();
        await _auth.signOut();
        _errorMessage = 'No tienes cuenta registrada. Ve a Registrarte.';
        _setStatus(AuthStatus.error);
        return false;
      }

      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      debugPrint('ERROR GOOGLE SIGN IN: $e');
      _errorMessage = 'Error al iniciar sesión con Google';
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Registro con Google — Paso 1: obtener datos ───────
  // No hace sign-in en Firebase. Solo obtiene nombre y correo de Google.

  Future<Map<String, String>?> obtenerDatosGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setStatus(AuthStatus.idle);
        return null;
      }
      _pendingGoogleAccount = googleUser;
      _setStatus(AuthStatus.idle);
      return {
        'nombre': googleUser.displayName ?? 'Usuario',
        'correo': googleUser.email,
      };
    } catch (e) {
      debugPrint('ERROR GOOGLE OBTENER DATOS: $e');
      _errorMessage = 'Error al conectar con Google';
      _setStatus(AuthStatus.error);
      return null;
    }
  }

  // ── Registro con Google — Paso 2: completar registro ──
  // Hace Firebase sign-in + verifica que no exista + guarda en Firestore.

  Future<bool> completarRegistroGoogle(bool isGuide) async {
    _setStatus(AuthStatus.loading);
    try {
      final googleUser = _pendingGoogleAccount;
      if (googleUser == null) {
        _errorMessage = 'Sesión de Google expirada. Intenta de nuevo.';
        _setStatus(AuthStatus.error);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);

      // Verificar si ya está registrado
      final existe = await _usuarioExiste(result.user!.uid);
      if (existe) {
        await _googleSignIn.signOut();
        await _auth.signOut();
        _pendingGoogleAccount = null;
        _errorMessage = 'Este correo ya tiene una cuenta. Inicia sesión.';
        _setStatus(AuthStatus.error);
        return false;
      }

      // Guardar en Firestore con el rol elegido
      final usuario = UsuarioModel(
        uid: result.user!.uid,
        nombre: result.user!.displayName ?? googleUser.displayName ?? 'Usuario',
        correo: result.user!.email ?? googleUser.email,
        rol: isGuide ? 'guia' : 'turista',
        fechaRegistro: DateTime.now(),
      );
      await _guardarUsuarioEnFirestore(usuario);

      _pendingGoogleAccount = null;
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      debugPrint('ERROR completarRegistroGoogle: $e');
      _errorMessage = 'Error al completar el registro';
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Cerrar sesión ─────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _pendingGoogleAccount = null;
    _setStatus(AuthStatus.idle);
  }

  // ── Mensajes de error ─────────────────────────────────

  String _getRegisterErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      default:
        return 'Error al crear la cuenta. Intenta de nuevo';
    }
  }

  String _getLoginErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error al iniciar sesión. Intenta de nuevo';
    }
  }
}
