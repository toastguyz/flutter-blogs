import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blogs/models/model_blog.dart';
import 'package:flutter_blogs/utils/network_utils.dart';
import 'package:flutter_blogs/utils/theme_utils.dart';
import 'package:image_picker/image_picker.dart';

class BlogCreateScreen extends StatefulWidget {
  final ModelBlog blog;

  BlogCreateScreen({this.blog});

  @override
  _BlogCreateScreenState createState() => _BlogCreateScreenState();
}

class _BlogCreateScreenState extends State<BlogCreateScreen> {
  var _titleController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var isLoading = false;
  var isEditInitialised = true;

  File _imageFile;
  String filePath;
  Uri fileURI;

  _getImage(BuildContext context, ImageSource source) async {
    ImagePicker.pickImage(
      source: source,
      maxWidth: 400.0,
      maxHeight: 400.0,
    ).then((File image) async {
      if (image != null) {
        setState(() {
          _imageFile = image;
          filePath = image.path;
          fileURI = image.uri;
        });
      }
    });
  }

  Future<String> uploadImage(File image) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child("images/${DateTime.now().toIso8601String()}");

    StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);

    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    String storagePath = await taskSnapshot.ref.getDownloadURL();
    print("storagePath : ${storagePath}");

    Uri finalPath = Uri.parse(storagePath);
    print("finalPath : ${finalPath}");

    return storagePath;
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    "Select Image",
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () {
                    _getImage(context, ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.photo_camera,
                        size: 30.0,
                        color: themeColor,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                      ),
                      Text(
                        "Use Camera",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () {
                    _getImage(context, ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.camera,
                        size: 30.0,
                        color: themeColor,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                      ),
                      Text(
                        "Use Gallery",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: themeColor,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildBlogImage() {
    return GestureDetector(
      onTap: () {
        _openImagePicker(context);
      },
      child: Center(
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.height * 0.3,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                /*image: DecorationImage(
                  image: widget.blog!=null && widget.blog.blogImage != null
                      ? AssetImage("assets/${widget.blog.blogImage}")
                      : AssetImage('assets/blog_placeholder.jpg'),
                  fit: BoxFit.cover,
                ),*/

                image: DecorationImage(
                  image: _imageFile != null
                      ? FileImage(_imageFile)
                      : widget.blog != null &&
                              widget.blog.blogImage != null &&
                              widget.blog.blogImage.length > 0
                          ? NetworkImage(
                              widget.blog.blogImage,
                            )
                          : AssetImage('assets/blog_placeholder.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height * 0.15,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 5.0,
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.045,
              right: MediaQuery.of(context).size.height * 0.045,
              child: Container(
                width: MediaQuery.of(context).size.height * 0.03,
                height: MediaQuery.of(context).size.height * 0.03,
                /*child: Icon(Icons.add_circle,color: Colors.red,),*/
                child: Icon(
                  Icons.camera_enhance,
                  color: themeColor,
                  size: 30.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: themeColor,
                  ),
                  onPressed: () {
                    if (MediaQuery.of(context).viewInsets.bottom == 0) {
                      // keyboard is not open
                      Navigator.of(context).pop();
                    } else {
                      // keyboard is open
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.done,
                    color: themeColor,
                  ),
                  onPressed: () {
                    _submitBlogPost();
                  },
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Expanded(
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              _buildBlogImage(),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    hintText: "Blog Title",
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  style: TextStyle(color: themeColor),
                                  keyboardType: TextInputType.text,
                                  validator: (String title) {
                                    if (title.isEmpty || title.length < 6) {
                                      return 'valid blog title is required!!';
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: TextFormField(
                                  minLines: 10,
                                  maxLines: 10,
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    hintText: "Blog Description",
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  style: TextStyle(color: themeColor),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.newline,
                                  validator: (String description) {
                                    if (description.isEmpty ||
                                        description.length < 10) {
                                      return 'valid blog description is required!!';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submitBlogPost() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    NetworkCheck networkCheck = NetworkCheck();
    networkCheck.checkInternet((isNetworkPresent) async {
      if (!isNetworkPresent) {
        final snackBar =
            SnackBar(content: Text("Please check your internet connection !!"));

        Scaffold.of(context).showSnackBar(snackBar);
        return;
      } else {
        setState(() {
          isLoading = true;
        });
      }
    });

    try {
      var imageUrl;
      try {
        if (_imageFile != null) {
          imageUrl = await uploadImage(_imageFile);
        }
      } catch (error) {
        print(error.toString());
      }

      final blogTaskReference =
          FirebaseDatabase.instance.reference().child("BlogPosts");

      String resourceID = blogTaskReference.push().key;
      if (widget.blog == null || widget.blog.id == null) {
        await blogTaskReference.child(resourceID).set({
          "id": resourceID,
          "blogTitle": _titleController.text,
          "blogImage": imageUrl != null && imageUrl.length > 0 ? imageUrl : "",
          "blogDescription": _descriptionController.text,
          "updatedAt": DateTime.now().toIso8601String(),
        });
      } else {
        await blogTaskReference.child(widget.blog.id).update({
          "id": widget.blog.id,
          "blogTitle": _titleController.text,
          "blogImage": imageUrl != null && imageUrl.length > 0
              ? imageUrl
              : widget.blog.blogImage,
          "blogDescription": _descriptionController.text,
          "updatedAt": DateTime.now().toIso8601String(),
        });
      }

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop();
    } catch (error) {
      print("catch block : " + error.toString());

      setState(() {
        isLoading = false;
      });

      final snackBar =
          SnackBar(content: Text("Something went wrong. please try again !!"));

      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void didChangeDependencies() {
    if (widget.blog != null) {
      if (isEditInitialised) {
        _titleController.text = widget.blog.blogTitle;
        _descriptionController.text = widget.blog.blogDescription;
        isEditInitialised = false;
      }
    }

    super.didChangeDependencies();
  }
}
