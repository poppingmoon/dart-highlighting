import 'node.dart';

import 'result.dart';

const closeSpan = '</span>';

class HtmlRenderer {
  String _buffer = '';
  String classPrefix;

  String get value => _buffer;

  HtmlRenderer({required this.classPrefix, required Result result}) {
    result.walk(this);
  }

  void addText(String text) {
    _buffer += _escape(text);
  }

  void openNode(Node node) {
    if (!emitsWrappingTag(node)) {
      return;
    }

    String className;
    if (node.sublanguage ?? false) {
      className = 'language-${node.language!}';
    } else {
      className = scopeToCSSClass(node.className!, classPrefix);
    }

    span(className);
  }

  void closeNode(Node node) {
    if (!emitsWrappingTag(node)) {
      return;
    }

    _buffer += closeSpan;
  }

  void span(String className) {
    _buffer += '<span class="$className">';
  }
}

bool emitsWrappingTag(Node node) {
  return node.className != null ||
      ((node.sublanguage ?? false) && node.language != null);
}

String scopeToCSSClass(String name, String prefix) {
  if (name.contains('.')) {
    return prefix + name.split('.').join(' ');
  }

  return '$prefix$name';
}

String _escape(String value) {
  return value
      .replaceAll(RegExp('&'), '&amp;')
      .replaceAll(RegExp('<'), '&lt;')
      .replaceAll(RegExp('>'), '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll('\'', '&#x27;');
}
