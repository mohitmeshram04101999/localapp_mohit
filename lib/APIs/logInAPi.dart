import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class LogApis{
  final _log = Logger();



  Future<http.Response> getUser(String deviceId) async
  {
    String uri = "https://localapp.satyakabir.in/api/get_user";

    var resp = await http.post(Uri.parse(uri),body: {"PostById":deviceId});

    return resp;
  }


  Future<http.Response> updateProfile({
    String? postById,
    String? name,
    String? mobileNumber1,
}) async
  {

    String uri = "https://localapp.satyakabir.in/api/update_profile";

    var _data = {
      "PostById":postById,
      "Name":name,
      "MobileNumber1":mobileNumber1,
    };

    Map _filterData = {};

    _data.forEach((key, value) {
      if(value!=null)
        {
          _filterData[key]=value;
        }
    });

    var resp = await http.post(Uri.parse(uri),body: _filterData);

    return resp;

  }

}