/// 实时状态数据模型 — 当前前台运行的应用
class StatusModel {
  final String userId;
  final String packageName;
  final String appName;
  final DateTime updatedAt;

  const StatusModel({
    required this.userId,
    required this.packageName,
    required this.appName,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'packageName': packageName,
        'appName': appName,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StatusModel.fromJson(Map<String, dynamic> json) => StatusModel(
        userId: json['userId'] as String,
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// 常见 App 对应的图标 emoji
  String get icon => _appIcons[packageName] ?? _guessIcon(appName);

  static const _appIcons = {
    'com.tencent.mm': '💬',             // 微信
    'com.tencent.mobileqq': '🐧',       // QQ
    'com.tencent.wework': '💼',          // 企业微信
    'com.alibaba.android.rimet': '💼',   // 钉钉
    'com.ss.android.ugc.aweme': '🎵',   // 抖音
    'com.ss.android.article.news': '📰', // 今日头条
    'com.sina.weibo': '📢',              // 微博
    'com.eg.android.AlipayGphone': '💰', // 支付宝
    'com.taobao.taobao': '🛒',          // 淘宝
    'com.jingdong.app.mall': '🛒',      // 京东
    'com.xunmeng.pinduoduo': '🛒',      // 拼多多
    'tv.danmaku.bili': '📺',             // 哔哩哔哩
    'com.netease.cloudmusic': '🎵',      // 网易云音乐
    'com.kugou.android': '🎵',           // 酷狗音乐
    'com.tencent.qqmusic': '🎵',         // QQ音乐
    'com.spotify.music': '🎵',           // Spotify
    'com.zhihu.android': '📖',           // 知乎
    'com.baidu.searchbox': '🔍',         // 百度
    'com.UCMobile': '🌐',               // UC浏览器
    'com.android.chrome': '🌐',          // Chrome
    'com.tencent.mtt': '🌐',             // QQ浏览器
    'com.google.android.youtube': '▶️',  // YouTube
    'com.smile.gifmaker': '📸',          // 快手
    'com.tencent.karaoke': '🎤',         // 全民K歌
    'com.tencent.tmgp.sgame': '🎮',     // 王者荣耀
    'com.tencent.ig': '🎮',              // 和平精英
    'com.miHoYo.Yuanshen': '🎮',        // 原神
    'com.autonavi.minimap': '🗺️',       // 高德地图
    'com.baidu.BaiduMap': '🗺️',         // 百度地图
    'com.didi.passenger': '🚗',          // 滴滴
    'com.MobileTicket': '🚄',           // 12306
    'com.mt.mtxx.mtxx': '📷',           // 美图秀秀
    'com.ss.android.ugc.trill': '🎵',   // TikTok
    'com.instagram.android': '📸',       // Instagram
    'com.whatsapp': '💬',                // WhatsApp
    'com.telegram.messenger': '💬',      // Telegram
    'com.twitter.android': '🐦',         // Twitter/X
    'com.facebook.katana': '👥',         // Facebook
    'com.google.android.gm': '📧',      // Gmail
    'com.microsoft.office.outlook': '📧', // Outlook
    'com.android.vending': '🏪',         // Play Store
    'com.android.settings': '⚙️',       // 设置
    'com.android.camera': '📷',          // 相机
    'com.android.gallery3d': '🖼️',      // 相册
    'com.android.phone': '📞',           // 电话
    'com.android.mms': '💬',             // 短信
  };

  static String _guessIcon(String appName) {
    final name = appName.toLowerCase();
    if (name.contains('music') || name.contains('音乐')) return '🎵';
    if (name.contains('game') || name.contains('游戏')) return '🎮';
    if (name.contains('video') || name.contains('视频')) return '📺';
    if (name.contains('camera') || name.contains('相机')) return '📷';
    if (name.contains('map') || name.contains('地图')) return '🗺️';
    if (name.contains('shop') || name.contains('购物') || name.contains('mall')) return '🛒';
    if (name.contains('browser') || name.contains('浏览')) return '🌐';
    if (name.contains('mail') || name.contains('邮件')) return '📧';
    if (name.contains('read') || name.contains('阅读') || name.contains('book')) return '📖';
    return '📱';
  }
}
