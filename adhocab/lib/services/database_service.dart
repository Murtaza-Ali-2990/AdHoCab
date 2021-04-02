import 'package:adhocab/models/customer.dart';
import 'package:adhocab/models/driver.dart';
import 'package:adhocab/models/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final uid;
  DatabaseService({this.uid});

  final CollectionReference customerRef =
      FirebaseFirestore.instance.collection('Customer');
  final CollectionReference driverRef =
      FirebaseFirestore.instance.collection('Driver');

  Stream<Customer> get customer {
    return customerRef.doc(uid).snapshots().map(_getCustomer);
  }

  Customer _getCustomer(DocumentSnapshot snapshot) {
    return Customer(
      address: snapshot.data()['address'],
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      gender: snapshot.data()['gender'],
      phone: snapshot.data()['phone'],
      dob: snapshot.data()['dob'] != null
          ? DateTime.parse(snapshot.data()['dob'])
          : null,
    );
  }

  Future setCustomerDetails(Customer customer) async {
    try {
      await customerRef.doc(uid).set({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'gender': customer.gender,
        'dob': customer.dob?.toIso8601String(),
      });
    } catch (error) {
      print(error.toString());
      return error.toString();
    }
  }

  Stream<Driver> get driver {
    return driverRef.doc(uid).snapshots().map(_getDriver);
  }

  Driver _getDriver(DocumentSnapshot snapshot) {
    return Driver(
      address: snapshot.data()['address'],
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      gender: snapshot.data()['gender'],
      phone: snapshot.data()['phone'],
      dob: snapshot.data()['dob'] != null
          ? DateTime.parse(snapshot.data()['dob'])
          : null,
      licenseNo: snapshot.data()['licenseNo'],
      drivingLicense: snapshot.data()['drivingLicense'],
      aadhaarCard: snapshot.data()['aadhaarCard'],
    );
  }

  Future setDriverDetails(Driver driver) async {
    try {
      await driverRef.doc(uid).set({
        'name': driver.name,
        'phone': driver.phone,
        'email': driver.email,
        'address': driver.address,
        'gender': driver.gender,
        'dob': driver.dob?.toIso8601String(),
        'licenseNo': driver.licenseNo,
        'drivingLicense': driver.drivingLicense,
        'aadhaarCard': driver.aadhaarCard,
      });
    } catch (error) {
      print(error.toString());
      return error.toString();
    }
  }

  Stream<Vehicle> get vehicle {
    return driverRef
        .doc(uid)
        .collection('Vehicle')
        .doc('Vehicle')
        .snapshots()
        .map(_getVehicle);
  }

  Vehicle _getVehicle(DocumentSnapshot snapshot) {
    return Vehicle(
      registration: snapshot.data()['registration'],
      vehicleNo: snapshot.data()['vehicleNo'],
      type: snapshot.data()['type'],
      seats: snapshot.data()['seats'],
      insurance: snapshot.data()['insurance'],
    );
  }

  Future setVehicleDetails(Vehicle vehicle) async {
    try {
      return driverRef.doc(uid).collection('Vehicle').doc('Vehicle').set({
        'registration': vehicle.registration,
        'vehicleNo': vehicle.vehicleNo,
        'type': vehicle.type,
        'seats': vehicle.seats,
        'insurance': vehicle.insurance,
      });
    } catch (error) {
      print(error.toString());
      return error.toString();
    }
  }
}
