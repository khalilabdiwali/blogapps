import 'dart:async';

import 'package:blogapp/screens/addpost.dart';
import 'package:blogapp/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbRef = FirebaseDatabase.instance.reference().child('Posts');
  final auth = FirebaseAuth.instance;
  TextEditingController SearchController = TextEditingController();
  TextEditingController _updateTitleController = TextEditingController();
  TextEditingController _updateDescriptionController = TextEditingController();
// Add more controllers if needed

  String Search = "";
  bool isFavorite = false;
  User? user = FirebaseAuth.instance.currentUser;

  void deletePost(String postId, String postUid) {
    // Check if the current user is the owner of the post
    if (user!.uid == postUid) {
      dbRef.child('Post List').child(postId).remove();
      toastmessages("post has been deleted successfully.");

      // You can also add additional actions or notifications after successful deletion
    } else {
      // Show an error message or notification indicating that only the post owner can delete it
      toastmessages("You don't have permission to delete this post.");
    }
  }

  void updatePost(
      String postId, String postUid, String newTitle, String newDescription) {
    if (user!.uid == postUid) {
      dbRef.child('Post List').child(postId).update({
        "pTitle": newTitle,
        "pDescription": newDescription,
        "pTime": DateTime.now().toString(),
      });
      toastmessages("Post has been updated successfully.");
    } else {
      toastmessages("You don't have permission to update this post.");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff4964c5),
        title: Text(
          'Blog Posts',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )),
          SizedBox(
            width: 20,
          ),
          InkWell(
              onTap: () {
                auth.signOut().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 13.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: TextFormField(
                controller: SearchController,
                //keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Search with blog title',
                  labelText: 'Search',
                  suffixIcon: Icon(
                    Icons.search,
                    color: Color(0xff4964c5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff4964c5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (String value) {
                  Search = value;
                },
              ),
            ),
            Expanded(
              child: FirebaseAnimatedList(
                query: dbRef.child('Post List'),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  String TemTitle = snapshot.child('pTitle').value.toString();
                  if (SearchController.text.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  foregroundImage:
                                      AssetImage('assets/tijabo.png'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    //'${currentUser?.email}',
                                    snapshot.child('uEmail').value.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage.assetNetwork(
                                  fit: BoxFit.fitHeight,
                                  // height: MediaQuery.of(context).size.height * .5,
                                  // width: MediaQuery.of(context).size.width * .5,
                                  placeholder: 'assets/tijabo.png',
                                  image: snapshot
                                      .child('pImage')
                                      .value
                                      .toString()),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                snapshot.child('pTitle').value.toString(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                snapshot.child('pTime').value.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                  snapshot
                                      .child('pDescription')
                                      .value
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 400,
                              height: 40,
                              color: Color(0xff4964c5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      color: isFavorite
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      // Toggle the state when the button is pressed
                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Update Post"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller:
                                                      _updateTitleController,
                                                  decoration: InputDecoration(
                                                      labelText: 'New Title'),
                                                ),
                                                TextField(
                                                  controller:
                                                      _updateDescriptionController,
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'New Description'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  updatePost(
                                                    snapshot
                                                        .child('pId')
                                                        .value
                                                        .toString(),
                                                    snapshot
                                                        .child('uid')
                                                        .value
                                                        .toString(),
                                                    _updateTitleController.text,
                                                    _updateDescriptionController
                                                        .text,
                                                  );
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text("Update"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Delete Post"),
                                            content: Text(
                                                "Are you sure you want to delete this post?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Close the dialog
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Delete the post from Firebase
                                                  deletePost(
                                                    snapshot
                                                        .child('pId')
                                                        .value
                                                        .toString(),
                                                    snapshot
                                                        .child('uid')
                                                        .value
                                                        .toString(),
                                                  );
                                                  // Close the dialog
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else if (TemTitle.toLowerCase()
                      .contains(SearchController.text.toString())) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  foregroundImage:
                                      AssetImage('assets/tijabo.png'),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10),
                                //   child: Text(
                                //     // '${currentUser?.email}',
                                //     snapshot.child('uid').value.toString(),
                                //     style: TextStyle(
                                //         fontSize: 15,
                                //         fontWeight: FontWeight.normal),
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    //'${currentUser?.email}',
                                    snapshot.child('uEmail').value.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage.assetNetwork(
                                  fit: BoxFit.fitHeight,
                                  // height: MediaQuery.of(context).size.height * .5,
                                  // width: MediaQuery.of(context).size.width * .5,
                                  placeholder: 'assets/tijabo.png',
                                  image: snapshot
                                      .child('pImage')
                                      .value
                                      .toString()),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                snapshot.child('pTitle').value.toString(),
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                  snapshot
                                      .child('pDescription')
                                      .value
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal)),
                            ),
                            Container(
                              width: 400,
                              height: 40,
                              color: Color(0xff4964c5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      color: isFavorite
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      // Toggle the state when the button is pressed
                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Update Post"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller:
                                                      _updateTitleController,
                                                  decoration: InputDecoration(
                                                      labelText: 'New Title'),
                                                ),
                                                TextField(
                                                  controller:
                                                      _updateDescriptionController,
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'New Description'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  updatePost(
                                                    snapshot
                                                        .child('pId')
                                                        .value
                                                        .toString(),
                                                    snapshot
                                                        .child('uid')
                                                        .value
                                                        .toString(),
                                                    _updateTitleController.text,
                                                    _updateDescriptionController
                                                        .text,
                                                  );
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text("Update"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Delete Post"),
                                            content: Text(
                                                "Are you sure you want to delete this post?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Close the dialog
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Delete the post from Firebase
                                                  deletePost(
                                                    snapshot
                                                        .child('pId')
                                                        .value
                                                        .toString(),
                                                    snapshot
                                                        .child('uid')
                                                        .value
                                                        .toString(),
                                                  );
                                                  // Close the dialog
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
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
