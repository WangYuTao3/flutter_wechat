import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterwechat/data/constants/constants.dart';
import 'package:flutterwechat/data/constants/style.dart';
import 'package:flutterwechat/ui/components/action_sheet.dart';
import 'package:flutterwechat/ui/components/avatar.dart';
import 'package:flutterwechat/ui/page/discover/moment_cell.dart';
import 'package:flutterwechat/ui/page/discover/moment_info.dart';
import 'package:flutterwechat/ui/page/discover/moment_list_provider.dart';
import 'package:flutterwechat/ui/page/discover/moment_operate_more.dart';
import 'package:flutterwechat/ui/page/discover/value_change_notifier.dart';
import 'package:flutterwechat/ui/view/bm_appbar.dart';
import 'package:provider/provider.dart';

class MomentListPage extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  // final ItemScrollController _scrollController = ItemScrollController();

  final double keyboardHeight = 250;

  final momentListProvider = MomentListProvider();
  final bottomHeightProvider = ValueChangeNotifier<double>(value: 0);

  final _items = List.generate(10, (index) => MomentInfo.random());

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: momentListProvider),
            ChangeNotifierProvider.value(value: bottomHeightProvider),
          ],
          child: Builder(
            builder: (context) {
              print("context");
              final textEditorHeight =
                  context.watch<ValueChangeNotifier<double>>();
              return Stack(
                children: <Widget>[
                  // 列表
                  MediaQuery.removePadding(
                    removeTop: true,
                    removeBottom: true,
                    context: context,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        final pixels = notification.metrics.pixels -
                            notification.metrics.minScrollExtent;

                        const maxValue = 300.0;
                        final offset = min(maxValue, max(0.0, pixels));
                        final alpha = offset / maxValue;
                        momentListProvider.setAppBarBackgroundAlpha(alpha);
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return _createHeader(context);
                          } else if (i == _items.length + 1) {
                            return SizedBox(height: textEditorHeight.value);
                          } else {
                            return MomentCell(
                              momentInfo: _items[i - 1],
                              test: (offset) {
                                print(offset);
                                // _scrollController.scrollTo(
                                //     index: i,
                                //     offset: addition - offset.dy,
                                //     duration: Duration(milliseconds: 250));
                              },
                              moreOperate: (offset) {
                                // 获取位置
                                final model = momentListProvider;
                                if (model.showOperateMore) {
                                  model.setOperateMoreTop(show: false);
                                } else {
                                  model.setOperateMoreTop(
                                      show: true, top: offset.dy);
                                }
                              },
                            );
                          }
                        },
                        itemCount: _items.length + 2,
                      ),
                    ),
                  ),
                  // appbar
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: paddingTop + kToolbarHeight,
                    child: Container(
                      child: Builder(
                        builder: (context) {
                          final threadshold = 0.8;
                          final originOffset = context.select(
                              (MomentListProvider value) =>
                                  value.appbarBackgroundAlpha);
                          final offset = max(0, originOffset - threadshold) *
                              (1 / (1 - threadshold));
                          final alpha = (offset * 255).toInt();
                          return BMAppBar(
                            color: originOffset < threadshold
                                ? Colors.white
                                : Colors.black,
                            backgroundColor:
                                Style.primaryColor.withAlpha(alpha),
                            title: Text(
                              "朋友圈",
                              style: TextStyle(
                                  color: Colors.black.withAlpha(alpha)),
                            ),
                            actions: <Widget>[
                              IconButton(
                                icon: SvgPicture.asset(
                                  Constant.assetsImagesMe
                                      .named("icons_filled_camera.svg"),
                                  color: originOffset < threadshold
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  _publishChoose(context);
                                },
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // OperateMore
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Builder(
                      builder: (context) {
                        final top = context.select(
                            (MomentListProvider model) => model.operateMoreTop);
                        return MomentOperateMore(
                          top: top,
                          show: context.select((MomentListProvider model) =>
                              model.showOperateMore),
                          dismiss: () {
                            momentListProvider.setOperateMoreTop(show: false);
                          },
                          onComment: () {
                            momentListProvider.setOperateMoreTop(show: false);
                          },
                          onLike: () {
                            momentListProvider.setOperateMoreTop(show: false);
                          },
                        );
                      },
                    ),
                  ),
                  // input
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: 0,
                    right: 0,
                    bottom: -keyboardHeight - 40 + textEditorHeight.value,
                    height: keyboardHeight + 40,
                    child: Container(
                      color: Colors.green,
                      height:
                          context.watch<ValueChangeNotifier<double>>().value,
                      child: TextField(
                          // autofocus: true,
                          ),
                    ),
                  )
                ],
              );
            },
          )),
    );
  }

  Widget _createHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 40,
            child: Container(
              color: Colors.green,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 18,
            width: 68,
            height: 68,
            child: Avatar(
              borderRadius: 8,
              color: Colors.blue,
            ),
          ),
          Positioned(
            right: 12.0 + 60 + 32,
            bottom: 48,
            child: Container(
              child: Text(
                "八戒",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _publishChoose(BuildContext context) {
    ActionSheet(
      itemCount: 2,
      itemBuilder: (c, i) {
        if (i == 0) {
          return SizedBox(
            height: 70,
            child: FlatButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "拍摄",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    "照片或视频",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black26,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        } else {
          return SizedBox(
            height: 60,
            child: FlatButton(
              padding: EdgeInsets.zero,
              child: Text(
                "从手机相册选择",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        }
      },
    ).show(context);
  }
}
