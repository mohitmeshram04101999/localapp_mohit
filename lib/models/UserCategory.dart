class User_Category_list{

  String CategoryId='';
  String CategoryName='';
  String CategoryImage='';
  String WhatsappMessage='';
  String WhatsappNumber='';
  String  status='';
  List<User_Category_list> data=[];

  User_Category_list({
    required this.CategoryId,
    required this.CategoryName,
    required this.CategoryImage,
    required this.WhatsappMessage,
    required this.WhatsappNumber
  });

  factory User_Category_list.fromJson(Map<String, dynamic> json) {
    return User_Category_list(
      CategoryId: json['CategoryId'] as String,
      CategoryName: json['CategoryName'] as String,
      CategoryImage: json['CategoryImage']==null?'':json['CategoryImage'] as String,
      WhatsappMessage:json['WhatsappMessage']==null?'':json['WhatsappMessage'] as String,
      WhatsappNumber:json['WhatsappNumber']==null?'':json['WhatsappNumber'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }
}



