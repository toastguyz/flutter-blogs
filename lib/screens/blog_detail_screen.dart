import 'package:flutter/material.dart';
import 'package:flutter_blogs/models/model_blog.dart';
import 'package:flutter_blogs/screens/blog_create_screen.dart';
import 'package:flutter_blogs/utils/theme_utils.dart';

class BlogDetailScreen extends StatefulWidget {
  final ModelBlog blog;

  BlogDetailScreen(this.blog);

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: themeColor,
            pinned: true,
            titleSpacing: 0.0,
            expandedHeight: MediaQuery.of(context).size.height * 0.3,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
//              titlePadding: EdgeInsets.only(left:40.0,top: 10.0,bottom: 10.0),
              title: Text(
                widget.blog.blogTitle,
                textAlign: TextAlign.center,
              ),
              background: Hero(
                tag: widget.blog.id,
                child: widget.blog.blogImage != null &&
                        widget.blog.blogImage.length > 0
                    ? Image.network(
                        widget.blog.blogImage,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/blog_placeholder.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogCreateScreen(
                        blog: widget.blog,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: double.infinity,
                child: Text(
                  widget.blog.blogDescription,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: 1000.0,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
