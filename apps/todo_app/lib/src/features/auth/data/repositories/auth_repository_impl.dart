import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserCredential> signInWithEmail(String email, String password) {
    return remoteDataSource.signInWithEmail(email, password);
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) {
    return remoteDataSource.signUpWithEmail(email, password);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<UserCredential?> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Stream<User?> authStateChanges() {
    return remoteDataSource.authStateChanges();
  }
}
