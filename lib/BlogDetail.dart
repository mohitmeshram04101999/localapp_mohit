import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:localapp/MyPostScreen.dart';
import 'package:localapp/VideoPlayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VideoPlayerScreen.dart';
import 'constants/Config.dart';
import 'package:http/http.dart' as http;
import 'package:localapp/models/Category.dart';
import 'package:localapp/models/SubCategory.dart';
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'image_viewer.dart';
import 'models/BlogDetailList.dart';
import 'models/LocalAd.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';


class BlogDetailScreen extends StatefulWidget {
  String BlogPostId;
  String PostCategory;
  String PostSubCategory;
  bool FromMyPost;
  BlogDetailScreen(this.BlogPostId,this.PostCategory,this.PostSubCategory,this.FromMyPost);

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  bool showShimmer = true; // Track whether to show shimmer or data
  final Duration shimmerDuration = Duration(seconds: 2);

  int selectedIdx = 0;
  String status='';
  int selected_category=1;
  int selected_sub_category=1;

  List categorylist_data = [];
  List<Category_list> categorylist_string = [];

  List sub_categorylist_data = [];
  List<SubCategory_list> sub_categorylist_string = [];

  List local_ad_data = [];
  List<LocalAd_list> local_ad_string = [];

  List blog_data = [];
  List<Blog_Detail_list> blog_string=[];
  String CategoryName='';
  int _currentIndex=0;

  String BlogPostId='';
  String Heading='';
  String HText='';
  String PostDisplayPhoto='';
  String TimeAgo='';
  String SubCategoryName='';
  String PostImage1='';
  String PostImage2='';
  String PostImage3='';
  String PostImage4='';
  String PostImage5='';
  String PostCategory='';
  String PostSubCategory='';
  String VideoLink='';
  String ShareText='';
  String PostByName='';
  String WhatsappNumber='';
  String WhatsappText='';
  String ShareLink='';
  String videoId='';
  String Status='';
  String RejectionComment='';
  String EndDate='';
  String TotalClicks='';
  late YoutubePlayerController _controller=YoutubePlayerController(
    initialVideoId: '${videoId}',
    flags: YoutubePlayerFlags(
      autoPlay: false,
    ),
  );


  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;


  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1), () {
      GetBlogData();
    });
    Timer(shimmerDuration, () {
      if (mounted) {
        setState(() {
          showShimmer = false;
        });
      }
    });

    super.initState();
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void selectItem(int index,String cat_id) {
    setState(() {
      selected_category=int.parse(cat_id);
      GetBlogData();
      if (index == selectedIdx) {
        // If the same item is tapped again, clear the selection
        selectedIdx = 0;
      } else {
        selectedIdx = index;
      }
    });
  }

  final List<String> imageList = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
    'assets/images/image5.jpg',
  ];
  List<String> items_2 = ["#all", "#crime", "#pimpriKand"];
  int selectedIdx_2 = -1;

  void onItemClicked(int index,String subcat_id) {
    setState(() {
      selectedIdx_2 = index;
      selected_sub_category=int.parse(subcat_id);
    });
   // getBlogData();

  }


  void onPageChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      _currentIndex = index;
    });
  }
  showLoaderDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,

              ),
              width: 80, // Dialog width
              height: 80, // Dialog height
              child: SingleChildScrollView(
                child:Image.asset(
                  "assets/images/loader.gif",
                  width: 80,
                  height: 80,

                ),
              ),
            ),
          ),
        );
      },
    );

  }

  GetBlogData() async{
    showLoaderDialog(context);
    var url = Config.get_blog_data;
    print('selected_category${widget.PostCategory}');
    print('selected_sub_category${widget.PostSubCategory}');
    print('post_id${widget.BlogPostId}');
    String? deviceId = await PlatformDeviceId.getDeviceId;

    http.Response response = await http.post(Uri.parse(url), body: {
      'category_id':'${widget.PostCategory}',
      'subcategory_id':'${widget.PostSubCategory}',
      'post_id':'${widget.BlogPostId}',
      'user_id':'${deviceId}'
    });
    Map<String, dynamic> data = json.decode(response.body );
    status = data["success"];
    print('status${status}');


    if (status == "0") {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();

      });
      categorylist_data = data['data']['category'] as List;
      categorylist_string = categorylist_data.map<Category_list>(
              (json) => Category_list.fromJson(json)).toList();

      sub_categorylist_data = data['data']['sub_category'] as List;
      sub_categorylist_string = sub_categorylist_data.map<SubCategory_list>(
              (json) => SubCategory_list.fromJson(json)).toList();

      local_ad_data = data['data']['local_ad']==null?[]: data['data']['local_ad'] as List;
      local_ad_string = local_ad_data.map<LocalAd_list>(
              (json) => LocalAd_list.fromJson(json)).toList();

      blog_data = data['data']['blog'] as List;
      blog_string = blog_data.map<Blog_Detail_list>(
              (json) => Blog_Detail_list.fromJson(json)).toList();


      setState(() {

        CategoryName=blog_string[0].CategoryName==null?'':blog_string[0].CategoryName;
        Heading=blog_string[0].Heading==null?'':blog_string[0].Heading;
        HText=blog_string[0].Text==null?'':blog_string[0].Text;
        PostDisplayPhoto=blog_string[0].PostDisplayPhoto==null?'':blog_string[0].PostDisplayPhoto;
        SubCategoryName=blog_string[0].SubCategoryName==null?'':blog_string[0].SubCategoryName;
        PostImage1=blog_string[0].PostImage1==null?'':blog_string[0].PostImage1;
        PostImage2=blog_string[0].PostImage2==null?'':blog_string[0].PostImage2;
        PostImage3=blog_string[0].PostImage3==null?'':blog_string[0].PostImage3;
        PostImage4=blog_string[0].PostImage4==null?'':blog_string[0].PostImage4;
        PostImage5=blog_string[0].PostImage5==null?'':blog_string[0].PostImage5;
        VideoLink=blog_string[0].VideoLink==null?'':blog_string[0].VideoLink;
        ShareText=blog_string[0].ShareText==null?'':blog_string[0].ShareText;
        PostByName=blog_string[0].PostByName==null?'':blog_string[0].PostByName;
        ShareLink=blog_string[0].ShareLink==null?'':blog_string[0].ShareLink;
        TimeAgo=blog_string[0].TimeAgo;
        Status=blog_string[0].Status==null?'':blog_string[0].Status;
        RejectionComment=blog_string[0].RejectionComment==null?'':blog_string[0].RejectionComment;
        WhatsappNumber=blog_string[0].WhatsappNumber==null?'':blog_string[0].WhatsappNumber;
        WhatsappText=blog_string[0].WhatsappText==null?'':blog_string[0].WhatsappText;
        EndDate=blog_string[0].EndDate==null?'':blog_string[0].EndDate;
        TotalClicks=blog_string[0].TotalClicks==null?'':blog_string[0].TotalClicks;

        if(VideoLink!='')
          {
            videoId = YoutubePlayer.convertUrlToId("${VideoLink}")!;
            _controller = YoutubePlayerController(
              initialVideoId: '${videoId}',
              flags: YoutubePlayerFlags(
                autoPlay: false,
              ),
            );

          }


      });
    }
    else{
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();

      });
    }
  }
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this post?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // Call delete_post() or perform deletion logic here
                Navigator.of(context).pop(); // Close the dialog
                delete_post();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  ad_response(ad_id) async {

    var url = Config.insert_ad_response;
    String? deviceId = await PlatformDeviceId.getDeviceId;
    print('deviceId${deviceId}');
    print('ad_id${ad_id}');
    http.Response response = await http.post(Uri.parse(url)
        , body: {
          "user_id": '${deviceId}',
          "ad_id":'${ad_id}'
        });




  }

  delete_post() async{
    showLoaderDialog(context);
    String? deviceId = await PlatformDeviceId.getDeviceId;

    var url = Config.delete_post;
    http.Response response = await http.post(Uri.parse(url), body: {
      'BlogPostId':'${widget.BlogPostId}',
      'user_id':'${deviceId}'
    });
    Map<String, dynamic> data = json.decode(response.body );
    status = data["success"];
    if (status == "0") {
      Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.black,
          fontSize: 15.0);
      Navigator.of(context).pop();


      Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyPostScreen(false)));


    }
    else{
        Navigator.of(context).pop();


      Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.black,
          fontSize: 15.0);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  MyPostScreen(false)));

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

          backgroundColor: Colors.white,
          appBar:AppBar(
            backgroundColor: Colors.white, // Change app bar color to white
            elevation: 0.0, // Remove the bottom border
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            iconTheme: IconThemeData(color: Colors.black), // Change icon color to black
            textTheme: TextTheme(
              headline6: TextStyle(color: Colors.black), // Change text color to black
            ),

            centerTitle: true,
            title: Row(
              children: [

                Text('${CategoryName}',
                    style:TextStyle(color: Colors.black,)),
              ],
            ),
            actions: [
              if(widget.FromMyPost==true)...[
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                    },
                ),
                ]
              ],
          ),

          body:       WillPopScope(
              onWillPop: () async {
                 Navigator.of(context).pop();
                   return false;
              },
              child:
              RefreshIndicator(
                  onRefresh:_refreshData,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child:

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: 5),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              if(VideoLink!='')...[
                                InkWell(
                                  onTap:(){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoId:videoId)));

                                  },
                                  child:        Stack(
                                    children: [
                                      Image.network(
                                        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                      Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 72.0,
                                      ),
                                    ],
                                  ),



                                  /*YoutubePlayer(
                                    controller: _controller,
                                    aspectRatio: 16 / 9,
                                  ),*/
                                ),

                              ]     else...[


                                GestureDetector(
                                  onTap:(){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,0,'blog')));


                                  },
                                  child:

                                  showShimmer
                                      ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 380,
                                      color: Colors.white,
                                    ),
                                  )
                                      :
                                  Container(
                                    color:Colors.white,
                                    alignment: Alignment.center,
                                    child:
                                    CachedNetworkImage(
                                      imageUrl:Config.Image_Path+'blog/${PostDisplayPhoto}',
                                    ),

                                  ),
                                )


                              ],
                              SizedBox(height: 10.0),
                              Center(
                                child:    Row(
                                  children: [

                                    if(VideoLink!='')...[
                                      showShimmer
                                          ? Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 380,
                                          color: Colors.white,
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,0,'blog')));


                                        },
                                        child:
                                        CachedNetworkImage(
                                            width: MediaQuery.of(context).size.width/6.5,
                                            height: 80,

                                            imageUrl:Config.Image_Path+'blog/${PostDisplayPhoto}',
                                            placeholder: (context, url) =>Image.asset(
                                              "assets/images/loader.gif",
                                              width: 80,
                                              height: 80,


                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              "assets/images/loader.gif",
                                              width: 80,
                                              height: 80,


                                            )
                                        ),
                                      ),


                                    ],
                                    if(PostImage1!='')...[

                                      SizedBox(width: 10),
                                      showShimmer
                                          ? Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,1,'blog')));


                                        },
                                        child:
                                        CachedNetworkImage(
                                            width: MediaQuery.of(context).size.width/6.5,
                                            height: 80,

                                            imageUrl:Config.Image_Path+'blog/${PostImage1}',
                                            placeholder: (context, url) =>Image.asset(
                                              "assets/images/loader.gif",
                                              width: 80,
                                              height: 80,


                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              "assets/images/loader.gif",
                                              width: 80,
                                              height: 80,


                                            )
                                        ),
                                      ),



                                    ],
                                    if(PostImage2!='')...[
                                      SizedBox(width: 10),
                                      showShimmer
                                          ? Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,2,'blog')));


                                        },
                                        child:
                                        CachedNetworkImage(
                                          width: MediaQuery.of(context).size.width/6.5,
                                          height: 80,

                                          imageUrl:Config.Image_Path+'blog/${PostImage2}',
                                          placeholder: (context, url) =>Image.asset(
                                            "assets/images/loader.gif",
                                            width: 80,
                                            height: 80,


                                          ),
                                          errorWidget: (context, url, error) => Image.asset(
                                            "assets/images/loader.gif",
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      )
                                    ],
                                    if(PostImage3!='')...[

                                      SizedBox(width: 10),
                                      showShimmer
                                          ? Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,3,'blog')));


                                        },
                                        child:
                                        CachedNetworkImage(
                                          width: MediaQuery.of(context).size.width/6.5,
                                          height: 80,

                                          imageUrl:Config.Image_Path+'blog/${PostImage3}',
                                          placeholder: (context, url) => Image.asset(
                                            "assets/images/loader.gif",
                                            width: 80,
                                            height: 80,


                                          ),
                                          errorWidget: (context, url, error) => Image.asset(
                                            "assets/images/loader.gif",
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      )
                                    ],
                                    if(PostImage4!='')...[

                                      SizedBox(width: 10),
                                      showShimmer
                                          ? Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,4,'blog')));


                                        },
                                        child:
                                        CachedNetworkImage(
                                          width: MediaQuery.of(context).size.width/6.5,
                                          height: 80,

                                          imageUrl:Config.Image_Path+'blog/${PostImage4}',
                                          placeholder: (context, url) =>Image.asset(
                                            "assets/images/loader.gif",
                                            width: 80,
                                            height: 80,


                                          ),
                                          errorWidget: (context, url, error) =>Image.asset(
                                            "assets/images/loader.gif",
                                            width: 80,
                                            height: 80,


                                          ),
                                        ),
                                      )

                                    ],
                                    if(PostImage5!='')...[

                                      SizedBox(width: 10),
                                      showShimmer
                                          ? Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          color: Colors.white,
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  ImageViewer(PostDisplayPhoto,PostImage1,PostImage2,PostImage3,PostImage4,PostImage5,5,'blog')));


                                        },
                                        child:
                                        CachedNetworkImage(
                                            width: MediaQuery.of(context).size.width/6.5,
                                            height: 80,

                                            imageUrl:Config.Image_Path+'blog/${PostImage5}',
                                            placeholder: (context, url) =>Image.asset(
                                              "assets/images/loader.gif",
                                              width: 80,
                                              height: 80,


                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              "assets/images/loader.gif",
                                              width: 80,
                                              height: 80,


                                            )
                                        ),
                                      )

                                    ],
                                  ],

                                ),
                              ),
                            /*  showShimmer
                                  ?
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  color: Colors.white,
                                ),
                              )
                                  :  Container(
                                padding: const EdgeInsets.only(left:10),
                                child:  Html(
                                  data:'${Heading}',

                                ),
                              ),
                              */
                              if(PostByName!='')...[


                              showShimmer
                                  ?
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  color: Colors.white,
                                ),
                              )
                                  :  Container(
                                padding: const EdgeInsets.only(left:15),
                                child:   Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.person, // Map pin icon
                                      color: Colors.black, // Optional: Set the color of the icon
                                      size: 15, // Optional: Set the size of the icon
                                    ),
                                    SizedBox(width: 2),
                                    Container(
                                      width: 200,
                                      child:  Text(
                                        'Post by: ${PostByName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // Add spacing between the icon and text
                                  ],
                                ),
                              ),
                              ],

                              SizedBox(height: 10.0),
                              showShimmer
                                  ?
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child:
                                Container(
                                    height: 300,
                                    child:  ListView.builder(
                                      itemCount: 5, // Number of lines
                                      itemBuilder: (context, index) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                            width: double.infinity,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                ),

                              )
                                  :
                              Container(
                                padding: const EdgeInsets.only(left:10),
                                child:  Html(
                                  data:'${HText}',
                                  onLinkTap: (url, _, __, ___) async {
                                    if (await canLaunch(url!)) {
                                      await launch(
                                        url,
                                      );
                                    }
                                  },

                                ),
                              ),
                              if(ShareText!='')...[
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if(ShareLink!='')
                                          {
                                            launchUrl(ShareLink);

                                          }
                                        else{
                                          launchUrl("https://wa.me/+91${WhatsappNumber}?text=${WhatsappText}");

                                        }
                                        // Add your button click logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        primary: Colors.black, // Set the background color to black
                                      ),
                                      child:
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                                        child:
                                        Text(
                                          '${ShareText}',
                                          style: TextStyle(
                                            fontSize: 11.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),


                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child:    Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.grey,
                                            size: 16.0,
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(
                                            '${TimeAgo}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ],

                              /*if(WhatsappNumber!='')...[
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        launchUrl("https://wa.me/+91${WhatsappNumber}?text=${WhatsappText}");
                                        // Add your button click logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        primary: Colors.black, // Set the background color to black
                                      ),
                                      child:
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                                        child:
                                        Text(
                                          '${ShareText}',
                                          style: TextStyle(
                                            fontSize: 11.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),


                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child:    Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.grey,
                                            size: 16.0,
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(
                                            '${TimeAgo}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ]*/





                            ],
                          ),
                        ),

                        if(local_ad_string.length>0)...[
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                GestureDetector(
                                    onTap: (){
                                      ad_response(local_ad_string[0].AdId);

                                      if(local_ad_string[0].Url!='')
                                      {
                                        launchUrl(local_ad_string[0].Url);

                                      }
                                      else{
                                        String w_no=local_ad_string[0].WhatsappNumber;
                                        String w_msg=local_ad_string[0].WhatsappText;
                                        String url="https://wa.me/+91${w_no}?text=${w_msg}";
                                        if(local_ad_string[0].Url!='')
                                        {
                                          url=local_ad_string[0].Url;
                                        }

                                        launchUrl(url);

                                      }
                                    },
                                    child:

                                    CachedNetworkImage(
                                      imageUrl: Config.Image_Path+'local_ad/${local_ad_string[0].AdImage}',
                                      fit: BoxFit.cover,

                                        placeholder: (context, url) =>Image.asset(
                                          "assets/images/loader.gif",
                                          width: 80,
                                          height: 80,


                                        ),
                                        errorWidget: (context, url, error) => Image.asset(
                                          "assets/images/loader.gif",
                                          width: 80,
                                          height: 80,


                                        )

                                    )

                                )


                              ],
                            ),
                          ),

                        ],
                        Divider(),
                        if(widget.FromMyPost==true)...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            child:    Row(
                              children: [

                                if(Status=='Pending Approval')...[
                                  Image.asset(
                                    'assets/images/PendingApproval.png',
                                    height: 16.0,
                                  )
                                ]
                                else if(Status=='Expired')...[
                                  Image.asset(
                                    'assets/images/Expired.png',
                                    height: 16.0,
                                  )
                                ]
                                else if(Status=='Approved')...[
                                    Image.asset(
                                      'assets/images/Approved.png',
                                      height: 16.0,
                                    )
                                  ]
                                  else if(Status=='Rejected')...[
                                      Image.asset(
                                        'assets/images/Rejected.png',
                                        height: 16.0,
                                      )
                                    ],
                              ],
                            ),
                          ),
                          if(EndDate!='01 Jan 1970')...[


                          Container(
                            padding: const EdgeInsets.all(8),
                            child:    Row(
                              children: [

                                Icon(
                                  Icons.calendar_month,
                                  color: Colors.grey,
                                  size: 16.0,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                 'Expires On : ${EndDate}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ],
            if(Status=='Approved')...[

                    Container(
                            padding: const EdgeInsets.all(8),
                            child:    Row(
                              children: [

                                Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.grey,
                                  size: 16.0,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  'Total Views:${TotalClicks}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ],

                          if(RejectionComment!='')...[
                            Container(
                                padding: const EdgeInsets.all(8),
                                child:Text('Rejection Reason: ${RejectionComment}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),))
                          ]


                        ]




                      ],
                    ),
                  )
              )
          )

      );
  }
  Future _refreshData() async {
    GetBlogData();
  }

  static void launchUrl(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}