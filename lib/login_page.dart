import 'dart:math';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:deck_royale_app/controller_passive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'controller.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GlobalKey<FormState> _formKey1;
  GlobalKey<FormState> _formKey2;
  TextEditingController _mailCtrl;
  TextEditingController _passwordCtrl;
  String mail;
  String pass;
  bool password;

  //Tabs
  TabController _tabController;

  //Login with link tab
  int button1;
  String message1;
  bool visible1;

  //Login with password tab
  int button2;
  String message2;
  bool visible2;

  @override
  void initState() {
    _formKey1 = GlobalKey<FormState>();
    _formKey2 = GlobalKey<FormState>();
    _mailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    button1 = LoadingButton.loginLink;
    button2 = LoadingButton.loginPass;
    message1 = 'hello';
    visible1 = false;
    message2 = 'hello';
    visible2 = false;
    password = true;
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(onTabChanged);
    super.initState();
  }

  @override
  void dispose() {
    _mailCtrl.dispose();
    _passwordCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: new BoxDecoration(image: DRColors.background,),
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 44, 0, 0),
            child: Stack(children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: TabBar(
                      tabs: [
                        Tab(
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 15 : 19,
                                color: Color(0xFFCCCCCC)),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Standard",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 15 : 19,
                                color: Color(0xFFCCCCCC)),
                          ),
                        ),
                      ],
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 46.0,
                        indicatorColor: Color(0x66222222),
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 144,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            firstTab(),
                            secondTab(),
                          ],
                        ),
                      ),
                    )
                  )
                ]
              ),
              Center(
                child: Hero(
                  tag: 'Splash',
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical:MediaQuery.of(context).size.height/10),
                    width: width / (MediaQuery.of(context).orientation == Orientation.portrait ? 1.5 : 3),
                    child: Image.asset(
                      'resources/images/splash.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ButtonTheme(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                            minWidth: MediaQuery.of(context).size.width / 4,
                            height: MediaQuery.of(context).size.height / 19,
                            child: RaisedButton(
                              elevation: 0.0,
                              onPressed: () {
                                HomeCtrl.me.setLogged();
                              },
                              color: Colors.transparent,
                              child: Text(
                                HomeCtrl.me.skip?'Skip login':'Exit',
                                style: TextStyle(color: DRColors.grey),
                              ),
                            ),
                          ),

                        ]
                    ),
                  ],
                ),
              )
            ]),
          ),
      ),
    );
  }

  Widget firstTab(){
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: DRColors.black2.withOpacity(0.6),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: DRColors.black2.withOpacity(0.4),
                width: 4,
              ),
            ),
            child: Column(
                  children: [
                    SizedBox(height: 30),
                    Center(
                        child: Text('Login',
                            style: TextStyle(
                                fontSize: 22,
                                color: DRColors.white.withOpacity(0.8)
                            )
                        )
                    ),
                    SizedBox(height: 8.0,),
                    Center(
                      child: Text("email address validation",
                          style: TextStyle(
                              fontSize: 12,
                              color: DRColors.white.withOpacity(0.6)
                          )
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    Form(
                      key: _formKey1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            readOnly: button1 != LoadingButton.loginLink,
                            cursorColor: DRColors.orange,
                            controller: _mailCtrl,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).orientation ==
                                  Orientation.portrait ? 15 : 18,
                              color: DRColors.orange,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20),
                              labelStyle: TextStyle(
                                fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait ? 15 : 18,
                                color: DRColors.grey,
                              ),
                              hintText: 'Email',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              suffixIcon: IconButton(
                                icon: Center(child: Icon(CupertinoIcons.mail)),
                                iconSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait ? 25 : 30,
                                color: DRColors.grey,
                                onPressed: () {},
                              ),
                              filled: true,
                              border: DRColors.formBorders,
                              disabledBorder: DRColors.formBorders,
                              errorBorder: DRColors.formBorders,
                              enabledBorder: DRColors.formBorders,
                              focusedBorder: DRColors.formBorders,
                              focusedErrorBorder: DRColors.formBorders,
                            ),
                          ),
                          SizedBox(height: 20),
                          FractionallySizedBox(
                            widthFactor: 0.6,
                            child: LoadingButton(
                              button: button1,
                              action: action1,
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 700),
                            opacity: (visible1)?1:0,
                            child: Text(
                              message1,
                              style: TextStyle(
                                fontSize: 14,
                                color: DRColors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0,),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget secondTab(){
    return Container(
      height: 340,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: DRColors.black2.withOpacity(0.6),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: DRColors.black2.withOpacity(0.4),
                width: 4,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: min(MediaQuery.of(context).size.height*0.03,30)),
                Center(
                  child: Text('Login',
                    style: TextStyle(
                      fontSize: 22,
                      color: DRColors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text("email and password",
                      style: TextStyle(
                          fontSize: 12,
                          color: DRColors.white.withOpacity(0.6)
                      )
                  ),
                ),
                SizedBox(height: min(MediaQuery.of(context).size.height*0.03,30)),
                Form(
                  key: _formKey2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        readOnly: button2 != LoadingButton.loginPass,
                        cursorColor: DRColors.orange,
                        controller: _mailCtrl,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait ? 15 : 18,
                          color: DRColors.orange,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal:20),
                          labelStyle: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait ? 15 : 18,
                            color: DRColors.grey,
                          ),
                          hintText: 'Email',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          suffixIcon: IconButton(
                            icon: Center(child: Icon(CupertinoIcons.mail)),
                            iconSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait ? 25 : 30,
                            color: DRColors.grey,
                            onPressed: () {},
                          ),
                          filled: true,
                          border: DRColors.formBorders,
                          disabledBorder: DRColors.formBorders,
                          errorBorder: DRColors.formBorders,
                          enabledBorder: DRColors.formBorders,
                          focusedBorder: DRColors.formBorders,
                          focusedErrorBorder: DRColors.formBorders,
                        ),
                      ),
                      SizedBox(height: min(MediaQuery.of(context).size.height*0.01,10)),
                      TextFormField(
                        obscureText: password,
                        keyboardType: TextInputType.text,
                        readOnly: button2 != LoadingButton.loginPass,
                        cursorColor: DRColors.orange,
                        controller: _passwordCtrl,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait ? 15 : 18,
                          color: DRColors.orange,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal:20,),
                          labelStyle: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait ? 15 : 18,
                            color: DRColors.grey,
                          ),
                          hintText: 'Password',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          suffixIcon: IconButton(
                            icon: Center(
                              child: AnimatedCrossFade(
                                duration: const Duration(milliseconds: 700),
                                firstChild: const Icon(CupertinoIcons.eye),
                                secondChild: const Icon(CupertinoIcons.eye_slash),
                                crossFadeState: !password ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              )
                            ),
                            iconSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait ? 25 : 30,
                            color: DRColors.grey,
                            onPressed: () {setState(() {password=!password;});},
                          ),
                          filled: true,
                          border: DRColors.formBorders,
                          disabledBorder: DRColors.formBorders,
                          errorBorder: DRColors.formBorders,
                          enabledBorder: DRColors.formBorders,
                          focusedBorder: DRColors.formBorders,
                          focusedErrorBorder: DRColors.formBorders,
                        ),
                      ),
                      SizedBox(height: min(MediaQuery.of(context).size.height*0.02,20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FlatButton(
                            height:14,
                            padding: const EdgeInsets.all(0),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 14,color: DRColors.orange,),
                            ),
                            onPressed: () {
                              Navigator.push( context, MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                              );
                            },
                          ),
                          LoadingButton(
                            button: button2,
                            action: action2,
                          ),
                        ],
                      ),
                      SizedBox(height: min(MediaQuery.of(context).size.height*0.01,10)),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 700),
                        opacity: (visible2)?1:0,
                        child: Text(
                          message2,
                          style: TextStyle(
                            fontSize: 14,
                            color: DRColors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: min(MediaQuery.of(context).size.height*0.02,20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onTabChanged(){
    _mailCtrl.clear();
    _passwordCtrl.clear();
    if(_tabController.index==1){
      button1 = LoadingButton.loginLink;
      message1 = 'hello';
      visible1 = false;
    }else{
      button2 = LoadingButton.loginPass;
      message2 = 'hello';
      visible2 = false;
    }
  }

  void action1(){
    if(button1==LoadingButton.loginLink){
      if (_mailCtrl.text.length>0) {
        mail = _mailCtrl.text;
        setState(() { button1=LoadingButton.loading; });
        loginWithLink();
      }else{
        showMessage1(LoadingButton.loginLink,'Email is required');
      }
    }else if(button1==LoadingButton.tryAgain){
      setState(() { button1=LoadingButton.loginLink; });
    }
  }

  void action2(){
    if(button2==LoadingButton.loginPass){
      if (_mailCtrl.text.length>0&&_passwordCtrl.text.length>0) {
        mail = _mailCtrl.text;
        pass = _passwordCtrl.text;
        setState(() { button2=LoadingButton.loading; });
        loginWithPassword();
      }else{
        showMessage2(LoadingButton.loginPass,'Email and password required');
      }
    }else if(button2==LoadingButton.tryAgain){
      setState(() { button2=LoadingButton.loginPass; });
    }
  }

  void showMessage1(int butt, String msg){
    setState(() {
      button1 = butt;
      visible1 = true;
      message1 = msg;
    });
    Future.delayed(const Duration(seconds: 5), () {
      setState(() { visible1 = false; });
    });
  }

  void showMessage2(int butt, String msg){
    setState(() {
      button2 = butt;
      visible2 = true;
      message2 = msg;
    });
    Future.delayed(const Duration(seconds: 5), () {
      setState(() { visible2 = false; });
    });
  }

  void loginWithPassword() async {
    FirebaseUser user;
    try {
      user = await InternetCtrl.signInWithEmailAndPassword(mail, pass);
      await AccountCtrl.me.loginFirebaseAccount(user.email, user.uid,
      isPasswordBased: true, isSignUpRequest: false);
      HomeCtrl.me.setLogged();
    } catch (e) {
      if(e.code=='ERROR_INVALID_EMAIL') {
        showMessage2(2,'Email address is malformed');
      }else if(e.code=='ERROR_WRONG_PASSWORD'){
        showMessage2(2,'Password is wrong');
      }else if(e.code=='ERROR_USER_NOT_FOUND'){
        showMessage2(2,'User not found');
      }else if(e.code=='ERROR_USER_DISABLED'){
        showMessage2(2,'User has been disabled');
      }else if(e.code=='ERROR_TOO_MANY_REQUESTS'){
        showMessage2(2,'Too many attempts');
      }else{
        showMessage2(2,'An error occurred, try again');
      }
      print(e.toString());
    }
  }

  void loginWithLink() async {
    try {
      await InternetCtrl.sendSignInWithEmailLink(mail);
      showMessage1(2, 'Check your mail inbox');
    } catch (e) {
      if(e.code=='ERROR_INVALID_EMAIL'){
        showMessage1(2,'Email address is malformed');
      }else{
        showMessage1(2, 'An error occurred, try again');
      }
      print(e.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      showMessage1(1, 'Checking info');
      final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
      if(data?.link != null) {
        handleLink(data?.link);
      }
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData dynamicLink) async {
            final Uri deepLink = dynamicLink?.link;
            handleLink(deepLink);
          },
          onError: (OnLinkErrorException e) async {
            print('onLinkError');
            print(e.toString());
            showMessage1(2, 'Authentication failed');
          }
        );
    }
  }

  void handleLink(Uri link) async {
    FirebaseUser user;
    try {
      if (await InternetCtrl.isLinkValid(link.toString())) {
        user = await InternetCtrl.signInWithEmailAndLink(mail,link.toString());
        await AccountCtrl.me.loginFirebaseAccount(user.email, user.uid);
        HomeCtrl.me.setLogged();
      }
    } on Exception catch (e) {
      print(e.toString());
      showMessage1(2,'Authentication failed, internal error');
      throw('Authentication failed, internal error');
    }
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> _formKey3;
  TextEditingController _mailCtrl;
  TextEditingController _passwordCtrl;
  String mail;
  String pass;
  bool password;
  int button;
  String message;
  bool visible;

  @override
  void initState() {
    _formKey3 = GlobalKey<FormState>();
    _mailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    button = LoadingButton.signUp;
    message = 'hello';
    visible = false;
    password = true;
    super.initState();
  }

  @override
  void dispose() {
    _mailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: new BoxDecoration(image: DRColors.background,),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 44, 0, 0),
          child: Stack(children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height:46,),
                  Flexible(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 144,
                        child: Container(
                        height: 300,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height/3 - 50),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: DRColors.black2.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: DRColors.black2.withOpacity(0.4),
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: min(MediaQuery.of(context).size.height*0.03,30)),
                                  Center(
                                      child: Text('Sign Up',
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: DRColors.white.withOpacity(0.8)
                                          )
                                      )
                                  ),
                                  SizedBox(height: 8.0,),
                                  Text("create a new account",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: DRColors.white.withOpacity(0.6))),
                                  SizedBox(height: min(MediaQuery.of(context).size.height*0.03,30)),
                                  Form(
                                    key: _formKey3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          keyboardType: TextInputType.emailAddress,
                                          readOnly: button != LoadingButton.signUp,
                                          cursorColor: DRColors.orange,
                                          controller: _mailCtrl,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).orientation ==
                                                Orientation.portrait ? 15 : 18,
                                            color: DRColors.orange,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal:20,),
                                            labelStyle: TextStyle(
                                              fontSize: MediaQuery.of(context).orientation ==
                                                  Orientation.portrait ? 15 : 18,
                                              color: DRColors.grey,
                                            ),
                                            hintText: 'Email',
                                            floatingLabelBehavior: FloatingLabelBehavior.never,
                                            suffixIcon: IconButton(
                                              icon: Center(child: Icon(CupertinoIcons.mail)),
                                              iconSize: MediaQuery.of(context).orientation ==
                                                  Orientation.portrait ? 25 : 30,
                                              color: DRColors.grey,
                                              onPressed: () {},
                                            ),
                                            filled: true,
                                            border: DRColors.formBorders,
                                            disabledBorder: DRColors.formBorders,
                                            errorBorder: DRColors.formBorders,
                                            enabledBorder: DRColors.formBorders,
                                            focusedBorder: DRColors.formBorders,
                                            focusedErrorBorder: DRColors.formBorders,
                                          ),
                                        ),
                                        SizedBox(height: min(MediaQuery.of(context).size.height*0.01,10)),
                                        TextFormField(
                                          obscureText: password,
                                          keyboardType: TextInputType.text,
                                          readOnly: button != LoadingButton.signUp,
                                          cursorColor: DRColors.orange,
                                          controller: _passwordCtrl,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).orientation ==
                                                Orientation.portrait ? 15 : 18,
                                            color: DRColors.orange,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal:20,),
                                            labelStyle: TextStyle(
                                              fontSize: MediaQuery.of(context).orientation ==
                                                  Orientation.portrait ? 15 : 18,
                                              color: DRColors.grey,
                                            ),
                                            hintText: 'Password',
                                            floatingLabelBehavior: FloatingLabelBehavior.never,
                                            suffixIcon: IconButton(
                                              icon: Center(
                                                  child: AnimatedCrossFade(
                                                    duration: const Duration(milliseconds: 700),
                                                    firstChild: const Icon(CupertinoIcons.eye),
                                                    secondChild: const Icon(CupertinoIcons.eye_slash),
                                                    crossFadeState: !password ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                                  )
                                              ),
                                              iconSize: MediaQuery.of(context).orientation ==
                                                  Orientation.portrait ? 25 : 30,
                                              color: DRColors.grey,
                                              onPressed: () {setState(() {password=!password;});},
                                            ),
                                            filled: true,
                                            border: DRColors.formBorders,
                                            disabledBorder: DRColors.formBorders,
                                            errorBorder: DRColors.formBorders,
                                            enabledBorder: DRColors.formBorders,
                                            focusedBorder: DRColors.formBorders,
                                            focusedErrorBorder: DRColors.formBorders,
                                          ),
                                        ),
                                        SizedBox(height: min(MediaQuery.of(context).size.height*0.02,20)),
                                        FractionallySizedBox(
                                          widthFactor: 0.6,
                                          child: LoadingButton(
                                            button: button,
                                            action: action,
                                          ),
                                        ),
                                        SizedBox(height: min(MediaQuery.of(context).size.height*0.01,10)),
                                        AnimatedOpacity(
                                          duration: const Duration(milliseconds: 700),
                                          opacity: (visible)?1:0,
                                          child: Text(
                                            message,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: DRColors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: min(MediaQuery.of(context).size.height*0.02,20)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      )
                  )
                ]
            ),
            Center(
              child: Hero(
                tag: 'Splash',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical:MediaQuery.of(context).size.height/10),
                  width: width / (MediaQuery.of(context).orientation == Orientation.portrait ? 1.5 : 3),
                  child: Image.asset(
                    'resources/images/splash.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonTheme(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                          minWidth: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.height / 19,
                          child: RaisedButton(
                            elevation: 0.0,
                            onPressed: () {Navigator.maybePop(context);},
                            color: Colors.transparent,
                            child: Text(
                              'Back',
                              style: TextStyle(color: DRColors.grey),
                            ),
                          ),
                        ),

                      ]
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  void action(){
    if(button==LoadingButton.signUp){
      if (_mailCtrl.text.length>0&&_passwordCtrl.text.length>0) {
        mail = _mailCtrl.text;
        pass = _passwordCtrl.text;
        setState(() { button=LoadingButton.loading; });
        signUp();
      }else{
        showMessage(LoadingButton.signUp,'Email and password required');
      }
    }else if(button==LoadingButton.tryAgain){
      setState(() { button=LoadingButton.signUp; });
    }
  }

  void showMessage(int butt, String msg){
    setState(() {
      button = butt;
      visible = true;
      message = msg;
    });
    Future.delayed(const Duration(seconds: 5), () {
      setState(() { visible = false; });
    });
  }

  void signUp() async {
    FirebaseUser user;
    try {
      user = await InternetCtrl.createUserWithEmailAndPassword(mail, pass);
      await AccountCtrl.me.loginFirebaseAccount(user.email, user.uid,
          isPasswordBased: true, isSignUpRequest: true);
      HomeCtrl.me.setLogged();
      showMessage(LoadingButton.done,'You are correctly registered');
    } catch (e) {
      if(e.code=='ERROR_WEAK_PASSWORD') {
        showMessage(2,'Password is too weak');
      }else if(e.code=='ERROR_INVALID_EMAIL'){
        showMessage(2,'Email address is malformed');
      }else if(e.code=='ERROR_EMAIL_ALREADY_IN_USE'){
        showMessage(2,'Email already in use by an account');
      }else{
        showMessage(2,'An error occurred, try again');
      }
      print(e.toString());
    }
  }
}


class LoadingButton extends StatelessWidget {
  static const int loginLink = 0;
  static const int loading = 1;
  static const int tryAgain = 2;
  static const int loginPass = 3;
  static const int signUp = 4;
  static const int done = 5;
  static final List<String> msg = const ['Send mail','loading','Try again','Login','Sign Up','Done'];

  final int button;
  final Function action;
  LoadingButton({this.button,this.action});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = button==LoadingButton.loading;
    final Color color =
    (button==LoadingButton.tryAgain||button==LoadingButton.done)?
    DRColors.blue:DRColors.orange;

    return ButtonTheme(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))
      ),
      minWidth: MediaQuery.of(context).size.width / 2 - 24,
      height: MediaQuery.of(context).size.height / 20,
      child: button!=LoadingButton.done?Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          height: MediaQuery.of(context).size.height / 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: color.withOpacity(0.6),
              width: 4,
            ),
          ),
          child: !isLoading?
          RaisedButton(
            elevation: 0.0,
            onPressed: () { action(); },
            color: color,
            child: Text(
              LoadingButton.msg[button],
              style: TextStyle(
                color: color==DRColors.orange?DRColors.black2:DRColors.white,
                fontSize: 16,
              ),
            ),
          ):
          RaisedButton(
            elevation: 0.0,
            onPressed: () {},
            color: DRColors.orange,
            child: SizedBox(
              height: 17,
              width: 17,
              child: CircularProgressIndicator(
                backgroundColor: DRColors.black,
                strokeWidth: 3,
              ),
            ),
          )
      ):Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          height: MediaQuery.of(context).size.height / 15,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.transparent,
              width: 4,
            ),
          ),
          child: RaisedButton(
            elevation: 0.0,
            onPressed: () { action(); },
            color: Colors.transparent,
            child: Text(
              LoadingButton.msg[button],
              style: TextStyle(
                color: color==DRColors.orange?DRColors.black2:DRColors.white,
                fontSize: 16,
              ),
            ),
          ),
      ),
    );
  }
}

