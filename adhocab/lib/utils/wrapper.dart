import 'package:adhocab/detail_updates/customer_details.dart';
import 'package:adhocab/detail_updates/driver_details.dart';
import 'package:adhocab/detail_updates/vehicle_details.dart';
import 'package:adhocab/models/customer.dart';
import 'package:adhocab/models/driver.dart';
import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/models/vehicle.dart';
import 'package:adhocab/home/home_customer.dart';
import 'package:adhocab/home/home_driver.dart';
import 'package:adhocab/screens/onboarding.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_screen.dart';

class Wrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final user = Provider.of<UserData>(context);
    final uid = user?.uid;
    final type = user?.type;

    final databaseService = DatabaseService(uid: uid);

    print('User is $uid and type is $type');

    if (uid == null) {
      return Onboarding();
    } else if (type == 'Customer') {
      return StreamProvider<Customer>.value(
        value: databaseService.customer,
        initialData: Customer(),
        child: CustomerWrapper(),
      );
    } else if (type == 'Driver') {
      return MultiProvider(
        providers: [
          StreamProvider.value(
            value: databaseService.driver,
            initialData: Driver(),
          ),
          StreamProvider.value(
            value: databaseService.vehicle,
            initialData: Vehicle(),
          )
        ],
        child: DriverWrapper(),
      );
    } else
      return Loading();
  }
}

class CustomerWrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final customer = Provider.of<Customer>(context);
    final user = Provider.of<UserData>(context);

    if (customer?.email == null) return Loading();

    if (customer?.name == null || customer.name.isEmpty)
      return CustomerDetails(
        customer: customer,
        uid: user.uid,
      );

    return CustomerHome();
  }
}

class DriverWrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final driver = Provider.of<Driver>(context);
    final vehicle = Provider.of<Vehicle>(context);
    final user = Provider.of<UserData>(context);

    if (driver?.email == null) return Loading();

    if (driver?.name == null || driver.name.isEmpty)
      return DriverDetails(
        driver: driver,
        uid: user.uid,
      );

    if (vehicle?.registration == null || vehicle.registration.isEmpty)
      return VehicleDetails(
        vehicle: vehicle,
        uid: user.uid,
      );

    return DriverHome();
  }
}
