import 'package:chat_app/provider/chat_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/custom_input_fields.dart';
import '../models/chat_message.dart';
import '../models/chat.dart';
import '../provider/chats_page_provider.dart';
import '../provider/authentication_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  ChatPage({required this.chat});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late ChatPageProvider _pageProvider;
  late AuthenticationProvider _auth;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messageListViewController;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messageListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
              this.widget.chat.uid, _auth, _messageListViewController),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<ChatPageProvider>();
      return Scaffold(
        body: Stack(
          children: [
            Container(
              height: _deviceHeight,
              width: _deviceWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.02),
                height: _deviceHeight,
                width: _deviceWidth * 0.97,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TopBar(
                      fontSize: 12,
                      this.widget.chat.title(),
                      primaryAction: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromRGBO(0, 82, 218, 1.0),
                        ),
                        onPressed: () {
                          _pageProvider.deleteChat();
                        },
                      ),
                      secondAction: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Color.fromRGBO(0, 82, 218, 1.0),
                        ),
                        onPressed: () {
                          _pageProvider.goBack();
                        },
                      ),
                    ),
                    _messagesListView(),
                    _sendMessageForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.length != 0) {
        return Container(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            controller: _messageListViewController,
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext _context, int _index) {
              ChatMessage _message = _pageProvider.messages![_index];
              bool _isOwnMessge = _message.senderID == _auth.user.uid;
              return Container(
                child: CustomChatListViewTile(
                  width: _deviceWidth * 0.80,
                  deviceHeight: _deviceHeight,
                  isOwnMessage: _isOwnMessge,
                  message: _message,
                  sender: this
                      .widget
                      .chat
                      .members
                      .where((_m) => _m.uid == _message.senderID)
                      .first,
                ),
              );
            },
          ),
        );
      } else {
        return Align(
          alignment: Alignment.center,
          child: Text(
            "Be the first to say Hi!",
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
  }

  Widget _sendMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _sentMessageButton(),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.60,
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        focusNode: _focusNode,
        onSaved: (_value) {
          _pageProvider.message = _value!;
        },
        cursorColor: Colors.white,
        style: TextStyle(
          color: Colors.white,
        ),
        obscureText: false,
        validator: (value) {
          return RegExp(r'^(?!\s*$).+').hasMatch(value!)
              ? null
              : 'Enter Valid value';
        },
        decoration: InputDecoration(
          fillColor: Color.fromRGBO(30, 29, 37, 1.0),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          hintText: "Type a message",
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _sentMessageButton() {
    double _size = _deviceHeight * 0.05;

    return Container(
      width: _size,
      height: _size,
      child: IconButton(
        onPressed: () {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save();
            _pageProvider.sendTextMessage();
            _focusNode.unfocus();
            _messageFormState.currentState!.reset();
          }
        },
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _imageMessageButton() {
    double _size = _deviceHeight * 0.04;

    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        backgroundColor: Color.fromRGBO(0, 82, 218, 1.0),
        child: Icon(
          Icons.camera_enhance,
          color: Colors.white,
        ),
      ),
    );
  }
}
