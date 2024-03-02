import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/provider/chats_page_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../provider/authentication_provider.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/top_bar.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<ChatsPageProvider>();
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              "Chats ",
              fontSize: 16,
              primaryAction: IconButton(
                icon: Icon(Icons.logout),
                color: Color.fromRGBO(0, 80, 218, 1.0),
                onPressed: () {
                  _auth.logOut();
                },
              ),
            ),
            _chatList(),
          ],
        ),
      );
    });
  }

  Widget _chatList() {
    List<Chat>? _chats = _pageProvider.chats;
    print(_chats);
    return Expanded(
      child: (() {
        if (_chats != null) {
          if (_chats.length != 0) {
            return ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (BuildContext _context, int indx) {
                  return _chatTile(_chats[indx]);
                });
          } else {
            return Text(
              "No Chats Found",
              style: TextStyle(
                color: Colors.white,
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white54,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recepiens = _chat.resepients();
    bool _isActive = _recepiens.any((_d) => _d.wasRecentlyActive());
    String _subTitleText = "";
    if (_chat.messages.isNotEmpty) {
      _subTitleText = _chat.messages.first.type != MessageType.TEXT
          ? "Media Attachment"
          : _chat.messages.first.content;

    }
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: _chat.title(),
      subtitle: _subTitleText,
      imagePath: _chat.imageURL(),
      isActive: _isActive,
      isActivity: _chat.activity,
      onTap: () {},
    );
  }
}
