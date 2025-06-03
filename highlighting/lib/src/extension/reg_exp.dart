import 'package:collection/collection.dart';

import '../const/regexes.dart';
import '../utils.dart';

String lookahead(Pattern re) {
  return concat(['(?=', re, ')']);
}

String anyNumberOfTimes(Pattern re) {
  return concat(['(?:', re, ')*']);
}

String optional(Pattern re) {
  return concat(['(?:', re, ')?']);
}

String? source(Pattern? pattern) {
  if (pattern is String) {
    return pattern;
  }
  if (pattern is RegExp) {
    return pattern.pattern;
  }

  return null;
}

String concat(List<Pattern> args) {
  return args.map(source).join();
}

/// List<String | RegExp>
String either(Iterable<Pattern> args) {
  final joined = '(?:${args.map(source).join('|')})';
  return joined;
}

extension RegExpExtension on RegExp {
  int countMatchGroups() {
    return RegExp('$pattern|').firstMatch('')?.groupCount ?? 0;
  }
}

String rewriteBackReferences(List<dynamic> re, {String joinWith = '|'}) {
  var numCaptures = 0;

  return re
      .map((regex) {
        numCaptures++;
        final offset = numCaptures;

        var re = source(regex);
        final out = StringBuffer();

        while (re != null && re.isNotEmpty) {
          final matches = kBackRefRe.allMatches(re).firstOrNull;
          if (matches == null) {
            out.write(re);
            break;
          }

          out.write(substring(re, 0, matches.start));
          re = substring(re, matches.end);

          if (matches.group(0)?[0] == r'\' && matches.group(1) != null) {
            out.write('\\${int.parse(matches.group(1)!) + offset}');
          } else {
            out.write(matches.group(0));
            if (matches.group(0) == '(') {
              numCaptures++;
            }
          }
        }

        return out.toString();
      })
      .map((re) => '($re)')
      .join(joinWith);
}
