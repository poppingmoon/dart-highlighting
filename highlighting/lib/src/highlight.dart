import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import '../languages/all.dart';
import '../languages/plaintext.dart';
import 'const/literals.dart';
import 'const/magic_numbers.dart';
import 'js_style_reg_exp_match.dart';
import 'language.dart';
import 'mode.dart';
import 'mode_compiler.dart';
import 'response.dart';
import 'result.dart';
import 'utils.dart';

class Highlight {
  final _languages = <String, Language>{};

  void registerLanguage(Language language, {String? id}) {
    _languages[id ?? language.id] = language;
  }

  Result parse(String text, {required String languageId}) {
    return highlight(languageId, text, true);
  }

  Result highlight(
    String languageId,
    String codeToHighlight,
    // ignore: avoid_positional_boolean_parameters
    bool ignoreIllegals, {
    Mode? continuation,
    bool safeMode = true,
  }) {
    final emitter = Result();
    final language = _languages[languageId] ?? builtinLanguages[languageId];

    final md = compileLanguage(language!);

    Mode top = continuation ?? md;
    final continuations = <String, dynamic>{};

    void processContinuations() {
      final list = [];
      for (
        Mode? current = top;
        current != language && current != null;
        current = current.parent
      ) {
        if (current.scope != null) {
          list.insert(0, current.scope);
        }
      }
      list.whereType<String>().forEach(emitter.openNode);
    }

    processContinuations();
    final modeBuffer = StringBuffer();
    double relevance = 0;
    int index = 0;
    int iterations = 0;
    bool resumeScanAtSamePosition = false;

    /// KVs:
    /// `$type: MatchType ('begin', 'end', 'illegal')`,
    /// `$index: int`,
    /// `$rule`: Mode
    JsStyleRegExpMatch? lastMatch;

    final keywordHits = <String, int>{};

    Tuple2<String, double>? keywordData(Mode mode, String matchText) {
      if (mode.keywords case final Map keywords) {
        return keywords[matchText];
      }
      return null;
    }

    void processKeywords() {
      if (top.keywords == null) {
        emitter.addText(modeBuffer.toString());
        return;
      }

      var lastIndex = 0;
      top.keywordPatternRe!.lastIndex = 0; // lets assume it can't be null here
      var match = top.keywordPatternRe!.exec(modeBuffer.toString());
      final buf = StringBuffer();

      while (match != null) {
        buf.write(substring(modeBuffer.toString(), lastIndex, match.index));
        final word = language.case_insensitive
            ? match[0]!.toLowerCase()
            : match[0];

        final data = keywordData(top, word!);
        if (data != null) {
          final kind = data.item1;
          final keywordRelevance = data.item2;
          emitter.addText(buf.toString());
          buf.clear();

          keywordHits[word] = (keywordHits[word] ?? 0) + 1;
          if ((keywordHits[word] ?? 0) <= kMaxKeywordHits) {
            relevance += keywordRelevance;
          }
          if (kind.startsWith('_')) {
            buf.write(match[0]);
          } else {
            if (language.classNameAliases case final Map classNameAliases) {
              final cssClass = classNameAliases[kind] ?? kind;
              emitter.addKeyword(match[0]!, cssClass);
            }
          }
        } else {
          buf.write(match[0]);
        }
        lastIndex = top.keywordPatternRe!.lastIndex;
        match = top.keywordPatternRe?.exec(modeBuffer.toString());
      }

      buf.write(substring(modeBuffer.toString(), lastIndex));
      emitter.addText(buf.toString());
    }

    void processSubLanguage() {
      if (top.subLanguage.isEmpty) {
        throw Exception('processSublanguage called on empty sublanguage');
      }

      if (modeBuffer.isEmpty) {
        return;
      }

      Result result;
      if (top.subLanguage.length > 1) {
        result = highlightAuto(modeBuffer.toString(), top.subLanguage);
      } else {
        result = highlight(
          top.subLanguage.first,
          modeBuffer.toString(),
          true,
          continuation: continuations[top.subLanguage.first],
        );
        continuations[top.subLanguage.first] = result.top;
      }

      if (top.relevance! > 0) {
        relevance += result.relevance;
      }
      emitter.addSublanguage(result, result.language);
    }

    void processBuffer() {
      if (top.subLanguage.isNotEmpty) {
        processSubLanguage();
      } else {
        processKeywords();
      }
      modeBuffer.clear();
    }

    void emitMultiClass(Map scope, JsStyleRegExpMatch match) {
      var i = 1;
      final max = match.length - 1;
      while (i <= max) {
        if ((scope[$emit] as Map)[i] == null) {
          i++;
          continue;
        }
        final klass =
            switch (language.classNameAliases) {
              final Map classNameAliases =>
                classNameAliases[scope[i.toString()]],
              _ => null,
            } ??
            scope[i.toString()];
        final text = match[i];

        if (klass != null) {
          emitter.addKeyword(text!, klass);
        } else {
          modeBuffer.clear();
          modeBuffer.write(text);
          processKeywords();
          modeBuffer.clear();
        }
        i++;
      }
    }

    Mode startNewMode(Mode mode, JsStyleRegExpMatch match) {
      if (mode.scope != null && mode.scope is String) {
        emitter.openNode(
          switch (language.classNameAliases) {
                final Map classNameAliases => classNameAliases[mode.scope],
                _ => null,
              } ??
              mode.scope,
        );
      }

      if (mode.beginScope case final Map beginScope) {
        if (beginScope[$wrap] case final wrap?) {
          emitter.addKeyword(
            modeBuffer.toString(),
            switch (language.classNameAliases) {
                  final Map classNameAliases => classNameAliases[wrap],
                  _ => null,
                } ??
                wrap,
          );
          modeBuffer.clear();
        } else if (beginScope[$multi] == true) {
          // Here it must be compiledscope
          emitMultiClass(mode.beginScope, match);
          modeBuffer.clear();
        }
      }

      return top = Mode.inherit(mode, Mode(parent: top));
    }

    Mode? endOfMode(
      Mode mode,
      JsStyleRegExpMatch match,
      String matchPlusRemainder,
    ) {
      var matched = false;

      if (mode.endRe != null) {
        matched = matchPlusRemainder.startsWith(mode.endRe!);
      }

      if (matched) {
        if (mode.onEnd != null) {
          final resp = Response(mode: mode);

          mode.onEnd?.call(match, resp);
          if (resp.isMatchIgnored) {
            matched = false;
          }
        }
        Mode result = mode;
        if (matched) {
          while ((result.endsParent ?? false) && result.parent != null) {
            result = result.parent!;
          }
          return result;
        }
      }

      if (mode.endsWithParent ?? false) {
        return endOfMode(mode.parent!, match, matchPlusRemainder);
      }

      // Check what we need to return here.
      return null;
    }

    int doIgnore(String lexeme) {
      if (top.matcher?.regexIndex == 0) {
        modeBuffer.write(lexeme[0]);
        return 1;
      } else {
        resumeScanAtSamePosition = true;
        return 0;
      }
    }

    int doBeginMatch(JsStyleRegExpMatch match) {
      final lexeme = match[0];
      final newMode = match.rule!;

      final resp = Response(mode: newMode);
      final beforeCallbacks = [newMode.beforeBegin, newMode.onBegin];

      for (final cb in beforeCallbacks) {
        if (cb == null) {
          continue;
        }
        cb(match, resp);
        if (resp.isMatchIgnored) return doIgnore(lexeme!);
      }

      if (newMode.skip ?? false) {
        modeBuffer.write(lexeme);
      } else {
        if (newMode.excludeBegin ?? false) {
          modeBuffer.write(lexeme);
        }
        processBuffer();
        if (newMode.returnBegin != true && newMode.excludeBegin != true) {
          modeBuffer.write(lexeme);
        }
      }
      startNewMode(newMode, match);
      return newMode.returnBegin ?? false ? 0 : lexeme!.length;
    }

    int doEndMatch(JsStyleRegExpMatch match) {
      final lexeme = match[0];
      final matchPlusRemainder = substring(codeToHighlight, match.index);

      final endMode = endOfMode(top, match, matchPlusRemainder);
      if (endMode == null) {
        return kNoMatch;
      }

      final origin = top;
      if (top.endScope case {$wrap: final wrap?}) {
        processBuffer();
        emitter.addKeyword(lexeme!, wrap);
      } else if (top.endScope case {$multi: true}) {
        processBuffer();
        emitMultiClass(top.endScope, match);
      } else if (origin.skip ?? false) {
        modeBuffer.write(lexeme);
      } else {
        if (!((origin.returnEnd ?? false) || (origin.excludeEnd ?? false))) {
          modeBuffer.write(lexeme);
        }
        processBuffer();
        if (origin.excludeEnd ?? false) {
          modeBuffer.write(lexeme);
        }
      }

      do {
        if (top.scope != null) {
          emitter.closeNode();
        }
        if (top.skip != true && top.subLanguage.isEmpty) {
          relevance += top.relevance!;
        }
        top = top.parent!;
      } while (top != endMode.parent);

      if (endMode.starts != null) {
        startNewMode(endMode.starts!, match);
      }
      return origin.returnEnd ?? false ? 0 : lexeme!.length;
    }

    int processLexeme(String textBeforeMatch, JsStyleRegExpMatch? match) {
      final lexeme = match != null ? match[0] : null;

      modeBuffer.write(textBeforeMatch);

      if (lexeme == null) {
        processBuffer();
        return 0;
      }

      if (lastMatch?.matchType == $begin &&
          match!.matchType == $end &&
          lastMatch?.index == match.index &&
          lexeme == '') {
        modeBuffer.write(
          codeToHighlight.substring(match.index, match.index + 1),
        );
        if (!safeMode) {
          throw Exception(
            '0 width match regex $languageId, rule: ${lastMatch?.rule}',
          );
        }

        return 1;
      }

      lastMatch = match;

      if (match != null && match.matchType == $begin) {
        return doBeginMatch(match);
      } else if (match?.matchType == $illegal && !ignoreIllegals) {
        throw Exception(
          'Illegal lexeme $lexeme for mode ${top.scope ?? '<unnamed>'}',
        );
      } else if (match != null && match.matchType == $end) {
        final processed = doEndMatch(match);
        if (processed != kNoMatch) {
          return processed;
        }
      }

      if (match?.matchType == $illegal && lexeme == '') {
        return 1;
      }

      if (iterations > kMaxIterations &&
          match != null &&
          iterations > match.index * 3) {
        throw Exception();
      }

      modeBuffer.write(lexeme);
      return lexeme.length;
    }

    try {
      top.matcher?.considerAll();

      for (;;) {
        iterations++;
        if (resumeScanAtSamePosition) {
          resumeScanAtSamePosition = false;
        } else {
          top.matcher?.considerAll();
        }
        if (top.matcher != null) {
          top.matcher!.lastIndex = index;
        }
        final match = top.matcher?.exec(codeToHighlight);

        if (match == null) {
          break;
        }

        final beforeMatch = substring(codeToHighlight, index, match.index);
        final processedCount = processLexeme(beforeMatch, match);
        index = match.index + processedCount;
      }
      processLexeme(substring(codeToHighlight, index), null);
      emitter.closeAllNodes();
      emitter.finalize();
      emitter.relevance = relevance;
      emitter.language = languageId;
      emitter.top = top;
      return emitter;
    } on Exception catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return emitter;
  }

  @internal
  Result highlightAuto(String code, List<String> languageSubset) {
    final plainText = justTextHighlightResult(code);
    try {
      final results = languageSubset
          .where((e) => _languages[e] != null || builtinLanguages[e] != null)
          .where(
            (e) =>
                _languages[e]?.disableAutodetect != true ||
                builtinLanguages[e]?.disableAutodetect != true,
          )
          .map((name) => highlight(name, code, false))
          .toList();

      results.insert(0, plainText);
      results.sortByCompare<Result>((element) => element, _resultComparator);

      return results[0];
    } on Exception {
      return plainText;
    }
  }

  Result justTextHighlightResult(String code) {
    final emitter = Result(top: plaintext);

    return emitter..addText(code);
  }

  /// Compares results based on relevance, then on one being a superset.
  int _resultComparator(Result a, Result b) {
    // Sort base on relevance.
    if ((a.relevance - b.relevance).abs() > 0.0001) {
      return (b.relevance - a.relevance).sign.round();
    }

    // Always award the tie to the base language
    // i.e. if C++ and Arduino are tied, it's more likely to be C++.
    if (a.language != null && b.language != null) {
      if (_getLanguage(a.language!)?.supersetOf == b.language) {
        return 1;
      }
      if (_getLanguage(b.language!)?.supersetOf == a.language) {
        return -1;
      }
    }

    // Otherwise say they are equal, which has the effect of sorting on
    // relevance while preserving the original ordering - which is how ties
    // have historically been settled, i.e. the language that comes first always
    // wins in the case of a tie.
    return 0;
  }

  Language? _getLanguage(String name) {
    return _languages[name] ?? builtinLanguages[name];
  }
}
