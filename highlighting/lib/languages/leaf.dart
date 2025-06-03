// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: file_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: use_raw_strings

import '../src/language_definition_common.dart';

final leaf = Language(
  id: "leaf",
  refs: {
    '~contains~0~contains~0': Mode(
      scope: "params",
      begin: "\\(",
      end: "\\)(?=\\:?)",
      endsParent: true,
      relevance: 7,
      contains: [
        Mode(
          match: ["([A-Za-z_][A-Za-z_0-9]*)?", "(?=\\()"],
          scope: {"1": "keyword"},
          contains: [ModeReference('~contains~0~contains~0')],
        ),
        Mode(scope: "string", begin: "\"", end: "\""),
        Mode(scope: "keyword", match: "true|false|in"),
        Mode(scope: "variable", match: "[A-Za-z_][A-Za-z_0-9]*"),
        Mode(
          scope: "operator",
          match: "\\+|\\-|\\*|\\/|\\%|\\=\\=|\\=|\\!|\\>|\\<|\\&\\&|\\|\\|",
        ),
      ],
    ),
  },
  name: "Leaf",
  contains: [
    Mode(
      match: ["#+", "([A-Za-z_][A-Za-z_0-9]*)?", "(?=\\()"],
      scope: {"1": "punctuation", "2": "keyword"},
      starts: Mode(
        contains: [Mode(match: "\\:", scope: "punctuation")],
      ),
      contains: [ModeReference('~contains~0~contains~0')],
    ),
    Mode(
      match: ["#+", "([A-Za-z_][A-Za-z_0-9]*)?", ":?"],
      scope: {"1": "punctuation", "2": "keyword", "3": "punctuation"},
    ),
  ],
);
