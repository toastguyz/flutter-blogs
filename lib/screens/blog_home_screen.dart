import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blogs/models/model_blog.dart';
import 'package:flutter_blogs/screens/blog_create_screen.dart';
import 'package:flutter_blogs/screens/blog_dashboard_indicator.dart';
import 'package:flutter_blogs/screens/blog_detail_screen.dart';
import 'package:flutter_blogs/utils/network_utils.dart';
import 'package:flutter_blogs/utils/theme_utils.dart';
import 'package:intl/intl.dart';

class BlogHomeScreen extends StatefulWidget {
  @override
  _BlogHomeScreenState createState() => _BlogHomeScreenState();
}

class _BlogHomeScreenState extends State<BlogHomeScreen>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  var _pageController = PageController(viewportFraction: 1.0);
  var images = [
    "image_one.jpg",
    "image_two.jpg",
    "image_three.jpeg",
    "image_four.jpg"
  ];
  bool isLoading = false;
  List<ModelBlog> blogList = [];

//  var dateFormat = DateFormat("dd-MM-yyyy hh:mm:ss a");
  var dateFormat = DateFormat("dd MMM, yyyy");

  @override
  void initState() {
    super.initState();

    fetchBlogList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(
          Icons.menu,
          color: themeColor,
        ),
        primary: true,
        centerTitle: true,
        title: Text("Dashboard", style: TextStyle(color: themeColor)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share, color: themeColor),
            onPressed: () {},
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : blogList == null || blogList.length == 0
              ? Center(
                  child: Text(
                    "No Blogs Found!!",
                    style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 25.0),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Stack(
                        children: <Widget>[
                          dashboard(context),
                        ],
                      ),
                      Container(
                        height: 20.0,
                        child: Center(
                          child: BlogDashboardIndicator(
                            controller: _pageController,
                            itemCount: images.length,
                            color: themeColor,
                            onPageSelected: (int page) {
                              _pageController.animateToPage(page,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Blogs",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: themeColor),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite_border,
                                size: 25.0,
                                color: themeColor,
                              ),
                              onPressed: () {},
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey[200],
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: blogList.length,
                          itemBuilder: (BuildContext context, int index) {
                            var blogDateTime =
                                DateTime.parse(blogList[index].updatedAt);
                            final blogDate = dateFormat.format(blogDateTime);

                            return Hero(
                              tag: blogList[index].id,
                              child: Card(
                                margin: index != (blogList.length - 1)
                                    ? EdgeInsets.only(
                                        top: 10.0,
                                        left: 10.0,
                                        right: 10.0,
                                        bottom: 0.0)
                                    : EdgeInsets.only(
                                        top: 10.0,
                                        left: 10.0,
                                        right: 10.0,
                                        bottom: 10.0),
                                color: themeColor,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BlogDetailScreen(
                                                  blogList[index])),
                                    );
                                  },
                                  title: Text(
                                    blogList[index].blogTitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    blogList[index].blogDescription,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leading: CircleAvatar(
                                    child: CircleAvatar(
                                      backgroundImage: blogList[index] != null && blogList[index].blogImage != null && blogList[index].blogImage.length>0
                                          ? NetworkImage(blogList[index].blogImage)
                                          : AssetImage("assets/blog_placeholder.jpg"),
                                    ),
                                  ),
                                  trailing: Text(
                                    blogDate,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
//          _createBlogPost();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BlogCreateScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  fetchBlogList() async {
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
      final blogTaskReference =
          FirebaseDatabase.instance.reference().child("BlogPosts");

      blogTaskReference.onValue.listen((Event event) {
        blogList = [];
        if (event.snapshot.value != null) {
          for (var value in event.snapshot.value.values) {
            blogList.add(ModelBlog.fromJson(value));
          }
        }

        /*for (int i = 0; i < blogList.length; i++) {
          print(blogList[i].id);
          print(blogList[i].blogTitle);
          print(blogList[i].blogImage);
          print(blogList[i].blogDescription);
          print(blogList[i].updatedAt);
        }*/

        setState(() {
          isLoading = false;
        });
      });

      // Method-1
      /*blogTaskReference.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          print(key);
          print(values);
          print('---------');
        });
      });*/

      // Method-2
      /*blogTaskReference.orderByKey().onValue.listen((blog) {
        for (var value in blog.snapshot.value.values) {
          print("Key ${value}");
          print('---------');
        }
      });*/
    } catch (error) {
      print("catch block : " + error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget dashboard(context) {
    return Container(
//      height: 200,
      height: MediaQuery.of(context).size.height * 0.3,
      child: PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: images.length,
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        itemBuilder: (BuildContext context, int index) {
          return getPageContent(index);
        },
      ),
    );
  }

  Widget getPageContent(index) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      borderOnForeground: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Image.asset(
        "assets/${images[index]}",
        fit: BoxFit.cover,
      ),
//      color: backgroundColor,
    );
  }
}
