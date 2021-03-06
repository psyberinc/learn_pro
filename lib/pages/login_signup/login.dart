import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learn_pro/appTheme/appTheme.dart';
import 'package:learn_pro/pages/home/home.dart';
import 'package:learn_pro/pages/login_signup/forgot_password.dart';
import 'package:learn_pro/pages/login_signup/signup.dart';
import 'package:learn_pro/services/networkHandler.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //Timer
  Timer _timer;
  int _timeOut = 5;
  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_timeOut < 1) {
        timer.cancel();
        setState(() {
          circular = false;
        });
        Fluttertoast.showToast(
          msg: 'Email or Password incorrect',
          backgroundColor: Colors.black,
          textColor: Theme.of(context).appBarTheme.color,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //for email validation
  RegExp emailReg =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+");
  bool circular = false;
  NetworkHandler networkHandler = NetworkHandler();
  //Controllers for validation
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  //Formkey for validation
  final loginFormKey = GlobalKey<FormState>();
  // Initially password is obscure
  bool _obscureText = true;
  DateTime currentBackPressTime;

  // Toggles the password show status
  void _viewPassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    nestedAppBar() {
      return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.all(20.0),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/appbar_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontFamily: 'Signika Negative',
                      fontWeight: FontWeight.w700,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
            ),
          ];
        },
        body: ListView(
          children: <Widget>[
            SizedBox(height: 30.0),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 30.0, left: 30.0),
              child: Form(
                key: loginFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      validator: (String val) {
                        if (val.isEmpty) {
                          return "field can't be empty";
                        } else if (!emailReg.hasMatch(val)) {
                          return "Enter Valid Email Adderess";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          fontFamily: 'Signika Negative',
                          color: Colors.grey[500],
                        ),
                        contentPadding:
                            const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: _passwordController,
                      validator: (String val) {
                        if (val.isEmpty) {
                          return "field can't be empty";
                        } else if (val.length < 6) {
                          return "password should have at least six characters";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontFamily: 'Signika Negative',
                          color: Colors.grey[500],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: _viewPassword,
                        ),
                        contentPadding:
                            const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      ),
                      obscureText: _obscureText,
                    ),
                    SizedBox(height: 40.0),
                    InkWell(
                      onTap: () async {
                        _startTimer();
                        Map<String, String> data = {
                          "email": _emailController.text,
                          "password": _passwordController.text
                        };
                        if (loginFormKey.currentState.validate()) {
                          setState(() {
                            circular = true;
                          });
                          var responseLogin =
                              await networkHandler.post("/login", data);
                          Map<String, dynamic> loginOutput =
                              json.decode(responseLogin.body);
                          print(loginOutput);
                          if (responseLogin.statusCode == 200 ||
                              responseLogin.statusCode == 201) {
                            final pref = await SharedPreferences.getInstance();
                            await pref.setString("id", loginOutput["_id"]);
                            await pref.setString(
                                "email", _emailController.text);
                            await pref.setString(
                                "password", _passwordController.text);
                            setState(() {
                              circular = false;
                            });
                            Fluttertoast.showToast(
                              msg: 'Logged In',
                              backgroundColor: Colors.black,
                              textColor: Theme.of(context).appBarTheme.color,
                            );
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: Home(),
                              ),
                            );
                          } else {
                            // setState(() {
                            //   circular = false;
                            // });
                            // Fluttertoast.showToast(
                            //   msg: 'Email or Password incorrect',
                            //   backgroundColor: Colors.black,
                            //   textColor: Theme.of(context).appBarTheme.color,
                            // );
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: textColor,
                        ),
                        child: circular
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'Sign in',
                                style: TextStyle(
                                  fontFamily: 'Signika Negative',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: SignUp()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontFamily: 'Signika Negative',
                            fontSize: 17.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: ForgotPassword()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontFamily: 'Signika Negative',
                            fontSize: 17.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: 30.0),
                    // InkWell(
                    //   onTap: () {},
                    //   child: Container(
                    //     padding: EdgeInsets.all(15.0),
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(5.0),
                    //       color: fbBgColor,
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: <Widget>[
                    //         Image.asset(
                    //           'assets/facebook.png',
                    //           height: 25.0,
                    //           fit: BoxFit.fitHeight,
                    //         ),
                    //         SizedBox(width: 10.0),
                    //         Text(
                    //           'Log in with Facebook',
                    //           style: TextStyle(
                    //             fontFamily: 'Signika Negative',
                    //             fontSize: 18.0,
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 20.0),
                    // InkWell(
                    //   onTap: () {},
                    //   child: Container(
                    //     padding: EdgeInsets.all(15.0),
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(5.0),
                    //       color: Colors.white,
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: <Widget>[
                    //         Image.asset(
                    //           'assets/google.png',
                    //           height: 25.0,
                    //           fit: BoxFit.fitHeight,
                    //         ),
                    //         SizedBox(width: 10.0),
                    //         Text(
                    //           'Log in with Google',
                    //           style: TextStyle(
                    //             fontFamily: 'Signika Negative',
                    //             fontSize: 18.0,
                    //             color: Colors.grey[500],
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: WillPopScope(
        child: nestedAppBar(),
        onWillPop: onWillPop,
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press Back Once Again to Exit.',
        backgroundColor: Colors.black,
        textColor: Theme.of(context).appBarTheme.color,
      );
      return Future.value(false);
    }
    exit(0);
    return Future.value(true);
  }
}
