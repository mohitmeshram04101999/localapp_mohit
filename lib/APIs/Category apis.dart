import 'package:http/http.dart' as http;
import 'package:localapp/constants/Config.dart';


class CategoryApi
{

  Future<http.Response> getSubSubCategory(String categoryID)async
  {
    String uri = Config.get_subSub_Categoey;

    var resp = await http.post(Uri.parse(uri),body: {"subcategory_id":categoryID});

    return resp;
  }

}