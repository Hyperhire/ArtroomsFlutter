
import 'package:artrooms/ui/screens/screen_chatroom_drawer.dart';
import 'package:artrooms/ui/widgets/widget_loader.dart';
import 'package:flutter/material.dart';
import '../../beans/bean_chat.dart';
import '../../beans/bean_file.dart';
import '../../beans/bean_message.dart';
import '../../modules/module_messages.dart';
import '../theme/theme_colors.dart';
import '../widgets/widget_media.dart';


class MyScreenChatroom extends StatefulWidget {

  final MyChat chat;

  const MyScreenChatroom({super.key, required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _MyScreenChatroomState();
  }

}

class _MyScreenChatroomState extends State<MyScreenChatroom> {

  bool _isLoading = true;
  bool _isLoadMore = false;
  bool _isButtonDisabled = true;
  bool _showAttachment = false;
  bool _showAttachmentFull = false;
  final List<MyMessage> listMessages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  late final ModuleMessages moduleMessages;

  double _boxHeight = 320.0;
  double _dragStartY = 0.0;
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_checkIfButtonShouldBeEnabled);
    _scrollController.addListener(_loadMessages);
    moduleMessages = ModuleMessages(widget.chat.id);
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    Widget attachmentPicker = _attachmentPicker(context, this);

    return WillPopScope(
      onWillPop: () async {
        if(_showAttachment) {
          setState(() {
            _showAttachment = false;
          });
          return false;
        }else if(_showAttachmentFull) {
          setState(() {
            _showAttachmentFull = false;
          });
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: colorMainGrey250,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  widget.chat.name,
                  style: const TextStyle(
                    color: colorMainGrey900,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: 'SUIT',
                    height: 0,
                    letterSpacing: -0.36,
                  ),
                ),
                centerTitle: true,
                elevation: 0.5,
                backgroundColor: Colors.white,
                actions: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/icons/icon_archive.png',
                            width: 24,
                            height: 24,
                          )
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return MyScreenChatroomDrawer(myChat: widget.chat,);
                        }));
                      },
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: _isLoading
                        ? const MyLoader()
                        : Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: listMessages.isNotEmpty ? ListView.builder(
                            controller: _scrollController,
                            itemCount: listMessages.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final message = listMessages[index];
                              final isPreviousSame = index == 0 ? false : listMessages[index - 1].senderId == message.senderId;
                              return message.isMe
                                  ? _buildMyMessageBubble(message)
                                  : _buildOtherMessageBubble(message, isPreviousSame);
                            },
                          )
                              : buildNoChats(context),
                        ),
                        Visibility(
                          visible: _isLoadMore,
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 6),
                            child: const CircularProgressIndicator(
                              color: Color(0xFF6A79FF),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMessageInput(),
                  const SizedBox(height: 8),
                  Visibility(
                    visible: _showAttachment,
                    child: SizedBox(
                        height: _boxHeight,
                        child: attachmentPicker
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _showAttachmentFull,
              child: Scaffold(
                backgroundColor: Colors.black.withOpacity(0.4),
                body: Container(
                  height: double.infinity,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: _boxHeight,
                      margin: const EdgeInsets.only(top: 80),
                      padding: const EdgeInsets.only(top: 16),
                      color: Colors.white,
                      child: attachmentPicker
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(0.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _boxHeight = 320;
                  _showAttachment = !_showAttachment;
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add,
                  color: colorMainGrey250,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '',
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,

                ),
                filled: true,
                fillColor: const Color(0xFFF3F3F3),
              ),
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontFamily: 'SUIT',
                fontWeight: FontWeight.w400,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(0.0),
            child: InkWell(
              onTap: () {
                _sendMessage();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/icons/icon_send.png',
                  width: 24,
                  height: 24,
                  color: _isButtonDisabled ? colorMainGrey250 : colorPrimaryBlue,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMyMessageBubble(MyMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: message.content.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.getTime(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: colorMainGrey300,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: colorPrimaryBlue,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24)
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              child: _buildAttachment(message)
          ),
          Container(
              child: _buildImageAttachments(message)
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessageBubble(MyMessage message, bool isPreviousSame) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {

                },
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: colorMainGrey200,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/profile/placeholder.png',
                    image: message.profilePictureUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 100),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/profile/profile_${(message.senderId.hashCode % 2) + 1}.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 4, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth / 4,
                          child: Text(
                            message.getName(),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Color(0xFF393939),
                              fontSize: 14,
                              fontFamily: 'SUIT',
                              fontWeight: FontWeight.w600,
                              height: 0.07,
                              letterSpacing: -0.28,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Visibility(
                          visible: message.content.isNotEmpty,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 40, minWidth: 46),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            alignment: Alignment.centerLeft,
                            decoration: const BoxDecoration(
                              color: colorMainGrey200,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  constraints: BoxConstraints(maxWidth: screenWidth * 0.65,),
                                  child: Text(
                                    message.content,
                                    style: const TextStyle(
                                      color: Color(0xFF1F1F1F),
                                      fontSize: 16,
                                      fontFamily: 'SUIT',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                      letterSpacing: -0.32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: message.content.isNotEmpty,
                    child: Text(
                      message.getTime(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: colorMainGrey300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 38),
              child: _buildAttachment(message)
          ),
          _buildImageAttachments(message),
        ],
      ),
    );
  }

  Widget buildNoChats(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/icons/chat_gray.png',
            width: 54.0,
            height: 54.0,
          ),
          const SizedBox(height: 17),
          const Text(
            '대화내용이 없어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorMainGrey700,
              fontSize: 14,
              fontFamily: 'SUIT',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: -0.28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(MyMessage message) {
    if (message.attachmentUrl.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE3E3E3), width: 1.0,),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.attachmentName,
              style: const TextStyle(
                  color: colorMainGrey700,
                fontSize: 16,
                fontFamily: 'SUIT',
                fontWeight: FontWeight.w400,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${message.getAttachmentSize()} / ${message.getDate()}',
              style: const TextStyle(
                color: colorMainGrey400,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 0,
                letterSpacing: -0.28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '만료',
              style: TextStyle(
                color: colorMainGrey400,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 0,
                letterSpacing: -0.28,
              ),
            ),
          ],
        ),
      );
    }else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildImageAttachments(MyMessage message) {
    if (message.imageAttachments.isNotEmpty) {
      return Container(
        height: message.imageAttachments.length > 1 ? 80 : 246,
        constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
        margin: EdgeInsets.symmetric(horizontal: message.isMe ? 0 : 40, vertical: 8),
        alignment: message.isMe ? Alignment.topRight : Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: message.imageAttachments.length,
          itemBuilder: (context, index) {
            bool isFirst = index == 0;
            bool isLast = index == message.imageAttachments.length - 1;
            return Container(
              margin: EdgeInsets.only(right: isFirst ? 0 : 2),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isFirst ? 24 : 0),
                    topRight: Radius.circular(isLast ? 24 : 0),
                    bottomLeft: Radius.circular(isFirst ? 24 : 0),
                    bottomRight: Radius.circular(isLast ? 24 : 0)
                ),
                child: Container(
                  width: (screenWidth * 0.65) / (message.imageAttachments.length > 3 ? 3 : message.imageAttachments.length),
                  decoration: BoxDecoration(
                    color: colorMainGrey200,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isFirst ? 24 : 0),
                        topRight: Radius.circular(isLast ? 24 : 0),
                        bottomLeft: Radius.circular(isFirst ? 24 : 0),
                        bottomRight: Radius.circular(isLast ? 24 : 0)
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      viewPhotoUrl(context, message.imageAttachments[index]);
                    },
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/chats/placeholder_photo.png',
                      image: message.imageAttachments[index],
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 100),
                      fadeOutDuration: const Duration(milliseconds: 100),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/chats/placeholder_photo.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }else {
      return const SizedBox.shrink();
    }
  }


  int type = 1;
  int _selected = 0;
  bool _selectMode = false;
  bool _isButtonFileDisabled = true;
  List<FileItem> files = [
    FileItem(name: '', path: 'assets/images/photos/photo_1.png'),
    FileItem(name: '', path: 'assets/images/photos/photo_2.png'),
    FileItem(name: '', path: 'assets/images/photos/photo_3.png'),
    FileItem(name: '', path: 'assets/images/photos/photo_4.png'),
  ];

  List<FileItem> filesMedia = [
    FileItem(name: 'artrooms_img_file_final_1', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_2', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_1', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_2', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_1', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_2', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_1', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_2', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_1', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_2', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_1', date: '2022.08.16 만료'),
    FileItem(name: 'artrooms_img_file_final_2', date: '2022.08.16 만료'),
  ];

  Widget _attachmentPicker(BuildContext context, State<StatefulWidget> state) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onTap: () {
                if(_showAttachment) {
                  state.setState(() {
                    _showAttachment = false;
                    _showAttachmentFull = true;
                  });
                }else {
                  setState(() {
                    _showAttachmentFull = false;
                  });
                }
              },
              child: Container(
                height: 16,
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: colorMainGrey250,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(color: colorPrimaryPurple,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      state.setState(() {
                        type = 1;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                            '카메라',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 0,
                              letterSpacing: -0.32,
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4,),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(color: colorPrimaryBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      state.setState(() {
                        type = 2;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                            '파일',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 0,
                              letterSpacing: -0.32,
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12,),
          Visibility(
            visible: type == 1,
            child: Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  var file = files[index];
                  return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        viewPhotoFile(context, file);
                      },
                      onLongPress: () {
                        state.setState(() {
                          file.isSelected = !file.isSelected;
                        });
                        _checkIfPhotoShouldBeEnabled();
                      },
                      child: Stack(
                        children: [
                          Image.asset(
                            file.path,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 3,
                            right: 4,
                            child: Visibility(
                              visible: _selectMode,
                              child: InkWell(
                                onTap: () {
                                  state.setState(() {
                                    file.isSelected = !file.isSelected;
                                    _checkIfPhotoShouldBeEnabled();
                                  });
                                },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: file.isSelected ? colorPrimaryBlue : colorMainGrey200.withAlpha(150),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: file.isSelected ? colorPrimaryBlue : const Color(0xFFE3E3E3),
                                      width: 1,
                                    ),
                                  ),
                                  child: file.isSelected
                                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                                      : Container(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Visibility(
            visible: type == 2,
            child: Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: filesMedia.length,
                itemBuilder: (context, index) {
                  var file = filesMedia[index];
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          file.isSelected = !file.isSelected;
                          _checkIfFileButtonShouldBeEnabled();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: colorMainGrey200, width: 1.0,),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Image.asset(
                                  file.isSelected ? 'assets/images/icons/icon_file_selected.png' : 'assets/images/icons/icon_file.png',
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        file.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: colorMainGrey700,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        file.date,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF8F8F8F),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 3,
                              right: 2,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: file.isSelected ? colorPrimaryBlue : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: file.isSelected ? colorPrimaryBlue : const Color(0xFFE3E3E3),
                                    width: 1,
                                  ),
                                ),
                                child: file.isSelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final newHeight = _boxHeight - details.globalPosition.dy + _dragStartY;

    setState(() {
      _boxHeight = newHeight.clamp(100.0, screenHeight);
      _dragStartY = details.globalPosition.dy;

      if(_boxHeight < screenHeight - 200 && _boxHeight > screenHeight - 300) {
        _showAttachment = false;
        _showAttachmentFull = false;
      }else if(_boxHeight > 320 + 160) {
        _showAttachment = false;
        if(!_showAttachmentFull) {
          _showAttachmentFull = true;
          _boxHeight = screenHeight;
        }
      }else if(_boxHeight < 320 - 160) {
        _showAttachment = false;
        _showAttachmentFull = false;
        _boxHeight = 320;
      }

    });

  }

  Future<void> _loadMessages() async {

    if(moduleMessages.isLoading()) return;

    if(!_isLoadMore) {
      _isLoadMore = listMessages.isNotEmpty;
    }

    moduleMessages.getMessages().then((List<MyMessage> messages){

      setState(() {
        listMessages.addAll(messages);
      });

      if(_isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      }

    }).catchError((e) {

    }).whenComplete(() {
      setState(() {
        _isLoading = false;
        _isLoadMore = false;
      });
    });

  }

  void _checkIfButtonShouldBeEnabled() {

    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }

  }

  void _sendMessage() {

    if(!_isButtonDisabled) {

      moduleMessages.sendMessage(_messageController.text).then((MyMessage myMessage) {

        setState(() {
          listMessages.insert(0, myMessage);
          _messageController.clear();
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });

      });

    }

  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _checkIfPhotoShouldBeEnabled() {

    _selected = 0;
    for(FileItem fileItem in files) {
      if(fileItem.isSelected) {
        setState(() {
          _selected++;
        });
      }
    }

    if (_selected > 0) {
      setState(() {
        _selectMode = true;
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }

  }

  void _deselectAll(isClose) {

    setState(() {
      _selected = 0;
    });

    for(FileItem fileItem in files) {
      setState(() {
        fileItem.isSelected = false;
      });
    }

    if(isClose) {
      setState(() {
        _selectMode = false;
      });

      _checkIfPhotoShouldBeEnabled();
    }

  }

  void select() {

    if(!_isButtonDisabled) {
      Navigator.pop(context);
    }

  }

  void _checkIfFileButtonShouldBeEnabled() {

    int n = 0;
    for(FileItem fileItem in files) {
      if(fileItem.isSelected) {
        n++;
      }
    }

    if (n > 0) {
      setState(() {
        _isButtonFileDisabled = false;
      });
    } else {
      setState(() {
        _isButtonFileDisabled = true;
      });
    }

  }

  void selectFiles() {

    if(!_isButtonFileDisabled) {
      Navigator.pop(context);
    }

  }

}
