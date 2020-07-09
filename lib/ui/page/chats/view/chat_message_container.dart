import 'package:flutter/material.dart';
import 'package:flutterwechat/data/models/chat_message_info.dart';
import 'package:flutterwechat/ui/components/avatar.dart';

class ChatMessageContainer extends StatelessWidget {
  final ChatMessageInfo message;
  final bool showUsername;
  final Widget child;

  ChatMessageContainer(
      {@required this.child, this.message, this.showUsername = true});

  @override
  Widget build(BuildContext context) {
    Widget avatar = Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Avatar(
        size: 50,
        borderRadius: 3,
        color: message.userType == 0 ? Colors.blue : Colors.orange,
      ),
    );
    Widget container = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: message.userType == 0
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: <Widget>[
          if (showUsername)
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
              child: Text(
                message.username,
                style: TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ),
          this.child,
        ],
      ),
    );
    Widget space = Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 100),
      ),
    );

    List<Widget> children = message.userType == 0
        ? [avatar, container, space]
        : [space, container, avatar];

    if (message.userType >= 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    }
  }
}
