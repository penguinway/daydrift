/// 配对信息模型（简化：服务端管理配对关系）
class PairModel {
  final String myId;
  final String? partnerId;

  const PairModel({
    required this.myId,
    this.partnerId,
  });

  bool get isPaired => partnerId != null;

  Map<String, dynamic> toJson() => {
        'myId': myId,
        'partnerId': partnerId,
      };

  factory PairModel.fromJson(Map<String, dynamic> json) => PairModel(
        myId: json['myId'] as String,
        partnerId: json['partnerId'] as String?,
      );
}
