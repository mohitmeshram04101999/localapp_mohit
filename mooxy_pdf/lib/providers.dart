import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateProviders {
  StateProvider<bool> isLeftSectionOpen= StateProvider((ref) => true,) ;
  static String prifixUrl='https://satyakabirbucket.ap-south-1.linodeobjects.com/';
}