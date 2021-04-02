import 'package:adhocab/models/driver.dart';
import 'package:adhocab/screens/upload_document.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DriverDetails extends StatefulWidget {
  final driver, uid;
  DriverDetails({this.driver, this.uid});

  _Details createState() => _Details(driver: driver, uid: uid);
}

class _Details extends State<DriverDetails> {
  final uid;
  Driver driver;
  _Details({this.driver, this.uid});

  bool loading = false, aadhaar = false, license = false;
  final _key = GlobalKey<FormState>();

  TextEditingController dobController;

  Widget build(BuildContext context) {
    dobController = TextEditingController(text: driver.dob?.toString());
    print('Email is ${driver?.email}');

    if (loading) return Loading();

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
                          initialValue: driver?.name,
                          decoration: textInputDecor.copyWith(hintText: 'Name'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Name' : null,
                          onChanged: (value) =>
                              setState(() => driver.name = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: driver?.email,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Email'),
                          onChanged: (value) =>
                              setState(() => driver.email = value),
                          readOnly: true,
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: driver?.phone,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Phone Number'),
                          validator: (value) {
                            if (value.isEmpty) return 'Enter Phone Number';
                            if (isNumeric(value)) {
                              if (value.length == 10 || value.length == 11)
                                return null;
                              return 'Length should be between 10-11';
                            }
                            return 'Enter a number';
                          },
                          onChanged: (value) =>
                              setState(() => driver.phone = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: driver?.address,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Address'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Address' : null,
                          onChanged: (value) =>
                              setState(() => driver.address = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: driver?.gender,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Gender'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Gender' : null,
                          onChanged: (value) =>
                              setState(() => driver.gender = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: dobController,
                          decoration: textInputDecor.copyWith(hintText: 'DOB'),
                          onTap: _pickDOB,
                          validator: (value) =>
                              value.isEmpty ? 'Enter DOB' : null,
                          readOnly: true,
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: driver?.licenseNo,
                          decoration: textInputDecor.copyWith(
                              hintText: 'License Number'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter License Number' : null,
                          onChanged: (value) =>
                              setState(() => driver.licenseNo = value),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton.icon(
                          icon: Icon(driver.drivingLicense == null
                              ? Icons.upload_file
                              : Icons.done),
                          label: ButtonLayout('Upload License'),
                          style: buttonStyle,
                          onPressed: () => _upload('License'),
                        ),
                        if (license)
                          Text('Upload License', style: errorTextStyle),
                        SizedBox(height: 8.0),
                        ElevatedButton.icon(
                          icon: Icon(driver.aadhaarCard == null
                              ? Icons.upload_file
                              : Icons.done),
                          label: ButtonLayout('Upload Aadhaar Card'),
                          style: buttonStyle,
                          onPressed: () => _upload('Aadhaar Card'),
                        ),
                        if (aadhaar)
                          Text('Upload Aadhaar Card', style: errorTextStyle),
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

  void _upload(String type) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => UploadDocument(
              url: type == 'License'
                  ? driver.drivingLicense
                  : driver.aadhaarCard,
              type: type,
              uid: uid,
              callback: (val) {
                setState(() {
                  if (type == 'License')
                    driver.drivingLicense = val;
                  else
                    driver.aadhaarCard = val;
                });
              },
            )));
  }

  Future<void> _saveDetails() async {
    if (_key.currentState.validate() && _checkUpload()) {
      setState(() => loading = true);
      dynamic result = await DatabaseService(uid: uid).setDriverDetails(driver);
      if (result != null && mounted)
        setState(() => loading = false);
      else if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _pickDOB() async {
    final selectedDate = driver.dob != null ? driver.dob : DateTime.now();

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null)
      setState(() {
        driver.dob = picked;
        dobController.text = picked.toString();
      });
  }

  bool _checkUpload() {
    if (driver.aadhaarCard == null)
      setState(() => aadhaar = true);
    else
      setState(() => aadhaar = false);
    if (driver.drivingLicense == null)
      setState(() => license = true);
    else
      setState(() => license = false);
    return !(aadhaar || license);
  }
}
