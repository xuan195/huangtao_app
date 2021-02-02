class RedditPost {
  final String imgUrl;
  final String title;

  RedditPost({this.imgUrl,this.title});

  factory RedditPost.fromJson(Map<String,dynamic> json){
    return RedditPost(imgUrl: json['url'], title: json['title']);
  }
}