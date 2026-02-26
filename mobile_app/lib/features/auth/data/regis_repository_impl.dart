import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobile_app/features/auth/domain/repositories/regis_repository.dart';

class RegisRepositoryImpl implements RegisRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  RegisRepositoryImpl(this.firebaseAuth, this.firestore);
  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String usuario,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final String uid = userCredential.user!.uid;
      // 2. Guardar todos los datos en la "tabla" (colección) de Firestore
      // Usamos el UID de Auth como ID del documento para que estén vinculados
      await firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nombre': nombre,
        'apellido': apellido,
        'ausuario': usuario,
        'email': email,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'ultimo_acceso': FieldValue.serverTimestamp(),
        'isAdmin': false,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapRegisError(e.code));
    } catch (e) {
      throw Exception("error al guardar el usuario");
    }
  }

  String _mapRegisError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Este correo ya está registrado.";
      case 'weak-password':
        return "La contraseña es muy corta.";
      default:
        return "Error en el registro. Inténtalo de nuevo.";
    }
  }
}

/* 
  }

  String _mapRegisError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Este correo ya está registrado.";
      case 'weak-password':
        return "La contraseña es muy corta.";
      default:
        return "Error en el registro. Inténtalo de nuevo.";
    }
  }
} */
