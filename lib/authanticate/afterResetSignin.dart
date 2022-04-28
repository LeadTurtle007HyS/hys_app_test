import 'package:flutter/material.dart';
import 'package:hys/services/auth.dart';

//This page is for to sign in again after reset your password

class AfterSignIn extends StatefulWidget {
  @override
  _AfterSignInState createState() => _AfterSignInState();
}

class _AfterSignInState extends State<AfterSignIn> {
  bool _obsecuretext = true;

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  String validate = '';
  String validatepass = '';
  int count = 0;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var scrWidth = MediaQuery.of(context).size.width;
    var scrHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0, top: 40),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 35,
                              color: Color(0xff0C2551),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          //
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40, top: 5),
                          child: Text(
                            'Sign In with\nnew updated password',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      //
                      SizedBox(
                        height: 60,
                      ),
                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(left: 30, right: 30, bottom: 4),
                            child: Container(
                              child: Text(
                                'Email ID',
                                style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontSize: 15,
                                  color: Color(0xff8f9db5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Color(0xff0962ff),
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff0962ff),
                              fontWeight: FontWeight.bold),
                          validator: (val) => ((val.isEmpty))
                              ? 'Enter Email ID correctly'
                              : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            counterText: '',
                            hintText: 'Enter Email ID',
                            hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[350],
                                fontWeight: FontWeight.w600),
                            alignLabelWithHint: false,
                            contentPadding: new EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            errorStyle: TextStyle(
                                color: Color.fromRGBO(240, 20, 41, 1)),
                            focusColor: Color(0xff0962ff),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xff0962ff)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[350],
                              ),
                            ),
                          ),
                        ),
                      ),
                      //
                      SizedBox(
                        height: 15,
                      ),
                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(left: 30, right: 30, bottom: 4),
                            child: Container(
                              child: Text(
                                'Password',
                                style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontSize: 15,
                                  color: Color(0xff8f9db5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xff0962ff),
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff0962ff),
                              fontWeight: FontWeight.bold),
                          obscureText: _obsecuretext,
                          validator: (val) {
                            return val.length < 6
                                ? 'Enter a password 6+ chars long'
                                : null;
                          },
                          onChanged: (val) {
                            setState(() => password = val);
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                color: Color(0xff0962ff),
                                icon: Icon(_obsecuretext
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _obsecuretext = !_obsecuretext;
                                  });
                                }),
                            fillColor: Colors.white,
                            filled: true,
                            counterText: '',
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[350],
                                fontWeight: FontWeight.w600),
                            alignLabelWithHint: false,
                            contentPadding: new EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            errorStyle: TextStyle(
                                color: Color.fromRGBO(240, 20, 41, 1)),
                            focusColor: Color(0xff0962ff),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xff0962ff)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[350],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      //

                      InkWell(
                        onTap: loading == false
                            ? () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  //function called to check user is exist or not if yes then the credentials are correct or not
                                  //function is in services/auth.dart file
                                  dynamic result = await _auth.signIn(
                                    email,
                                    password,
                                  );
                                  if (result == "Signed in") {
                                    setState(() {
                                      loading = false;
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                      _showAlertDialog(result);
                                    });
                                  }
                                }
                              }
                            : null,
                        child: Container(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(88, 165, 196, 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: loading == false
                                ? Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontFamily: 'ProductSans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  )
                                : Container(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                ClipPath(
                  clipper: OuterClippedPart(),
                  child: Container(
                    color: Color.fromRGBO(209, 228, 235, 1),
                    width: scrWidth,
                    height: scrHeight,
                  ),
                ),
                //
                ClipPath(
                  clipper: InnerClippedPart(),
                  child: Container(
                    color: Color.fromRGBO(88, 165, 196, 1),
                    width: scrWidth,
                    height: scrHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(String message) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Product Sans',
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w400,
          fontFamily: 'Product Sans',
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class Neu_button extends StatelessWidget {
  Neu_button({this.char});
  String char;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            offset: Offset(12, 11),
            blurRadius: 26,
            color: Color(0xffaaaaaa).withOpacity(0.1),
          )
        ],
      ),
      //
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 29,
            fontWeight: FontWeight.bold,
            color: Color(0xff0962FF),
          ),
        ),
      ),
    );
  }
}

class OuterClippedPart extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    //
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height / 4);
    //
    path.cubicTo(size.width * 0.55, size.height * 0.16, size.width * 0.85,
        size.height * 0.05, size.width / 2, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class InnerClippedPart extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    //
    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.1);
    //
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.11, size.width * 0.7, 0);

    //
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
