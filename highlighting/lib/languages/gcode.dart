// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: file_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: use_raw_strings

import '../src/language_definition_common.dart';

final gcode = Language(
  id: "gcode",
  refs: {},
  name: "G-code (ISO 6983)",
  aliases: ["nc"],
  case_insensitive: true,
  disableAutodetect: true,
  keywords: {
    "\$pattern": "[A-Z]+|%",
    "keyword": [
      "THEN",
      "ELSE",
      "ENDIF",
      "IF",
      "GOTO",
      "DO",
      "WHILE",
      "WH",
      "END",
      "CALL",
      "SUB",
      "ENDSUB",
      "EQ",
      "NE",
      "LT",
      "GT",
      "LE",
      "GE",
      "AND",
      "OR",
      "XOR",
      "%",
    ],
    "built_in": [
      "ATAN",
      "ABS",
      "ACOS",
      "ASIN",
      "COS",
      "EXP",
      "FIX",
      "FUP",
      "ROUND",
      "LN",
      "SIN",
      "SQRT",
      "TAN",
      "EXISTS",
    ],
  },
  contains: [
    Mode(
      scope: "comment",
      begin: "\\(",
      end: "\\)",
      contains: [
        Mode(
          scope: "doctag",
          begin: "[ ]*(?=(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):)",
          end: "(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):",
          excludeBegin: true,
          relevance: 0,
        ),
        Mode(
          begin:
              "[ ]+((?:I|a|is|so|us|to|at|if|in|it|on|[A-Za-z]+['](d|ve|re|ll|t|s|n)|[A-Za-z]+[-][a-z]+|[A-Za-z][a-z]{2,})[.]?[:]?([.][ ]|[ ])){3}",
        ),
      ],
    ),
    Mode(
      scope: "comment",
      begin: ";",
      end: "\$",
      contains: [
        Mode(
          scope: "doctag",
          begin: "[ ]*(?=(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):)",
          end: "(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):",
          excludeBegin: true,
          relevance: 0,
        ),
        Mode(
          begin:
              "[ ]+((?:I|a|is|so|us|to|at|if|in|it|on|[A-Za-z]+['](d|ve|re|ll|t|s|n)|[A-Za-z]+[-][a-z]+|[A-Za-z][a-z]{2,})[.]?[:]?([.][ ]|[ ])){3}",
        ),
      ],
    ),
    APOS_STRING_MODE,
    QUOTE_STRING_MODE,
    C_NUMBER_MODE,
    Mode(
      scope: "title.function",
      variants: [
        Mode(match: "\\b[GM]\\s*\\d+(\\.\\d+)?"),
        Mode(
          begin: "[GM]\\s*\\d+(\\.\\d+)?",
          onBegin: language_g_code_iso_6983_contains_1_variants_0_onBegin,
        ),
        Mode(match: "\\bT\\s*\\d+"),
        Mode(
          begin: "T\\s*\\d+",
          onBegin: language_g_code_iso_6983_contains_1_variants_0_onBegin,
        ),
      ],
    ),
    Mode(
      scope: "symbol",
      variants: [
        Mode(match: "\\bO\\s*\\d+"),
        Mode(
          begin: "O\\s*\\d+",
          onBegin: language_g_code_iso_6983_contains_1_variants_0_onBegin,
        ),
        Mode(match: "\\bO<.+>"),
        Mode(
          begin: "O<.+>",
          onBegin: language_g_code_iso_6983_contains_1_variants_0_onBegin,
        ),
        Mode(match: "\\*\\s*\\d+\\s*\$"),
      ],
    ),
    Mode(scope: "operator", match: "^N\\s*\\d+"),
    Mode(scope: "variable", match: "-?#\\s*\\d+"),
    Mode(
      scope: "property",
      variants: [
        Mode(match: "\\b[ABCUVWXYZ]\\s*[+-]?((\\.\\d+)|(\\d+)(\\.\\d*)?)"),
        Mode(
          begin: "[ABCUVWXYZ]\\s*[+-]?((\\.\\d+)|(\\d+)(\\.\\d*)?)",
          onBegin: language_g_code_iso_6983_contains_1_variants_0_onBegin,
        ),
      ],
    ),
    Mode(
      scope: "params",
      variants: [
        Mode(match: "\\b[FHIJKPQRS]\\s*[+-]?((\\.\\d+)|(\\d+)(\\.\\d*)?)"),
        Mode(
          begin: "[FHIJKPQRS]\\s*[+-]?((\\.\\d+)|(\\d+)(\\.\\d*)?)",
          onBegin: language_g_code_iso_6983_contains_1_variants_0_onBegin,
        ),
      ],
    ),
  ],
);
