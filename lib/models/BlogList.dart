class Blog_list{

  String BlogPostId='';
  String Heading='';
  String Text='';
  String PostDisplayPhoto='';
  String  Status='';
  String TimeAgo='';
  String SubCategoryName='';
  String CategoryName='';
  String VideoLink;
  String ContactDetail='';
  String TotalClicks='';
  String RejectionComment='';

  List<Blog_list> data=[];

  Blog_list({
    required this.BlogPostId,
    required this.Heading,
    required this.Text,
    required this.PostDisplayPhoto,
    required this.TimeAgo,
    required this.SubCategoryName,
    required this.VideoLink,
    required this.CategoryName,
    required this.ContactDetail,
    required this.Status,
    required this.TotalClicks,
    required this.RejectionComment

  });

  factory Blog_list.fromJson(Map<String, dynamic> json) {
    return Blog_list(
      BlogPostId: json['BlogPostId'] as String,
      Heading: json['Heading']==null?'': json['Heading'] as String,
      Text:  json['Text']==null?'': json['Text'] as String,
      PostDisplayPhoto: json['PostDisplayPhoto']==null?'': json['PostDisplayPhoto'] as String,
      TimeAgo: json['TimeAgo']==null?'': json['TimeAgo'] as String,
      SubCategoryName: json['SubCategoryName']==null?'': json['SubCategoryName'] as String,
      VideoLink: json['VideoLink']==null?'': json['VideoLink'] as String,
      CategoryName: json['CategoryName']==null?'': json['CategoryName'] as String,
      ContactDetail: json['ContactDetail']==null?'': json['ContactDetail'] as String,
      Status: json['Status']==null?'': json['Status'] as String,
      TotalClicks: json['TotalClicks']==null?'': json['TotalClicks'] as String,
      RejectionComment: json['RejectionComment']==null?'': json['RejectionComment'] as String,



    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }
}



