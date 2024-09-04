import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/home_page.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State management
final loginTypeProvider = StateProvider<LoginType>((ref) => LoginType.user);

final isPasswordVisible = StateProvider<bool>((ref) => false);

enum LoginType { user, admin }

// SharedPreferences provider
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final bannerImageProvider = StateProvider<String>((ref) {
  return 'https://images.unsplash.com/photo-1623276527153-fa38c1616b05?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
});

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
    _loadSavedLoginInfo();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getBannerImage();
    });
  }

  String bannerImage =
      'https://images.unsplash.com/photo-1623276527153-fa38c1616b05?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
  getBannerImage() async {
    final dio = Dio();
    final response = await dio
        .get('https://api.mooxy.co.in/api/desktop/getBanners?type=LoginBanner');
    if (response.statusCode == 200) {
      // setState(() {
      //   bannerImage =
      //       AppStateProviders.prifixUrl + response.data['data']['bannerImage'];
      // });
      if (mounted) {
        ref.read(bannerImageProvider.notifier).state =
            AppStateProviders.prifixUrl + response.data['data']['bannerImage'];
      }
    }
  }

  loginUser(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error',
                style: TextStyle(color: Colors.red, fontSize: 24)),
            content: Text('Please enter email and password.',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        },
      );
      return;
    }
    try {
      final dio = Dio();
      if (ref.read(loginTypeProvider) == LoginType.admin) {
        final response =
            await dio.post('https://api.mooxy.co.in/api/adminLogIn', data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'hashKey': "ITZHASHKEY"
        });
        if (response.statusCode == 200) {
          _saveLoginInfo(emailController.text.trim(), LoginType.admin,
              response.data['data']['_id']);
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (context) => HomePage(),
          )); // Navigate to home screen
        }
      } else {
        final response = await dio
            .post('https://api.mooxy.co.in/api/logInWithPassword', data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'hashKey': "ITZHASHKEY"
        });
        if (response.statusCode == 200) {
          _saveLoginInfo(emailController.text.trim(), LoginType.user,
              response.data['data']['_id']);
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (context) => HomePage(),
          )); // Navigate to home screen
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title:
              Text('Error', style: TextStyle(color: Colors.red, fontSize: 24)),
          content: Text('Failed to login. Please try again.',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      );
    }
  }

  void _loadSavedLoginInfo() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final savedEmail = prefs.getString('email') ?? '';
    final savedLoginType = prefs.getString('loginType') ?? 'user';

    emailController.text = savedEmail;
    ref.read(loginTypeProvider.notifier).state =
        savedLoginType == 'admin' ? LoginType.admin : LoginType.user;
  }

  void _saveLoginInfo(String email, LoginType loginType, String userId) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('email', email);
    await prefs.setString('userId', userId);
    await prefs.setString(
        'loginType', loginType == LoginType.admin ? 'admin' : 'user');
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginType = ref.watch(loginTypeProvider);

    return Stack(children: [
      Scaffold(
        body: Row(
          children: [
            // Left side - Image
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.height,
              child: CachedNetworkImage(
                imageUrl: ref.watch(bannerImageProvider),
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            // Right side - Login form
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Radio buttons
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Radio<LoginType>(
                    //       value: LoginType.user,
                    //       groupValue: loginType,
                    //       onChanged: (value) => ref
                    //           .read(loginTypeProvider.notifier)
                    //           .state = value!,
                    //     ),
                    //     const Text('Student'),
                    //     const SizedBox(width: 16),
                    //     Radio<LoginType>(
                    //       value: LoginType.admin,
                    //       groupValue: loginType,
                    //       onChanged: (value) => ref
                    //           .read(loginTypeProvider.notifier)
                    //           .state = value!,
                    //     ),
                    //     const Text('Administrator'),
                    //   ],
                    // ),
                    const SizedBox(height: 16),
                    // Email field
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(150)),
                        ),
                      ),
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    TextField(
                      obscureText: ref.watch(isPasswordVisible) ? true : false,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                ref.read(isPasswordVisible.notifier).state =
                                    !ref.watch(isPasswordVisible);
                              });
                            },
                            icon: ref.watch(isPasswordVisible)
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(150)),
                        ),
                      ),
                      controller: passwordController,
                    ),
                    const SizedBox(height: 32),
                    // Login button
                    ElevatedButton(
                      onPressed: () {
                        loginUser(context);
                      },
                      child: Text('Login', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      WindowTitleBarBox(
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
            Container(
              // width: 200,
              height: double.infinity,
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  // color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(150)),
              child: Row(
                children: [
                  MinimizeWindowButton(
                    colors: WindowButtonColors(
                      iconNormal: Colors.white,
                      mouseOver: Colors.orangeAccent,
                      mouseDown: Colors.orange,
                    ),
                  ),
                  MaximizeWindowButton(
                    colors: WindowButtonColors(
                      iconNormal: Colors.white,
                      mouseOver: Colors.yellowAccent,
                      mouseDown: Colors.yellow,
                    ),
                  ),
                  CloseWindowButton(
                    colors: WindowButtonColors(
                      iconNormal: Colors.red,
                      mouseOver: Colors.redAccent,
                      mouseDown: Colors.red,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    ]);
  }
}
