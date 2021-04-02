import 'package:adhocab/models/vehicle.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleDetails extends StatefulWidget {
  final vehicle, uid;
  VehicleDetails({this.vehicle, this.uid});

  _Details createState() => _Details(vehicle: vehicle, uid: uid);
}

class _Details extends State<VehicleDetails> {
  final uid;
  Vehicle vehicle;
  _Details({this.vehicle, this.uid});

  bool loading = false;
  final _key = GlobalKey<FormState>();

  TextEditingController dobController;

  Widget build(BuildContext context) {
    if (loading) return loadingStyle;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        margin: EdgeInsets.only(top: 20.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeadingStyle('Enter your Details'),
              SizedBox(height: 50.0),
              SizedBox(
                width: 400.0,
                child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: vehicle?.registration,
                          decoration: textInputDecor.copyWith(
                              hintText: 'Registration ID'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Registration ID' : null,
                          onChanged: (value) =>
                              setState(() => vehicle.registration = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: vehicle?.vehicleNo,
                          decoration: textInputDecor.copyWith(
                              hintText: 'Vehicle Number'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Vehicle Number' : null,
                          onChanged: (value) =>
                              setState(() => vehicle.vehicleNo = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: vehicle?.seats,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Seats'),
                          validator: (value) {
                            if (value.isEmpty) return 'Enter Number of Seats';
                            if (isNumeric(value)) {
                              if (int.parse(value) > 0 && int.parse(value) < 5)
                                return null;
                              return 'Seats should be between 1-4';
                            }
                            return 'Enter a number';
                          },
                          onChanged: (value) =>
                              setState(() => vehicle.seats = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: vehicle?.type,
                          decoration: textInputDecor.copyWith(hintText: 'Type'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Vehicle Type' : null,
                          onChanged: (value) =>
                              setState(() => vehicle.type = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: vehicle?.insurance,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Insurance ID'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Insurance ID' : null,
                          onChanged: (value) =>
                              setState(() => vehicle.insurance = value),
                        ),
                        SizedBox(height: 30.0),
                        ElevatedButton.icon(
                          icon: Icon(Icons.update),
                          label: ButtonLayout('Update Details'),
                          style: buttonStyle,
                          onPressed: _saveDetails,
                        ),
                        SizedBox(height: 20.0),
                      ],
                    )),
              ),
              SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDetails() async {
    if (_key.currentState.validate()) {
      setState(() => loading = true);
      dynamic result =
          await DatabaseService(uid: uid).setVehicleDetails(vehicle);
      if (result != null && mounted)
        setState(() => loading = false);
      else if (mounted) Navigator.of(context).pop();
    }
  }
}
