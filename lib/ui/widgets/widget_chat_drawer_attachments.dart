
import 'package:artrooms/ui/widgets/widget_media.dart';

import 'package:flutter/material.dart';

import '../../beans/bean_message.dart';


Widget widgetChatDrawerAttachments(BuildContext context, List<DataMessage> listAttachmentsImages) {
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for(DataMessage message in listAttachmentsImages)
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () {
                doOpenPhotoView(context, imageUrl:message.getImageUrl(), fileName:message.attachmentName);
              },
              child: Container(
                width: 80,
                height: 80,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFF3F3F3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/chats/placeholder_photo.png',
                  image: message.getImageUrl(),
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
      ],
    ),
  );
}
