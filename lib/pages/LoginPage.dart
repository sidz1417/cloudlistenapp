import 'package:cloudlisten/providers/AuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { login, signUp }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Map<String, dynamic> _formData = {
    "email": null,
    "password": null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _passwordTextController = TextEditingController();
  AuthMode _mode = AuthMode.login;

  _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).accentColor)),
        labelText: "Enter E-mail",
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String email){
        if(email.isEmpty) return 'Email cannot be blank';
      },
      onSaved: (String value) {
        _formData["email"] = value;
      },
    );
  }

  _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).accentColor)),
        labelText: "Confirm password",
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
      ),
      obscureText: true,
      onSaved: (String value) {
        _formData["password"] = value;
      },
      validator: (String value) {
        if (_passwordTextController.text != value)
          return 'Passwords do not match';
      },
    );
  }

  _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).accentColor)),
        labelText: "Enter Password",
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
      ),
      obscureText: true,
      onSaved: (String value) {
        _formData["password"] = value;
      },
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6)
          return "Minimum password length is 6";
      },
    );
  }

  _submitForm(
      {@required BuildContext context, @required AuthService authService}) {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    if (_mode == AuthMode.login) {
      authService.signIn(
          email: _formData['email'],
          password: _formData['password'],
          context: context);
      _formKey.currentState.reset();
    } else {
      authService.signUp(
          email: _formData['email'],
          password: _formData['password'],
          context: context);
      _formKey.currentState.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cloud Upload'),
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Container(
                height: 400,
                width: 300,
                child: Consumer<AuthService>(
                  builder: (BuildContext context, AuthService authService,
                      Widget child) {
                    if (authService.loadingStatus)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildEmailTextField(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        ),
                        _buildPasswordTextField(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        ),
                        (_mode == AuthMode.signUp)
                            ? _buildPasswordConfirmTextField()
                            : Container(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        ),
                        RaisedButton(
                            color: Theme.of(context).accentColor,
                            child: Text(
                              '${_mode == AuthMode.login ? 'Login' : 'Signup'}',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              _submitForm(
                                  context: context, authService: authService);
                            }),
                        RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Switch to ${_mode == AuthMode.login ? 'Signup' : 'Login'}',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _mode = _mode == AuthMode.login
                                  ? AuthMode.signUp
                                  : AuthMode.login;
                            });
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
