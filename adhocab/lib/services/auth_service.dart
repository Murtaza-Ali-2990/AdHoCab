import 'package:adhocab/models/customer.dart';
import 'package:adhocab/models/driver.dart';
import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/models/vehicle.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return e.code;
    }
  }

  Future signUp(String email, String password, String type) async {
    try {
      final user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      final databaseService = DatabaseService(uid: _auth.currentUser.uid);

      if (type == 'Customer')
        await databaseService.setCustomerDetails(Customer(email: email));
      else {
        await databaseService.setVehicleDetails(Vehicle());
        await databaseService.setDriverDetails(Driver(email: email));
      }

      await user.updateProfile(displayName: type);
    } catch (e) {
      return e.code;
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Problem logging out $e');
    }
  }

  Stream<UserData> get user {
    return _auth.userChanges().map(_toUser);
  }

  UserData _toUser(User user) {
    return UserData(user?.uid, type: user?.displayName);
  }
}
