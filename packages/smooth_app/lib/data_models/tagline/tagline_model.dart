import 'dart:ui';

class TagLine {
  const TagLine({
    required this.news,
    required this.feed,
  });

  final TagLineNewsList news;
  final TagLineFeed feed;

  @override
  String toString() {
    return 'TagLine{news: $news, feed: $feed}';
  }
}

class TagLineNewsList {
  const TagLineNewsList(Map<String, TagLineNewsItem> news) : _news = news;

  final Map<String, TagLineNewsItem> _news;

  TagLineNewsItem? operator [](String key) => _news[key];

  @override
  String toString() {
    return 'TagLineNewsList{_news: $_news}';
  }
}

class TagLineNewsItem {
  const TagLineNewsItem({
    required this.id,
    required this.title,
    required this.message,
    required this.url,
    this.buttonLabel,
    this.startDate,
    this.endDate,
    this.image,
    this.style,
  });

  final String id;
  final String title;
  final String message;
  final String url;
  final String? buttonLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final TagLineImage? image;
  final TagLineStyle? style;

  @override
  String toString() {
    return 'TagLineNewsItem{id: $id, title: $title, message: $message, url: $url, buttonLabel: $buttonLabel, startDate: $startDate, endDate: $endDate, image: $image, style: $style}';
  }
}

class TagLineStyle {
  const TagLineStyle({
    this.titleBackground,
    this.titleTextColor,
    this.titleIndicatorColor,
    this.messageBackground,
    this.messageTextColor,
    this.buttonBackground,
    this.buttonTextColor,
    this.contentBackgroundColor,
  });

  TagLineStyle.fromHexa({
    String? titleBackground,
    String? titleTextColor,
    String? titleIndicatorColor,
    String? messageBackground,
    String? messageTextColor,
    String? buttonBackground,
    String? buttonTextColor,
    String? contentBackgroundColor,
  })  : titleBackground = _parseColor(titleBackground),
        titleTextColor = _parseColor(titleTextColor),
        titleIndicatorColor = _parseColor(titleIndicatorColor),
        messageBackground = _parseColor(messageBackground),
        messageTextColor = _parseColor(messageTextColor),
        buttonBackground = _parseColor(buttonBackground),
        buttonTextColor = _parseColor(buttonTextColor),
        contentBackgroundColor = _parseColor(contentBackgroundColor);

  final Color? titleBackground;
  final Color? titleTextColor;
  final Color? titleIndicatorColor;
  final Color? messageBackground;
  final Color? messageTextColor;
  final Color? buttonBackground;
  final Color? buttonTextColor;
  final Color? contentBackgroundColor;

  static Color? _parseColor(String? hexa) {
    if (hexa == null || hexa.length != 7) {
      return null;
    }
    return Color(int.parse(hexa.substring(1), radix: 16));
  }

  @override
  String toString() {
    return 'TagLineStyle{titleBackground: $titleBackground, titleTextColor: $titleTextColor, titleIndicatorColor: $titleIndicatorColor, messageBackground: $messageBackground, messageTextColor: $messageTextColor, buttonBackground: $buttonBackground, buttonTextColor: $buttonTextColor, contentBackgroundColor: $contentBackgroundColor}';
  }
}

class TagLineImage {
  const TagLineImage({
    required this.src,
    this.width,
    this.alt,
  });

  final String src;
  final double? width;
  final String? alt;

  @override
  String toString() {
    return 'TagLineImage{src: $src, width: $width, alt: $alt}';
  }
}

class TagLineFeed {
  const TagLineFeed(this.news);

  final List<TagLineFeedItem> news;

  bool get isNotEmpty => news.isNotEmpty;

  @override
  String toString() {
    return 'TagLineFeed{news: $news}';
  }
}

class TagLineFeedItem {
  const TagLineFeedItem({
    required this.news,
    DateTime? startDate,
    DateTime? endDate,
  })  : _startDate = startDate,
        _endDate = endDate;

  final TagLineNewsItem news;
  final DateTime? _startDate;
  final DateTime? _endDate;

  String get id => news.id;

  DateTime? get startDate => _startDate ?? news.startDate;

  DateTime? get endDate => _endDate ?? news.endDate;

  @override
  String toString() {
    return 'TagLineFeedItem{news: $news, _startDate: $_startDate, _endDate: $_endDate}';
  }
}
