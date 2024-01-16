import 'package:chat_app/Services/navigation_service.dart';
import 'package:chat_app/widgets/rounded_image.dart';
import 'package:flutter/material.dart';

//packages
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//services
import '../Services/media_service.dart';
import '../Services/database_service.dart';
import '../Services/cloud_storage_service.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//provider
import '../provider/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? _name;
  String? _email;
  String? _password;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorageService;
  late NavigationService _navigationService;

  PlatformFile? profileImage;
  final _registeFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _auth=Provider.of<AuthenticationProvider>(context);
    _db=GetIt.instance.get<DatabaseService>();
    _cloudStorageService=GetIt.instance.get<CloudStorageService>();
    _navigationService=GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileImageField(),
            SizedBox(
              height: _deviceHeight * 0.05,
            ),
            _registerForm(),
            SizedBox(
              height: _deviceHeight * 0.04,
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
          (_file) {
            setState(
              () {
                profileImage = _file;
              },
            );
          },
        );
      },
      child: () {
        if (profileImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            image: profileImage!,
            size: _deviceHeight * 0.15,
          );
        } else {
          return RoundedImageNetwork(
            key: UniqueKey(),
            imagePath: "https://i.pravatar.cc/150?img=65",
            size: _deviceHeight * 0.15,
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registeFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _name = _value;
                  });
                },
                regEX: r'.{8,}',
                hintText: "Name",
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _email = _value;
                  });
                },
                regEX:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Email",
                obscureText: false),
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _password = _value;
                });
              },
              regEX: r".{8,}",
              hintText: "Password",
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.075,
      width: _deviceWidth * 0.79,
      onPressed: () async{

        if(_registeFormKey.currentState!.validate() && profileImage !=null)
          {
              _registeFormKey.currentState!.save();

              String? _uid=await _auth.registerUserUsingEmailAndPassword(_email!, _password!);
              String? _imageURL=await _cloudStorageService.saveUserImageToStorage(_uid!, profileImage!);
              await _db.createUser(_uid, _email!, _name!, _imageURL!);
              await _auth.logOut();
              await _auth.loginUsingEmailAndPassword(_email!, _password!);
              //_navigationService.goBack();
          }
      },
    );
  }
}
