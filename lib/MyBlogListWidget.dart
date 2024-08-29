
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'BlogDetail.dart';
import 'constants/Config.dart';
import 'models/BlogList.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

class MyBlogListWidget extends StatefulWidget {
  @override
  _MyBlogListWidgetState createState() => _MyBlogListWidgetState();
  final Blog_list blog;
  String selected_category;
  String selected_sub_category;

  MyBlogListWidget(this.blog,this.selected_category,this.selected_sub_category);

}


class _MyBlogListWidgetState extends State<MyBlogListWidget> {


  bool showShimmer = true; // Track whether to show shimmer or data
  final Duration shimmerDuration = Duration(seconds: 2);
  late YoutubePlayerController _controller=YoutubePlayerController(
    initialVideoId: '',
    flags: YoutubePlayerFlags(
        autoPlay: false,
        controlsVisibleAtStart: true
    ),
  );
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Start a timer to hide the shimmer after 2 seconds
    Timer(shimmerDuration, () {
      if (mounted) {
        setState(() {
          showShimmer = false;
        });
      }
    });

  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(widget.blog.videoLink!='')
    {
      String  videoId = YoutubePlayer.convertUrlToId("${widget.blog.videoLink}")!;
      _controller = YoutubePlayerController(
        initialVideoId: '${videoId}',
        flags: YoutubePlayerFlags(
            autoPlay: false,
            controlsVisibleAtStart: true
        ),
      );

    }

    // Your widget implementation for displaying a single blog item
    return  GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailScreen(
              widget.blog.blogPostId??"0",
              '${widget.selected_category}',
              '${widget.selected_sub_category}',true,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              if (widget.blog.videoLink!= '') ...[
                YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                ),
                // Add your video rendering here...
              ] else ...[
                if (widget.blog.postDisplayPhoto != '') ...[
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
                      : CachedNetworkImage(
                    imageUrl: Config.Image_Path + 'blog/${widget.blog.postDisplayPhoto??""}',
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
                ],
              ],
              SizedBox(height: 20),

              showShimmer?
              Column(
                children: [
                  SizedBox(height: 20),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      color: Colors.white,
                    ),
                  )
                ],
              ):

                  Text("${widget.blog.text}"),
              // Html(
              //   data: widget.blog.heading!=''?widget.blog.heading:widget.blog.text,
              //   style: {
              //     "body": Style(
              //       padding: EdgeInsets.zero,
              //       margin: EdgeInsets.all(0),
              //     ),
              //   },
              // ),

              showShimmer?
              Column(
                children: [
                  SizedBox(height: 10),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity/2,
                      height: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ):
              Container(
                padding: const EdgeInsets.all(8),
                child:    Row(
                  children: [

                    Text(
                     "${widget.blog.subCategoryName??""}",

                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              showShimmer?
              Column(
                children: [
                  SizedBox(height: 10),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity/3,
                      height: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ):
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
                      widget.blog.timeAgo??"",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Spacer(),
                    if(widget.blog.status=='Pending Approval')...[
                      Image.asset(
                        'assets/images/PendingApproval.png',
                        height: 16.0,
                      )
                    ]
                    else if(widget.blog.status=='Expired')...[
                      Image.asset(
                        'assets/images/Expired.png',
                        height: 16.0,
                      )
                    ]
                    else if(widget.blog.status=='Approved')...[
                        Image.asset(
                          'assets/images/Approved.png',
                          height: 16.0,
                        )
                      ]
                      else if(widget.blog.status=='Rejected')...[
                          Image.asset(
                            'assets/images/Rejected.png',
                            height: 16.0,
                          )
                        ],
                  ],
                ),
              ),
              if(widget.blog.rejectionComment!='')...[
    Container(
    padding: const EdgeInsets.all(8),
    child:Text('Rejection Reason: ${widget.blog.rejectionComment}',
    style: TextStyle(
    color: Colors.red,
      fontSize: 13,
    ),))
              ]

            ],
          ),
        ),
      ),
    );
  }
}
