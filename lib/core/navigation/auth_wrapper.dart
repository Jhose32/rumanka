import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/home_guia/view/home_guia_screen.dart';
import '../../features/home_turista/view/home_turista_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Esperando estado de autenticación
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // Sin sesión → Login
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        // Con sesión → escuchar el documento en Firestore en tiempo real
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(authSnapshot.data!.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            // Esperando o documento aún no existe (registro en curso)
            if (userSnapshot.connectionState == ConnectionState.waiting ||
                !userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return const _LoadingScreen();
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>?;
            final rol = data?['rol'] ?? 'turista';

            if (rol == 'guia') {
              return const HomeGuiaScreen();
            } else {
              return const HomeTuristaScreen();
            }
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
