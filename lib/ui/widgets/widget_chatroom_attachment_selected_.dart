import 'package:artrooms/beans/bean_file.dart';
import 'package:artrooms/ui/widgets/widget_media.dart';
import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';

class ChatroomAttachmentSelected extends StatelessWidget {

  final List<FileItem> filesImages;
  final Function(FileItem fileItem) onRemove;

  const ChatroomAttachmentSelected(
      {super.key, required this.filesImages, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    List<FileItem> filesAttachment = [];

    for (FileItem fileImage in filesImages) {
      if (fileImage.isSelected) {
        filesAttachment.add(fileImage);
      }
    }

    filesAttachment.sort((a, b) {
      return a.timeSelected.compareTo(b.timeSelected);
    });

    int index = 0;
    for (FileItem fileImage in filesAttachment) {
      fileImage.index = index;
      index++;
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (FileItem fileItem in filesAttachment)
              Container(
                margin: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                child: InkWell(
                  onTap: () {
                    doOpenPhotoView(
                        context, filesImages, initialIndex: fileItem.index);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFF3F3F3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Image.file(
                          fileItem.getPreviewFile(),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: colorMainGrey400,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              onRemove(fileItem);
                            },
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
    );
  }
}
