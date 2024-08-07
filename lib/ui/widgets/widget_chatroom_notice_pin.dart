import 'package:artrooms/beans/bean_notice.dart';
import 'package:artrooms/utils/utils_screen.dart';
import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';

class WidgetChatroomNoticePin extends StatefulWidget {
  final DataNotice dataNotice;
  final bool isExpandNotice;
  final void Function() onToggle;
  final void Function() onHide;

  const WidgetChatroomNoticePin(
    this.dataNotice,
    this.isExpandNotice, {
    super.key,
    required this.onToggle,
    required this.onHide,
  });

  @override
  State<WidgetChatroomNoticePin> createState() {
    return _WidgetChatroomNoticePinState();
  }
}

class _WidgetChatroomNoticePinState extends State<WidgetChatroomNoticePin> {
  late int maxLines;

  @override
  void initState() {
    super.initState();

    maxLines = widget.isExpandNotice ? 5 : 1;
  }

  @override
  void didUpdateWidget(WidgetChatroomNoticePin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpandNotice != widget.isExpandNotice) {
      _adjustMaxLines();
    }
  }

  void _adjustMaxLines() {
    if (widget.dataNotice.notice.isEmpty || !widget.isExpandNotice) {
      setState(() {
        maxLines = 1;
      });
      return;
    }

    final textSpan = TextSpan(
      text: widget.dataNotice.notice,
      style: TextStyle(
        color: const Color(0xFF3A3A3A),
        fontSize: widget.isExpandNotice
            ? (isTablet(context) ? 17 : 14)
            : (isTablet(context) ? 17 : 14),
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        height: 0,
        letterSpacing: -0.28,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 5,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);

    final numLines = textPainter.computeLineMetrics().length;

    setState(() {
      maxLines = numLines < 5 ? numLines : 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        padding: EdgeInsets.only(
          top: widget.isExpandNotice ? 4 : 4,
          bottom: widget.isExpandNotice ? 4 : 0,
        ),
        constraints: BoxConstraints(minHeight: widget.isExpandNotice ? 60 : 44),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 18,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            widget.onToggle();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: isTablet(context) ? 22 : 20,
                              height: isTablet(context) ? 22 : 20,
                              padding: const EdgeInsets.only(
                                top: 2.55,
                                left: 1.64,
                                right: 1.77,
                                bottom: 2.46,
                              ),
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 16.5,
                                    height: 15,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/icons/icon_notice.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: widget.isExpandNotice
                                          ? Alignment.topLeft
                                          : Alignment.centerLeft,
                                      child: Text(
                                        widget.dataNotice.notice,
                                        style: TextStyle(
                                          color: const Color(0xFF3A3A3A),
                                          fontSize: widget.isExpandNotice
                                              ? (isTablet(context) ? 17 : 14)
                                              : (isTablet(context) ? 17 : 14),
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                          letterSpacing: -0.28,
                                        ),
                                        maxLines: maxLines,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: isTablet(context) ? 22 : 20,
                              height: isTablet(context) ? 22 : 20,
                              margin: const EdgeInsets.only(right: 2.0),
                              clipBehavior: Clip.antiAlias,
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(widget.isExpandNotice
                                        ? "assets/images/icons/icon_arrow_up.png"
                                        : "assets/images/icons/icon_arrow_down.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.isExpandNotice,
                  child: Container(
                    width: double.infinity,
                    height: 32,
                    margin: const EdgeInsets.only(top: 10.0),
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: TextButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: colorPrimaryBlue,
                        backgroundColor: colorMainGrey200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: const Text(
                        '다시 열지 않음',
                        style: TextStyle(
                          color: colorMainGrey900,
                          fontSize: 13,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.26,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        widget.onHide();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
