import 'package:highlighting/highlighting.dart';
import 'package:highlighting/languages/dart.dart';

void main() {
  const source = '''
main() {
  print('Highlighting by Akvelon.');
}
''';

  highlight.registerLanguage(dart);

  final highlighted = highlight.parse(source, languageId: dart.id);
  final html = highlighted.toHtml();
  // ignore: avoid_print
  print(html); // HTML string
}
