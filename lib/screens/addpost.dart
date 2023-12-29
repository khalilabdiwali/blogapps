import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:blogapp/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool showSpinner = false;
  // ignore: deprecated_member_use
  final postRef = FirebaseDatabase.instance.reference().child('Posts');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  Future getImageGallery() async {
    final PickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (PickedFile != null) {
        _image = File(PickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

  Future getImageCamera() async {
    final PickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      if (PickedFile != null) {
        _image = File(PickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

  void dialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      getImageCamera();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Camera'),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getImageGallery();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Gallery'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Color(0xff4964c5),
            title: Text(
              'Upload Blogs ',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      dialog(context);
                    },
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .2,
                        width: MediaQuery.of(context).size.width * 1,
                        child: _image != null
                            ? ClipRRect(
                                child: Image.file(
                                  _image!.absolute,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 100,
                                height: 100,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.blue,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'title',
                            hintText: 'Enter Post title',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: _descriptionController,
                          keyboardType: TextInputType.text,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter Post Description',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Roundedbutton(
                      title: 'Upload',
                      onPress: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          int date = DateTime.now().microsecondsSinceEpoch;
                          firebase_storage.Reference ref = firebase_storage
                              .FirebaseStorage.instance
                              .ref('/blogapp$date');
                          UploadTask uploadtask = ref.putFile(_image!.absolute);
                          await Future.value(uploadtask);
                          var newUrl = await ref.getDownloadURL();
                          final User? user = _auth.currentUser;
                          postRef
                              .child('Post List')
                              .child(date.toString())
                              .set({
                            "pId": date.toString(),
                            "pImage": newUrl.toString(),
                            // "pTime": date.toString(),
                            "pTime": DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now()), // Format the timestamp
                            "pTitle": _titleController.text,
                            "pDescription":
                                _descriptionController.text.toString(),
                            "uEmail": user!.email.toString(),
                            // "uImage": user!.photoURL.toString(),
                            "uid": user!.uid.toString(),
                            //"url": newUrl.toString()
                          }).then((value) {
                            toastmessages('Post Published');
                            setState(() {
                              showSpinner = false;
                            });
                          }).onError((error, stackTrace) {
                            toastmessages(error.toString());
                            setState(() {
                              showSpinner = false;
                            });
                          });
                        } catch (e) {
                          toastmessages(e.toString());
                          setState(() {
                            showSpinner = false;
                          });
                          toastmessages(e.toString());
                        }
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void toastmessages(String message) {
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
