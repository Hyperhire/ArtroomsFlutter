import 'package:artrooms/ui/screens/screen_chatroom.dart';
import 'package:artrooms/ui/screens/screen_login.dart';
import 'package:artrooms/ui/screens/screen_notifications_sounds.dart';
import 'package:artrooms/ui/screens/screen_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';

import '../../beans/bean_chat.dart';
import '../../main.dart';
import '../../modules/module_chats.dart';
import '../../data/module_datastore.dart';
import '../../utils/utils_notifications.dart';
import '../../utils/utils.dart';
import '../../utils/utils_permissions.dart';
import '../theme/theme_colors.dart';
import '../widgets/widget_loader.dart';


class MyScreenChats extends StatefulWidget {

  const MyScreenChats({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyScreenChatsState();
  }

}

class _MyScreenChatsState extends State<MyScreenChats> {

  bool isLoading = true;
  bool isSearching = false;
  final List<MyChat> listChats = [];
  final List<MyChat> listChatsAll = [];
  final TextEditingController searchController = TextEditingController();

  final ChatModule chatModule = ChatModule();

  @override
  void initState() {
    super.initState();

    if(!MyDataStore().isLoggedIn()) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
        return const MyScreenLogin();
      }));
      return;
    }

    requestPermissions(context);

    loadChats();

    searchController.addListener(() {
      searchChats(searchController.text);
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chats',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '채팅',
            style: TextStyle(
              color: colorMainGrey900,
              fontSize: 20,
              fontFamily: 'SUIT',
              fontWeight: FontWeight.w700,
              height: 0,
              letterSpacing: -0.40,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return {'설정', '알림 및 소리'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: const Icon(
                  Icons.more_vert,
                  color: colorMainGrey250
              ),
              onSelected: (value) {
                switch (value) {
                  case '설정':
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const MyScreenProfile();
                    }));
                    break;
                  case '알림 및 소리':
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const MyScreenNotificationsSounds();
                    }));
                    break;
                }
              },
            ),
          ],
        ),
        body: isLoading
            ? const MyLoader()
            : Column(
          children: [
            Visibility(
              visible: isSearching || listChats.isNotEmpty || searchController.text.isNotEmpty,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '',
                    suffixIcon: !isSearching
                        ? Icon(
                        Icons.search,
                        size: 30,
                        color: searchController.text.isNotEmpty ? colorPrimaryBlue : colorMainGrey300
                    ) : Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(15),
                      child: const CircularProgressIndicator(
                        color: colorPrimaryBlue,
                        strokeWidth: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: (listChats.isNotEmpty || isSearching)
                  ? ListView.builder(
                itemCount: listChats.length,
                itemBuilder: (context, index) {
                  return Container(
                    key: Key(listChats[index].id),
                    child: buildListTile(context, index),
                  );
                },
              )
                  : buildNoChats(context),
            ),
          ],
        ),
      ),
    );
  }

  Slidable buildListTile(BuildContext context, int index) {
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            flex: 1,
            onPressed: _onClickOption1,
            backgroundColor: colorMainGrey300,
            foregroundColor: Colors.white,
            child: Image.asset('assets/images/icons/icon_bell.png', width: 24, height: 24),
          ),
          CustomSlidableAction(
            flex: 1,
            onPressed: _onClickOption2,
            backgroundColor: colorPrimaryBlue,
            foregroundColor: Colors.white,
            child: Image.asset('assets/images/icons/icon_forward.png', width: 24, height: 24),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/profile/profile_${(index % 2) + 1}.png',
                image: listChats[index].profilePictureUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 200),
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/profile/profile_${(index % 2) + 1}.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          title: Text(
            listChats[index].name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 15,
              fontFamily: 'SUIT',
              fontWeight: FontWeight.w700,
              height: 0,
              letterSpacing: -0.30,
            ),
          ),
          subtitle: Text(
            listChats[index].lastMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 13,
              fontFamily: 'SUIT',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: -0.26,
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatChatDateString(listChats[index].date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF979797),
                  fontSize: 10,
                  fontFamily: 'SUIT',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: -0.20,
                ),
              ),
              Visibility(
                visible: listChats[index].unreadMessages > 0,
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: colorPrimaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    listChats[index].unreadMessages.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MyScreenChatroom(chat: listChats[index]);
            }));
          },
        ),
      ),
    );
  }

  Widget buildNoChats(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/icons/chat_blue.png',
            width: 50.0,
            height: 50.0,
          ),
          const SizedBox(height: 14),
          const Text(
            '채팅방이 없어요',
            style: TextStyle(
              color: Color(0xFF565656),
              fontSize: 16,
              fontFamily: 'SUIT',
              fontWeight: FontWeight.w600,
              height: 0,
              letterSpacing: -0.32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '아트룸즈 홈페이지에서 상담신청을 하시거나\n라이브 클래스가 개설되면 채팅방이 개설됩니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorMainGrey700,
              fontSize: 12,
              fontFamily: 'SUIT',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }

  void _onClickOption1(BuildContext context) {

  }

  void _onClickOption2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: colorMainGrey200,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '채팅방 나가기',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 20,
                    fontFamily: 'SUIT',
                    fontWeight: FontWeight.w600,
                    height: 0,
                    letterSpacing: -0.40,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '대화 내용이 모두 삭제됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 16,
                    fontFamily: 'SUIT',
                    fontWeight: FontWeight.w400,
                    height: 0,
                    letterSpacing: -0.32,
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        listChats.removeAt(0);
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: colorPrimaryBlue,
                      backgroundColor: colorPrimaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SUIT',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadChats() async {

    await chatModule.getUserChats().then((List<MyChat> chats) {

      setState(() {
        listChats.addAll(chats);
        listChatsAll.addAll(chats);
      });

    }).catchError((e) {

    }).whenComplete(() {

      setState(() {
        isLoading = false;
      });

    });

  }

  void searchChats(String query) {

    setState(() {
      if(query.isNotEmpty) {
        isSearching = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {

      List<MyChat> filtered = listChatsAll.where((chat) {
        return chat.name.toLowerCase().contains(query.toLowerCase()) ||
            chat.lastMessage.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        listChats.clear();
        listChats.addAll(filtered);
        isSearching = false;
        isLoading = false;
      });

    });

  }

}
