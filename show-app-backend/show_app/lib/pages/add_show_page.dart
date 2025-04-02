import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/show.dart';

class AddShowPage extends StatefulWidget {
  @override
  _AddShowPageState createState() => _AddShowPageState();
}

class _AddShowPageState extends State<AddShowPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  File? _image;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No image selected.')),
          );
        }
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_image != null) {
        Show newShow = Show(
          id: '',
          title: _title,
          description: _description,
          image: _image!.path,
        );
        await ApiService().addShow(newShow);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Show'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: pickImage,
                child: Icon(Icons.add_a_photo),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Show'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}