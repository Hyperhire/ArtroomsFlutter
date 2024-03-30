
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sendbird_sdk/core/message/file_message.dart';
import 'package:sendbird_sdk/core/message/user_message.dart';

import '../beans/bean_file.dart';
import '../beans/bean_message.dart';
import '../main.dart';
import '../utils/utils_media.dart';


class ModuleMessages {

  late final String _channelUrl;
  late final GroupChannel _groupChannel;
  bool _isInitialized = false;
  bool _isLoading = false;
  int? _earliestMessageTimestamp;
  int? _earliestMessageTimestampFiles;

  ModuleMessages(String channelUrl) {
    _channelUrl = channelUrl;
  }

  Future<GroupChannel> initChannel() async {

    await GroupChannel.getChannel(_channelUrl).then((GroupChannel groupChannel) {
      _groupChannel = groupChannel;
    });

    _isInitialized = true;

    return _groupChannel;
  }

  Future<List<DataMessage>> getMessagesNew() async {
    return getMessages(false);
  }

  Future<List<DataMessage>> getMessagesMore() async {
    return getMessages(true);
  }

  Future<List<DataMessage>> getMessages(bool isMore) async {

    final List<DataMessage> messages = [];

    if(_isLoading) return messages;

    _isLoading = true;

    if(!_isInitialized) {
      await initChannel();
    }

    await moduleSendBird.loadMessages(_groupChannel, isMore ? _earliestMessageTimestamp : null).then((List<BaseMessage> baseMessages) {

      for(BaseMessage baseMessage in baseMessages) {
        final DataMessage myMessage = DataMessage.fromBaseMessage(baseMessage);
        messages.add(myMessage);
      }

      if (isMore && messages.isNotEmpty) {
        _earliestMessageTimestamp = baseMessages.last.createdAt;
      }

    });

    _isLoading = false;

    return messages;
  }

  Future<DataMessage> sendMessage(String text,DataMessage? message) async {

    if(!_isInitialized) {
      await initChannel();
    }

    final UserMessage userMessage = await moduleSendBird.sendMessage(_groupChannel, text.trim(),message: message);

    final myMessage = DataMessage.fromBaseMessage(userMessage);

    return myMessage;
  }

  DataMessage preSendMessageImage(List<FileItem> fileItems) {

    DataMessage myMessage = DataMessage.empty();
    myMessage.index = DateTime.now().millisecondsSinceEpoch;
    myMessage.isMe = true;
    myMessage.isImage = true;
    myMessage.isSending = true;
    myMessage.timestamp = DateTime.now().millisecondsSinceEpoch;

    for(FileItem fileItem in fileItems) {
      if(fileItem.isSelected) {
        myMessage.index = DateTime.now().millisecondsSinceEpoch + fileItem.path.hashCode;
        myMessage.attachmentImages.add(fileItem.path);
      }
    }

    return myMessage;
  }

  Future<List<DataMessage>> preSendMessageMedia(List<FileItem> fileItems) async {

    List<DataMessage> messages = [];

    for(FileItem fileItem in fileItems) {
      if(fileItem.isSelected) {

        DataMessage myMessage = DataMessage.empty();
        myMessage.index = DateTime.now().millisecondsSinceEpoch + fileItem.file.path.length;
        myMessage.isMe = true;
        myMessage.isFile = true;
        myMessage.isSending = true;
        myMessage.attachmentName = getFileName(fileItem.file);
        myMessage.attachmentSize = await fileItem.file.length();
        myMessage.timestamp = DateTime.now().millisecondsSinceEpoch;

        myMessage.attachmentUrl = fileItem.path;

        messages.add(myMessage);
      }
    }

    return messages;
  }

  Future<DataMessage> sendMessageImages(List<FileItem> fileItems) async {

    if(!_isInitialized) {
      await initChannel();
    }

    List<File> files = [];

    for(FileItem fileItem in fileItems) {
      if(fileItem.isSelected) {
        files.add(fileItem.file);
      }
    }

    final DataMessage myMessage;

    if(files.length == 1) {
      myMessage = await moduleSendBird.sendMessageFiles(_groupChannel, files);
    }else {

      Map<String, dynamic> data = {};
      List<String> dataImages = [];

      for(File file in files) {

        Map<String, dynamic>? uploadData = await uploadFile(file);

        if(uploadData != null) {

          String accessUrl = uploadData["accessUrl"] ?? "";

          if(accessUrl.isNotEmpty) {
            dataImages.add(accessUrl);
          }
        }
      }

      data["data"] = dataImages;

      if(kDebugMode) {
        print("message images data: ${jsonEncode(data)}");
      }

      UserMessage userMessage = await moduleSendBird.sendMessage(_groupChannel, "multiple:image", data: jsonEncode(data));
      myMessage = DataMessage.fromBaseMessage(userMessage);
    }

    return myMessage;
  }

  Future<List<DataMessage>> sendMessageMedia(List<FileItem> fileItems) async {

    List<DataMessage> messages = [];

    if(!_isInitialized) {
      await initChannel();
    }

    List<File> files = [];

    for(FileItem fileItem in fileItems) {
      if(fileItem.isSelected) {
        files.add(fileItem.file);
      }
    }

    for(File file in files) {
      FileMessage fileMessage = await moduleSendBird.sendMessageFile(_groupChannel, file);
      DataMessage myMessage = DataMessage.fromBaseMessage(fileMessage);
      messages.add(myMessage);
    }

    return messages;
  }

  bool isLoading() {
    return _isLoading;
  }

  Future<List<DataMessage>> fetchAttachments() async {

    if(!_isInitialized) {
      await initChannel();
    }

    List<DataMessage> attachmentsImages = [];

    List<BaseMessage> attachments = await moduleSendBird.fetchAttachments(_groupChannel, _earliestMessageTimestampFiles);

    for (BaseMessage message in attachments) {

      DataMessage myMessage = DataMessage.fromBaseMessage(message);

      if(myMessage.isImage || myMessage.isFile) {
        attachmentsImages.add(myMessage);
      }

    }

    if (attachments.isNotEmpty) {
      _earliestMessageTimestampFiles = attachments.last.createdAt;
    }

    return attachmentsImages;
  }

  Future<List<DataMessage>> fetchAttachmentsImages() async {

    if(!_isInitialized) {
      await initChannel();
    }

    List<DataMessage> attachmentsImages = [];

    List<DataMessage> attachments = await fetchAttachments();

    for (DataMessage myMessage in attachments) {

        if(myMessage.isImage) {

          for(String attachmentUrl in myMessage.attachmentImages) {

            DataMessage myMessage1 = DataMessage.fromBaseMessageWithDetails(
              index: myMessage.index,
              senderId: myMessage.senderId,
              senderName: myMessage.senderName,
              content: myMessage.content,
              timestamp: myMessage.timestamp,
              isMe: myMessage.isMe,
            );

            myMessage1.isImage = true;
            myMessage1.attachmentUrl = attachmentUrl;
            myMessage1.attachmentName = myMessage.attachmentName;
            myMessage1.attachmentSize = myMessage.attachmentSize;

            attachmentsImages.add(myMessage1);
          }

        }

    }

    return attachmentsImages;
  }

  Future<List<DataMessage>> fetchAttachmentsFiles() async {

    if(!_isInitialized) {
      await initChannel();
    }

    List<DataMessage> attachmentsImages = [];

    List<DataMessage> attachments = await fetchAttachments();

    for (DataMessage myMessage in attachments) {

      if(myMessage.isFile) {
        attachmentsImages.add(myMessage);
      }

    }

    return attachmentsImages;
  }

  Future<Map<String, dynamic>?> uploadFile(File file) async {
    try {

      var uri = Uri.parse('https://artrooms-api-upload.com/file');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: null,
      ));

      request.headers.addAll({
        'Accept': 'application/json, text/plain, */*',
      });

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {

        Map<String,dynamic> uploadData = jsonDecode(response.body);

        print(uploadData.toString());

        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('Failed to upload file: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }
  GroupChannel getGroupChannel(){
    return _groupChannel;
  }
}
