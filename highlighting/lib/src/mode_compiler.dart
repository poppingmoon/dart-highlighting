import 'compile_keywords.dart';
import 'const/literals.dart';
import 'extension/before_match.dart';
import 'extension/compiler_extensions.dart';
import 'extension/multi_class.dart';
import 'extension/reg_exp.dart';
import 'js_style_reg_exp.dart';
import 'language.dart';
import 'mode.dart';
import 'multi_regex.dart';

Mode compileLanguage(Language language) {
  if (language.contains != null &&
      language.contains!.any((element) => element is ModeSelfReference)) {
    throw Exception('Self is not supported at top level');
  }

  if (language.classNameAliases is Map) {
    language.classNameAliases ??= Map.from(language.classNameAliases ?? {});
  } else {
    language.classNameAliases = {};
  }

  return compileMode(language, language: language, refs: language.refs);
}

ResumableMultiRegex buildModeRegex(Mode mode, {required Language language}) {
  final mm = ResumableMultiRegex(language: language);

  mode.contains?.forEach((term) {
    mm.addRule(term.beginRe!, RuleOptions(rule: term, type: $begin));
  });

  if (mode.terminatorEnd != null) {
    mm.addRule(RegExp(mode.terminatorEnd!), RuleOptions(type: $end));
  }

  if (mode.illegal != null) {
    mm.addRule(mode.illegalRe!, RuleOptions(type: $illegal));
  }

  return mm;
}

Mode compileMode(
  Mode mode, {
  required Language language,
  required Map<String, Mode> refs,
  Mode? parent,
}) {
  if (mode.isCompiled) {
    return mode;
  }
  Mode result = mode;

  if (result is ModeReference) {
    result = replaceRef(result, refs: refs);
  }

  final starts = result.starts;
  if (starts is ModeReference) {
    result.starts = replaceRef(starts, refs: refs);
  }

  scopeClassName(result);
  compileMatch(result, parent);
  multiClass(result, parent);
  beforeMatchExt(result, parent);

  // for (final ext in language.compilerExtensions) {
  //   ext?.call(result, parent);
  // }

  result.beforeBegin = null;

  beginKeywords(result, parent);
  compileIllegal(result, parent);
  compileRelevance(result, parent);

  result.isCompiled = true;

  dynamic keywordPattern;

  if (result.keywords case {$pattern: final pattern?}) {
    keywordPattern = pattern;
    result.keywords = Map.from(result.keywords)..remove($pattern);
  }

  keywordPattern ??= RegExp(r'(\w+)', multiLine: true);

  if (result.keywords != null) {
    result.keywords = compileKeywords(
      result.keywords,
      language.case_insensitive,
    );
  }

  result.keywordPatternRe = JsStyleRegExp(
    langRe(keywordPattern, true, language),
    global: true,
  );

  if (parent != null) {
    result.begin ??= r'\B|\b';
    result.beginRe = langRe(result.begin, false, language);
    if (result.endsWithParent != true) {
      result.end ??= RegExp(r'\B|\b');
    }
    if (result.end != null) {
      result.endRe = langRe(result.end, false, language);
    }

    result.terminatorEnd = source(result.end);

    if ((result.endsWithParent ?? false) && parent.terminatorEnd != null) {
      result.terminatorEnd =
          (result.terminatorEnd ?? '') +
          (result.end != null ? '|' : '') +
          parent.terminatorEnd!;
    }
  }

  if (result.illegal != null) {
    result.illegalRe = langRe(result.illegal, false, language);
  }
  result.contains ??= [];

  final newList = <Mode>[];
  for (var element in result.contains!) {
    if (element is ModeReference) {
      element = replaceRef(element, refs: refs);
    }
    newList.addAll(
      expandOrCloneMode(
        element is ModeSelfReference ? result : element,
        refs: refs,
      ),
    );
  }
  result.contains = newList;
  for (final element in result.contains!) {
    compileMode(element, parent: result, language: language, refs: refs);
  }

  if (result.starts != null) {
    compileMode(result.starts!, parent: parent, language: language, refs: refs);
  }

  result.matcher = buildModeRegex(result, language: language);

  return result;
}

bool dependencyOnParent(Mode? mode) {
  if (mode == null) return false;

  return (mode.endsWithParent ?? false) || dependencyOnParent(mode.starts);
}

List<Mode> expandOrCloneMode(Mode mode, {required Map<String, Mode> refs}) {
  if (mode.variants != null &&
      mode.variants!.isNotEmpty &&
      mode.cachedVariants == null) {
    mode.cachedVariants = mode.variants!.map((variant) {
      if (variant is ModeReference) {
        variant = replaceRef(variant, refs: refs);
      }
      return Mode.inherit(Mode.inherit(mode, Mode(variants: [])), variant);
    }).toList();
  }

  // EXPAND
  // if we have variants then essentially "replace" the mode with the variants
  // this happens in compileMode, where this function is called from
  if (mode.cachedVariants != null && mode.cachedVariants!.isNotEmpty) {
    return mode.cachedVariants!;
  }

  // CLONE
  // if we have dependencies on parents then we need a unique
  // instance of ourselves, so we can be reused with many
  // different parents without issue
  if (dependencyOnParent(mode)) {
    return [
      Mode.inherit(
        mode,
        Mode(starts: mode.starts != null ? Mode.inherit(mode.starts!) : null),
      ),
    ];
  }

  return [mode];
}
