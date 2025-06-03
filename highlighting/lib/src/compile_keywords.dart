import 'package:tuple/tuple.dart';

import 'const/literals.dart';
import 'const/regexes.dart';

typedef KeywordDict = Map<String, Tuple2<String, double>>;

KeywordDict compileKeywords(
  dynamic rawKeywords,
  // ignore: avoid_positional_boolean_parameters
  bool caseInsensitive, {
  String scopeName = kDefaultKeywordScope,
}) {
  // ignore: omit_local_variable_types
  final KeywordDict compiledKeywords = {};

  bool commonKeyword(String keyword) {
    return kCommonKeywords.contains(keyword.toLowerCase());
  }

  double scoreForKeyword(String keyword, String? providedScore) {
    // manual scores always win over common keywords
    // so you can force a score of 1 if you really insist
    double? score;
    if (providedScore != null) {
      score = double.tryParse(providedScore);
    }

    return score ?? (commonKeyword(keyword) ? 0 : 1);
  }

  void compileList({
    required String scopeName,
    required List<String> keywordList,
    required bool caseInsensitive,
  }) {
    if (caseInsensitive) {
      keywordList = keywordList.map((x) => x.toLowerCase()).toList();
    }

    for (final keyword in keywordList) {
      final pair = keyword.split('|');
      compiledKeywords[pair[0]] = Tuple2(
        scopeName,
        scoreForKeyword(pair[0], pair.length > 1 ? pair[1] : null),
      );
    }
  }

  if (rawKeywords is String) {
    compileList(
      scopeName: scopeName,
      keywordList: rawKeywords.split(' '),
      caseInsensitive: caseInsensitive,
    );
  } else if (rawKeywords is List<String>) {
    compileList(
      scopeName: scopeName,
      keywordList: rawKeywords,
      caseInsensitive: caseInsensitive,
    );
  } else if (rawKeywords is Map) {
    for (final scopeName in rawKeywords.keys) {
      final result = compileKeywords(
        rawKeywords[scopeName],
        caseInsensitive,
        scopeName: scopeName,
      );

      for (final key in result.keys) {
        if (result[key] != null) {
          compiledKeywords[key] = result[key]!;
        }
      }
    }
  }

  return compiledKeywords;
}
