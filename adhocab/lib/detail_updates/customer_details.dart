import 'package:adhocab/models/customer.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerDetails extends StatefulWidget {
  final customer, uid;
  CustomerDetails({this.customer, this.uid});

  _Details createState() => _Details(customer: customer, uid: uid);
}

class _Details extends State<CustomerDetails> {
  final uid;
  Customer customer;
  _Details({this.customer, this.uid});

  bool loading = false;
  final _key = GlobalKey<FormState>();

  TextEditingController dobController;

  Widget build(BuildContext context) {
    dobController = TextEditingController(text: customer.dob?.toString());
    print('Email is ${customer?.email}');

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
                          initialValue: customer?.name,
                          decoration: textInputDecor.copyWith(hintText: 'Name'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Name' : null,
                          onChanged: (value) =>
                              setState(() => customer.name = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: customer?.email,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Email'),
                          onChanged: (value) =>
                              setState(() => customer.email = value),
                          readOnly: true,
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: customer?.phone,
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
                              setState(() => customer.phone = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: customer?.address,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Address'),
                          onChanged: (value) =>
                              setState(() => customer.address = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: customer?.gender,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Gender'),
                          onChanged: (value) =>
                              setState(() => customer.gender = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: dobController,
                          decoration: textInputDecor.copyWith(hintText: 'DOB'),
                          onTap: _pickDOB,
                          readOnly: true,
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
          await DatabaseService(uid: uid).setCustomerDetails(customer);
      if (result != null && mounted)
        setState(() => loading = false);
      else if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _pickDOB() async {
    final selectedDate = customer.dob != null ? customer.dob : DateTime.now();

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null)
      setState(() {
        customer.dob = picked;
        dobController.text = picked.toString();
      });
  }
}

/*class CustomerDetails extends StatefulWidget {
  _Details createState() => _Details();
}

class _Details extends State<CustomerDetails> {
  UserData user;
  Customer customer;

  bool loading = false;
  final _key = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController addressController = TextEditingController(text: '');
  TextEditingController genderController = TextEditingController(text: '');
  TextEditingController dobController = TextEditingController(text: '');

  Widget build(BuildContext context) {
    _initialise();

    print('Email is ${customer?.email}');

    if (loading) return loadingStyle;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        margin: EdgeInsets.only(top: 20.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeadingStyle('Register your Hospital with Us'),
              SizedBox(height: 50.0),
              SizedBox(
                width: 400.0,
                child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: textInputDecor.copyWith(hintText: 'Name'),
                          validator: (value) =>
                              value.isEmpty ? 'Enter Name' : null,
                          onChanged: (value) =>
                              setState(() => customer.name = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: emailController,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Email'),
                          onChanged: (value) =>
                              setState(() => customer.email = value),
                          readOnly: true,
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: phoneController,
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
                              setState(() => customer.phone = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: addressController,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Address'),
                          onChanged: (value) =>
                              setState(() => customer.address = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: genderController,
                          decoration:
                              textInputDecor.copyWith(hintText: 'Gender'),
                          onChanged: (value) =>
                              setState(() => customer.gender = value),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: dobController,
                          decoration: textInputDecor.copyWith(hintText: 'DOB'),
                          onTap: _pickDOB,
                          readOnly: true,
                        ),
                        SizedBox(height: 30.0),
                        ElevatedButton.icon(
                          icon: Icon(Icons.login),
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

  void _initialise() {
    user = Provider.of<UserData>(context);
    if (customer?.email == null)
      customer = Provider.of<Customer>(context) ?? Customer();
    nameController
      ..text = customer.name ?? ''
      ..selection = TextSelection(
          baseOffset: nameController.text.length,
          extentOffset: nameController.text.length);
    emailController..text = customer.email ?? '';
    phoneController
      ..text = customer.phone ?? ''
      ..selection = TextSelection(
          baseOffset: phoneController.text.length,
          extentOffset: phoneController.text.length);
    addressController
      ..text = customer.address ?? ''
      ..selection = TextSelection(
          baseOffset: addressController.text.length,
          extentOffset: addressController.text.length);
    genderController
      ..text = customer.gender ?? ''
      ..selection = TextSelection(
          baseOffset: genderController.text.length,
          extentOffset: genderController.text.length);
    dobController..text = customer.dob?.toString() ?? '';
  }

  Future<void> _saveDetails() async {
    if (_key.currentState.validate()) {
      setState(() => loading = true);
      dynamic result =
          await DatabaseService(uid: user.uid).setCustomerDetails(customer);

      setState(() => loading = false);
    }
  }

  Future<void> _pickDOB() async {
    final selectedDate = customer.dob != null ? customer.dob : DateTime.now();

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        customer.dob = picked;
        dobController.text = picked.toString();
      });
  }
}*/