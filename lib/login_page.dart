import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SMIInput<double>? _numLook;
  SMIInput<bool>? _isChecking;
  SMIInput<bool>? _isHandsUp;
  SMIInput<bool>? _trigSuccess;
  SMIInput<bool>? _trigFail;

  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  String validEmail = "winko@rive.com";
  String validPassword = "12345678";

  StateMachineController? stateMachineController;

  FocusNode emailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isShowingPassword = false;
  bool _isLoading = false;
  bool _isLoginSuccess = false;

  void emailFocus() {
    _isChecking?.change(emailFocusNode.hasFocus);
  }

  @override
  void initState() {
    emailFocusNode.addListener(emailFocus);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E2EA),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Rive\nReactive Animations",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            _buildReactiveAnimation(),
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(emailFocus);
    stateMachineController!.dispose();
    _emailTEC.dispose();
    _passwordTEC.dispose();
    super.dispose();
  }

  _buildReactiveAnimation() {
    return SizedBox(
      height: 280,
      child: RiveAnimation.asset(
        "assets/animations/polar.riv",
        onInit: (artBoard) {
          for (var element in artBoard.stateMachines) {
            print(element.name);
          }
          stateMachineController =
              StateMachineController.fromArtboard(artBoard, "State Machine 1");

          if (stateMachineController == null) return;

          for (var element in stateMachineController!.inputs) {
            print(element.name);
          }

          try {
            artBoard.addController(stateMachineController!);

            _isChecking = stateMachineController?.findInput("Check");
            _numLook = stateMachineController?.findInput("Look");

            _isHandsUp = stateMachineController?.findInput("hands_up");
            _trigSuccess = stateMachineController?.findInput("success");
            _trigFail = stateMachineController?.findInput("fail");
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        },
      ),
    );
  }

  _buildLoginForm() {
    return Card(
      margin: EdgeInsets.zero,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
          child: Column(
            children: [
              TextFormField(
                focusNode: emailFocusNode,
                controller: _emailTEC,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  hintText: "Email",
                ),
                validator: (value) => EmailValidator.validate(value ?? "")
                    ? null
                    : "Please enter a valid email",
                onChanged: (value) {
                  _isHandsUp!.change(false);
                  _numLook?.change(value.length.toDouble());
                },
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: _passwordTEC,
                obscureText: !_isShowingPassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 8) {
                    return 'Password must be more than 7 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _isShowingPassword = !_isShowingPassword;
                      });
                    },
                    child: Icon(_isShowingPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  hintText: "Password",
                ),
                onChanged: (value) {
                  _isHandsUp!.change(false);
                },
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 56,
                width: (_isLoading || _isLoginSuccess) ? 56 : double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: (_isLoading || _isLoginSuccess)
                            ? EdgeInsets.zero
                            : null,
                        backgroundColor:
                            _isLoginSuccess ? Colors.green : Colors.blueAccent,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      emailFocusNode.unfocus();
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            _isLoading = false;
                          });

                          if (_emailTEC.text == validEmail &&
                              _passwordTEC.text == validPassword) {
                            setState(() {
                              _isLoginSuccess = true;
                            });

                            _trigSuccess?.change(true);

                            Future.delayed(const Duration(seconds: 3), () {
                              setState(() {
                                _isLoginSuccess = false;
                              });

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ));
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid email and password'),
                                    backgroundColor: Colors.redAccent));

                            _trigFail?.change(true);
                          }
                        });
                      } else {
                        _isHandsUp!.change(true);
                      }
                    },
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _isLoginSuccess
                            ? const Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Icon(Icons.check),
                                ),
                              )
                            : const Text("Login")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
