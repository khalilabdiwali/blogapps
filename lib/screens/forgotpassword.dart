import 'package:blogapp/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String email = '';

  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff4964c5),
          automaticallyImplyLeading: false,
          title: Text(
            'Forgot Password',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            // Add a background image or color
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff4964c5)),
                    ),
                    SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (String value) {
                              email = value;
                            },
                            validator: (value) {
                              return value!.isEmpty ? 'Enter email' : null;
                            },
                          ),
                          //SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Roundedbutton(
                              title: 'Recover Password',
                              onPress: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    showSpinner = true;
                                  });
                                  try {
                                    auth
                                        .sendPasswordResetEmail(
                                            email: _email.text.toString())
                                        .then((value) {
                                      setState(() {
                                        showSpinner = false;
                                      });
                                      toastMessages(
                                          'Please Check you email reset link has been sent to you via email');
                                    }).onError((error, stackTrace) {
                                      toastMessages(error.toString());
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    });
                                    // final user =
                                    //     await auth.signInWithEmailAndPassword(
                                    //   email: email.toString().trim(),
                                    //   password: password.toString().trim(),
                                    // );
                                    // if (user != null) {
                                    //   print('SUCCESS');
                                    //   toastMessages(
                                    //       'User successfully logged in');
                                    //   setState(() {
                                    //     showSpinner = false;
                                    //   });
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => Home()),
                                    //   );
                                    // }
                                  } catch (e) {
                                    print(e.toString());
                                    toastMessages(e.toString());
                                    setState(() {
                                      showSpinner = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void toastMessages(String message) {
    Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.deepOrange, // Adjust the background color
      textColor: Colors.white, // Adjust the text color
      fontSize: 16.0,
    );
  }
}
