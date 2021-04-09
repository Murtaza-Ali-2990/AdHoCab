import 'package:adhocab/models/booking_details.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Payment extends StatefulWidget {
  final customer,
      sourceCor,
      destinationCor,
      source,
      destination,
      time,
      distance,
      cost;
  Payment({
    this.cost,
    this.customer,
    this.destination,
    this.destinationCor,
    this.distance,
    this.source,
    this.sourceCor,
    this.time,
  });

  _Payment createState() => _Payment(
        cost: cost,
        customer: customer,
        destination: destination,
        destinationCor: destinationCor,
        source: source,
        sourceCor: sourceCor,
        distance: distance,
        time: time,
      );
}

class _Payment extends State<Payment> {
  final customer,
      sourceCor,
      destinationCor,
      source,
      destination,
      time,
      distance,
      cost;
  _Payment({
    this.cost,
    this.customer,
    this.destination,
    this.destinationCor,
    this.distance,
    this.source,
    this.sourceCor,
    this.time,
  });

  final Map<String, dynamic> result = {};

  bool _loading = false;
  String driverID;

  Widget build(BuildContext context) {
    if (_loading) Loading();

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: semiHeadingStyle),
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Text('Customer Name: ${customer.name}', style: miniHeadingStyle),
            SizedBox(height: 20),
            Text('Customer Phone No: ${customer.phone}',
                style: miniHeadingStyle),
            SizedBox(height: 20),
            Text('From: $source', style: miniHeadingStyle),
            SizedBox(height: 20),
            Text('To: $destination', style: miniHeadingStyle),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 1),
                Text(
                    'Distance: ${distance >= 1000 ? (distance / 1000).toStringAsFixed(1) : distance} ${distance >= 1000 ? 'km' : 'm'}',
                    style: miniHeadingStyle),
                Text(
                    'Time: ${time / 60 > 0 ? (time / 60).toStringAsFixed(0) + ' min' : ''} ${time % 60 > 0 ? (time % 60).toString() + ' s' : ''}',
                    style: miniHeadingStyle),
                SizedBox(width: 1),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 1),
                Text('Cost: Rs. ${cost.toStringAsFixed(2)}',
                    style: miniHeadingStyle),
                SizedBox(width: 1),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _paymentDone(),
              child: ButtonLayout('Pay'),
              style: buttonStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _paymentDone() async {
    setState(() => _loading = true);

    DatabaseService databaseService = DatabaseService();
    var cabList = await databaseService.getCabs();
    for (var cab in cabList) {
      if (cab['bookingDetails'].customerName == null ||
          cab['bookingDetails'].customerName.isEmpty) {
        driverID = cab['id'];
        break;
      }
    }

    if (driverID == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sorry, no cabs available')));
      setState(() => _loading = false);
      return;
    }

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AcknowledgePayment(),
    ));

    databaseService = DatabaseService(uid: driverID);
    var setResult = await databaseService.setBookingDetails(BookingDetails(
      customerName: customer.name,
      customerPhone: customer.phone,
      cost: cost,
      distance: distance,
      time: time,
      source: source,
      destination: destination,
      sourceLocation: sourceCor,
      destinationLocation: destinationCor,
      pickup: false,
      drop: false,
    ));
    if (setResult != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(setResult)));
      setState(() => _loading = false);
    }

    result['driver'] = await databaseService.getDriverDetails();
    result['driverID'] = driverID;

    Navigator.of(context).pop(result);
  }
}

class AcknowledgePayment extends StatefulWidget {
  _AcknowledgePayment createState() => _AcknowledgePayment();
}

class _AcknowledgePayment extends State<AcknowledgePayment> {
  bool paymentDone = false;

  initState() {
    super.initState();
    _managePayment();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        SpinKitHourGlass(color: mainColor, size: 100.0),
        if (paymentDone)
          Center(
            child: TextButton.icon(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              icon: Icon(
                Icons.done,
                color: Colors.greenAccent[700],
              ),
              label: Text('Payment Done'),
            ),
          ),
      ]),
    );
  }

  _managePayment() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() => paymentDone = true);
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }
}
