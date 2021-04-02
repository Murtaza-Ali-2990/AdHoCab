import 'package:adhocab/models/vehicle.dart';

class Driver {
  String name, email, phone, address, gender;
  DateTime dob;
  Vehicle vehicle;
  String licenseNo, drivingLicense, aadhaarCard;
  Driver({
    this.name,
    this.phone,
    this.email,
    this.gender,
    this.address,
    this.dob,
    this.vehicle,
    this.licenseNo,
    this.drivingLicense,
    this.aadhaarCard,
  });
}
