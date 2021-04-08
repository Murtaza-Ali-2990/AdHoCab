import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetails {
  GeoPoint driverLocation;
  String customerName, customerPhone;
  GeoPoint sourceLocation, destinationLocation;
  String source, destination;
  double cost;
  int distance, time;
  bool pickup, drop;

  BookingDetails({
    this.cost,
    this.customerName,
    this.customerPhone,
    this.destinationLocation,
    this.distance,
    this.driverLocation,
    this.sourceLocation,
    this.time,
    this.destination,
    this.source,
    this.drop,
    this.pickup,
  });
}
