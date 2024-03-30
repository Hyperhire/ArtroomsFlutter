
import 'package:artrooms/ui/widgets/widget_chatroom_message_span.dart';
import 'package:flutter/material.dart';


Widget widgetChatroomMessageInput(TextEditingController messageController, messageFocusNode, {required Null Function(String text) onChanged}) {
  return Stack(
    alignment: Alignment.topLeft,
    children: <Widget>[
      TextFormField(
        controller: messageController,
        focusNode: messageFocusNode,
        onChanged: (text) {
          onChanged(text);
        }, // TextEditingController
        decoration: InputDecoration(
          hintText: 'Enter your message',
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF3F3F3),
        ),
        // cursorColor: Colors.transparent, // Hide cursor
        style: const TextStyle(color: Colors.transparent), // Hide text
      ),
      Positioned(
        top: 15,
        left: 15,
        child: IgnorePointer(
          child: RichText(
            text: widgetChatroomMessageTextSpan(messageController.text),
          ),
        ),
      ),
    ],
  );
}