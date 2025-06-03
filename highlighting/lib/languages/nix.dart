// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: file_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: use_raw_strings

import '../src/language_definition_common.dart';

final nix = Language(
  id: "nix",
  refs: {
    '~contains~5~variants~0~contains~3': Mode(
      scope: "char.escape",
      match: "\\\\(?!\\\$).",
    ),
    '~contains~5~variants~0~contains~1~contains~9': Mode(
      begin: "[A-Za-z_][A-Za-z0-9_'-]*(\\.[A-Za-z_][A-Za-z0-9_'-]*)*\\s*=(?!=)",
      returnBegin: true,
      relevance: 0,
      contains: [
        Mode(
          scope: "attr",
          match:
              "[A-Za-z_][A-Za-z0-9_'-]*(\\.[A-Za-z_][A-Za-z0-9_'-]*)*(?=\\s*=)",
          relevance: 0.2,
        ),
      ],
    ),
    '~contains~5~variants~0~contains~1~contains~8': Mode(
      scope: "params",
      match: "[A-Za-z_][A-Za-z0-9_'-]*\\s*:(?=\\s)",
    ),
    '~contains~5~variants~0~contains~1~contains~7': Mode(
      scope: "symbol",
      match:
          "(\\.\\.|\\.|\\x7e)?\\/([A-Za-z0-9_\\+\\.-]+)?(\\/[A-Za-z0-9_\\+\\.-]+)*(?=[\\s;])",
    ),
    '~contains~5~variants~0~contains~1~contains~6': Mode(
      scope: "symbol",
      match: "<[A-Za-z_][A-Za-z0-9_'-]*(\\/[A-Za-z_][A-Za-z0-9_'-]*)*>",
    ),
    '~contains~5~variants~0~contains~1~contains~11': Mode(
      scope: "operator",
      match:
          "(?:==|=|\\+\\+|\\+|<=|<\\||<|>=|>|->|//|/|!=|!|\\|\\||\\|>|\\?|\\*|&&)(?!-)",
      relevance: 0,
    ),
    '~contains~5~variants~0~contains~1~contains~10': Mode(
      variants: [
        Mode(scope: "operator", begin: "-(?!>)"),
        Mode(
          begin: ["\\b\\d+(\\.\\d+)?", "-", "(?!>)"],
          beginScope: {"1": "number", "2": "operator"},
        ),
        Mode(
          begin: [
            "(?:==|=|\\+\\+|\\+|<=|<\\||<|>=|>|->|//|/|!=|!|\\|\\||\\|>|\\?|\\*|&&)",
            "-",
            "(?!>)",
          ],
          beginScope: {"1": "operator", "2": "operator"},
        ),
      ],
      relevance: 0,
    ),
    '~contains~5~variants~0~contains~1': Mode(
      scope: "subst",
      begin: "\\\$\\{",
      end: "\\}",
      keywords: {
        "keyword": [
          "assert",
          "else",
          "if",
          "in",
          "inherit",
          "let",
          "or",
          "rec",
          "then",
          "with",
        ],
        "literal": ["true", "false", "null"],
        "built_in": [
          "abort",
          "baseNameOf",
          "builtins",
          "derivation",
          "derivationStrict",
          "dirOf",
          "fetchGit",
          "fetchMercurial",
          "fetchTarball",
          "fetchTree",
          "fromTOML",
          "import",
          "isNull",
          "map",
          "placeholder",
          "removeAttrs",
          "scopedImport",
          "throw",
          "toString",
        ],
      },
      contains: [
        ModeReference('~contains~0'),
        HASH_COMMENT_MODE,
        C_BLOCK_COMMENT_MODE,
        ModeReference('~contains~3'),
        ModeReference('~contains~4'),
        ModeReference('~contains~5'),
        ModeReference('~contains~5~variants~0~contains~1~contains~6'),
        ModeReference('~contains~5~variants~0~contains~1~contains~7'),
        ModeReference('~contains~5~variants~0~contains~1~contains~8'),
        ModeReference('~contains~5~variants~0~contains~1~contains~9'),
        ModeReference('~contains~5~variants~0~contains~1~contains~10'),
        ModeReference('~contains~5~variants~0~contains~1~contains~11'),
      ],
    ),
    '~contains~5': Mode(
      scope: "string",
      variants: [
        Mode(
          begin: "''",
          end: "''",
          contains: [
            Mode(scope: "char.escape", match: "''\\\$"),
            ModeReference('~contains~5~variants~0~contains~1'),
            Mode(scope: "char.escape", match: "'''"),
            ModeReference('~contains~5~variants~0~contains~3'),
          ],
        ),
        Mode(
          begin: "\"",
          end: "\"",
          contains: [
            Mode(scope: "char.escape", match: "\\\\\\\$"),
            ModeReference('~contains~5~variants~0~contains~1'),
            ModeReference('~contains~5~variants~0~contains~3'),
          ],
        ),
      ],
    ),
    '~contains~4': Mode(
      scope: "built_in",
      match:
          "(?:builtins\\.abort|builtins\\.add|builtins\\.addDrvOutputDependencies|builtins\\.addErrorContext|builtins\\.all|builtins\\.any|builtins\\.appendContext|builtins\\.attrNames|builtins\\.attrValues|builtins\\.baseNameOf|builtins\\.bitAnd|builtins\\.bitOr|builtins\\.bitXor|builtins\\.break|builtins\\.builtins|builtins\\.catAttrs|builtins\\.ceil|builtins\\.compareVersions|builtins\\.concatLists|builtins\\.concatMap|builtins\\.concatStringsSep|builtins\\.convertHash|builtins\\.currentSystem|builtins\\.currentTime|builtins\\.deepSeq|builtins\\.derivation|builtins\\.derivationStrict|builtins\\.dirOf|builtins\\.div|builtins\\.elem|builtins\\.elemAt|builtins\\.false|builtins\\.fetchGit|builtins\\.fetchMercurial|builtins\\.fetchTarball|builtins\\.fetchTree|builtins\\.fetchurl|builtins\\.filter|builtins\\.filterSource|builtins\\.findFile|builtins\\.flakeRefToString|builtins\\.floor|builtins\\.foldl'|builtins\\.fromJSON|builtins\\.fromTOML|builtins\\.functionArgs|builtins\\.genList|builtins\\.genericClosure|builtins\\.getAttr|builtins\\.getContext|builtins\\.getEnv|builtins\\.getFlake|builtins\\.groupBy|builtins\\.hasAttr|builtins\\.hasContext|builtins\\.hashFile|builtins\\.hashString|builtins\\.head|builtins\\.import|builtins\\.intersectAttrs|builtins\\.isAttrs|builtins\\.isBool|builtins\\.isFloat|builtins\\.isFunction|builtins\\.isInt|builtins\\.isList|builtins\\.isNull|builtins\\.isPath|builtins\\.isString|builtins\\.langVersion|builtins\\.length|builtins\\.lessThan|builtins\\.listToAttrs|builtins\\.map|builtins\\.mapAttrs|builtins\\.match|builtins\\.mul|builtins\\.nixPath|builtins\\.nixVersion|builtins\\.null|builtins\\.parseDrvName|builtins\\.parseFlakeRef|builtins\\.partition|builtins\\.path|builtins\\.pathExists|builtins\\.placeholder|builtins\\.readDir|builtins\\.readFile|builtins\\.readFileType|builtins\\.removeAttrs|builtins\\.replaceStrings|builtins\\.scopedImport|builtins\\.seq|builtins\\.sort|builtins\\.split|builtins\\.splitVersion|builtins\\.storeDir|builtins\\.storePath|builtins\\.stringLength|builtins\\.sub|builtins\\.substring|builtins\\.tail|builtins\\.throw|builtins\\.toFile|builtins\\.toJSON|builtins\\.toPath|builtins\\.toString|builtins\\.toXML|builtins\\.trace|builtins\\.traceVerbose|builtins\\.true|builtins\\.tryEval|builtins\\.typeOf|builtins\\.unsafeDiscardOutputDependency|builtins\\.unsafeDiscardStringContext|builtins\\.unsafeGetAttrPos|builtins\\.warn|builtins\\.zipAttrsWith)",
      relevance: 10,
    ),
    '~contains~3': Mode(
      scope: "comment",
      begin: "\\/\\*\\*(?!\\/)",
      end: "\\*\\/",
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
      subLanguage: ["markdown"],
      relevance: 0,
    ),
    '~contains~0': Mode(
      scope: "number",
      match: "\\b\\d+(\\.\\d+)?(?!-)",
      relevance: 0,
    ),
  },
  name: "Nix",
  aliases: ["nixos"],
  keywords: {
    "keyword": [
      "assert",
      "else",
      "if",
      "in",
      "inherit",
      "let",
      "or",
      "rec",
      "then",
      "with",
    ],
    "literal": ["true", "false", "null"],
    "built_in": [
      "abort",
      "baseNameOf",
      "builtins",
      "derivation",
      "derivationStrict",
      "dirOf",
      "fetchGit",
      "fetchMercurial",
      "fetchTarball",
      "fetchTree",
      "fromTOML",
      "import",
      "isNull",
      "map",
      "placeholder",
      "removeAttrs",
      "scopedImport",
      "throw",
      "toString",
    ],
  },
  contains: [
    ModeReference('~contains~0'),
    HASH_COMMENT_MODE,
    C_BLOCK_COMMENT_MODE,
    ModeReference('~contains~3'),
    ModeReference('~contains~4'),
    ModeReference('~contains~5'),
    ModeReference('~contains~5~variants~0~contains~1~contains~6'),
    ModeReference('~contains~5~variants~0~contains~1~contains~7'),
    ModeReference('~contains~5~variants~0~contains~1~contains~8'),
    ModeReference('~contains~5~variants~0~contains~1~contains~9'),
    ModeReference('~contains~5~variants~0~contains~1~contains~10'),
    ModeReference('~contains~5~variants~0~contains~1~contains~11'),
    Mode(scope: "meta.prompt", match: "^nix-repl>(?=\\s)", relevance: 10),
    Mode(scope: "meta", begin: ":([a-z]+|\\?)"),
  ],
);
