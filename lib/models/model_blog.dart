class ModelBlog {
  String id;
  String blogTitle;
  String blogImage;
  String blogDescription;
  String updatedAt;

  ModelBlog(this.id, this.blogTitle, this.blogImage, this.blogDescription,
      this.updatedAt);

  ModelBlog.fromJson(var value) {
    this.id = value["id"];
    this.blogTitle = value["blogTitle"];
    this.blogImage = value["blogImage"];
    this.blogDescription = value["blogDescription"];
    this.updatedAt = value["updatedAt"];
  }
}
