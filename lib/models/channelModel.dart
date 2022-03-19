
class ChannelModel{

  final String name;
  final String photoUrl;
  final String peerEmail;
  final String channelId;


  factory ChannelModel.fromJson(Map<dynamic, dynamic> json) => ChannelModel(
    peerEmail: json['peerEmail'],
    name: json['name'],
    photoUrl: json['photoUrl'],
    channelId: json['channelId'],
  );

  ChannelModel({this.name, this.photoUrl, this.peerEmail, this.channelId});
}