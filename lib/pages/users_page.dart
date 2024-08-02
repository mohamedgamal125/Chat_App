import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/provider/authentication_provider.dart';
import 'package:chat_app/widgets/custom_list_view_tiles.dart';
import 'package:chat_app/widgets/rounded_button.dart';
import 'package:chat_app/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../provider/user_page_provider.dart';

import '../widgets/custom_input_fields.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late double _devicesHeight;
  late double _devicesWidth;
  late AuthenticationProvider _auth;

  late UserPageProvider _pageProvider;
  final TextEditingController _searchFieldTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    _devicesHeight = MediaQuery.of(context).size.height;
    _devicesWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserPageProvider>(
          create: (_) => UserPageProvider(_auth),
        )
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (context) {
        _pageProvider = context.watch<UserPageProvider>();
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: _devicesWidth * 0.03,
              vertical: _devicesHeight * 0.02),
          height: _devicesHeight * 0.98,
          width: _devicesWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Users',
                primaryAction: IconButton(
                  onPressed: () {
                    _auth.logOut();
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                ),
              ),
              CustomTextField(
                  hintText: "Search.....",
                  obscureText: false,
                  onEditingComplete: (_value) {
                    _pageProvider.getUsers(name: _value);
                    FocusScope.of(context).unfocus();
                  },
                  controller: _searchFieldTextEditingController,
                  icon: Icons.search),
              _userList(),
              _createChatButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _userList() {
    List<ChatUser>? _users = _pageProvider.users;
    return Expanded(
      child: () {
        if (_users != null) {
          if (_users.length != 0) {
            return ListView.builder(
              itemBuilder: (context, index) {
                return CustomListViewTile(
                    height: _devicesHeight * 0.10,
                    title: _users[index].name,
                    subtitle: "Last active ${_users[index].lastDayActive()}",
                    imagePath: _users[index].imageUrl,
                    isActive: _users[index].wasRecentlyActive(),
                    isSelected:
                        _pageProvider.selectedUser.contains(_users[index]),
                    onTap: () {
                      _pageProvider.updateSelectedUsers(_users[index]);
                    });
              },
              itemCount: _users.length,
            );
          } else {
            return Center(
              child: Text(
                "No Users found",
                style: TextStyle(
                  color: Colors.white,
                ),
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
      }(),
    );
  }

  Widget _createChatButton() {
    return Visibility(
        visible: _pageProvider.selectedUser.isNotEmpty,
        child: RoundedButton(
        name: _pageProvider.selectedUser.length == 1
            ? "Chat With ${_pageProvider.selectedUser.first.name}"
            : "Create Group Chat",
        height: _devicesHeight * 0.08,
        width: _devicesWidth * 0.8,
        onPressed: () {
          _pageProvider.createChat();
        }));
  }
}
