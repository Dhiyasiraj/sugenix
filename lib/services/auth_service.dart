import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    required String gender,
    required String diabetesType,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'diabetesType': diabetesType,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'emergencyContacts': [],
        'medicalHistory': [],
        'preferences': {
          'notifications': true,
          'reminders': true,
          'language': 'en',
        },
      });

      return result;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      await _firestore.collection('users').doc(result.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return result;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? diabetesType,
  }) async {
    try {
      if (currentUser == null) throw Exception('No user logged in');

      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;
      if (gender != null) updateData['gender'] = gender;
      if (diabetesType != null) updateData['diabetesType'] = diabetesType;

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updateData);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Add emergency contact
  Future<void> addEmergencyContact({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    try {
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(currentUser!.uid).update({
        'emergencyContacts': FieldValue.arrayUnion([
          {
            'name': name,
            'phone': phone,
            'relationship': relationship,
            'addedAt': FieldValue.serverTimestamp(),
          },
        ]),
      });
    } catch (e) {
      throw Exception('Failed to add emergency contact: ${e.toString()}');
    }
  }

  // Delete emergency contact
  Future<void> deleteEmergencyContact(int index) async {
    try {
      if (currentUser == null) throw Exception('No user logged in');

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> contacts = data['emergencyContacts'] ?? [];

      if (index >= 0 && index < contacts.length) {
        contacts.removeAt(index);
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'emergencyContacts': contacts,
        });
      }
    } catch (e) {
      throw Exception('Failed to delete emergency contact: ${e.toString()}');
    }
  }

  // Set user role
  Future<void> setUserRole(String role) async {
    try {
      if (currentUser == null) throw Exception('No user logged in');
      
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to set user role: ${e.toString()}');
    }
  }
}
