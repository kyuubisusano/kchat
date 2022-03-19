import 'package:flutter/foundation.dart';
import 'package:kchat/widget/channel_list_widget.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// For Web
class ChannelProvider extends ChangeNotifier {
  String _selectedChannel;

  String get selectedChannel => _selectedChannel;

  void setChannel(String channel) {
    _selectedChannel = channel;
    notifyListeners();
  }
}