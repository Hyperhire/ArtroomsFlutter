
import 'package:artrooms/ui/widgets/widget_chatroom_mentioned_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendbird_sdk/core/models/member.dart';


Widget buildMentions({required Null Function(Member member) onCancelReply, required List<Member> members}) {
  return Container(
      padding: const EdgeInsets.all(0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: WidgetChatroomMentionUser(
        member: members,
        onCancelReply: (Member member) {
          onCancelReply(member);
        },
      ),
  );
}
