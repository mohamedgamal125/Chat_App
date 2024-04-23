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
        body: SingleChildScrollView(
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
                    onPressed: () {},
                  ),
                  secondAction: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(0, 82, 218, 1.0),
                    ),
                    onPressed: () {},
                  ),
                ),
                _messagesListView(),
              ],
            ),
          ),
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
                    )
                );
              }),
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
}
