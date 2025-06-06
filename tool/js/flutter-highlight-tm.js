import fs from "fs";
import path from "path";
import _ from "lodash";
import { NOTICE_COMMENT } from "./common.js";
import { convertColor } from "./color.js";

const pathToNodeModules = "../node_modules";
const pathToFlutterHighlighting = "../../flutter_highlighting";

const rootDir = `${pathToNodeModules}/tm-themes/themes`;
const destDir = `${pathToFlutterHighlighting}/lib/tm_themes/themes`;

// https://macromates.com/manual/en/language_grammars#naming_conventions
// https://highlightjs.readthedocs.io/en/latest/css-classes-reference.html
const tmHlScopeMap = {
  "comment": "comment",
  "constant": "literal",
  "constant.numeric": "number",
  "constant.character": "string",
  "constant.character.escape": "char.escape_",
  "constant.language": "literal",
  "constant.other": "built_in",
  "entity": "title",
  "entity.name": "symbol",
  "entity.name.function": "title.function_",
  "entity.name.type": "title.class_",
  "entity.name.tag": "name",
  "entity.name.section": "section",
  "entity.other.inherited-class": "title.class_.inherited__",
  "entity.other.attribute-name": "attr",
  "invalid": "comment",
  "keyword": "keyword",
  "keyword.operator": "operator",
  "markup.bold": "strong",
  "markup.deleted": "deletion",
  "markup.inserted": "addition",
  "markup.italic": "emphasis",
  "markup.list.bullet": "bullet",
  "markup.heading": "strong",
  "markup.quote": "quote",
  "markup.underline.link": "link",
  "meta": "meta",
  "meta.embedded.expression": "subst",
  "meta.property-name": "property",
  "meta.tag.attributes": "attr",
  "punctuation.definition.deleted": "deletion",
  "punctuation.definition.inserted": "addition",
  "punctuation.definition.list.begin.markdown": "bullet",
  "storage": "type",
  "storage.type": "type",
  "storage.modifier": "meta",
  "string": "string",
  "string.interpolated": "subst",
  "string.regexp": "regexp",
  "support": "built_in",
  "support.constant": "literal",
  "support.type": "type",
  "variable": "variable",
  "variable.parameter": "params",
  "variable.language": "variable.language_",
};

function normalizeThemeName(name) {
  if (/^\d/.test(name)) {
    name = "theme" + name;
  }
  return _.camelCase(name + "Theme").replace(/a11y/i, "a11y");
}

export function style() {
  let all = [NOTICE_COMMENT, "const tmThemeMap = {"];

  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }

  fs.readdirSync(rootDir).forEach((file) => {
    const fileName = path.basename(file, ".json");
    const varName = normalizeThemeName(fileName);

    all[0] += `import 'themes/${fileName}.dart';`;
    all[1] += `'${fileName}': ${varName},`;

    const theme = JSON.parse(
      fs.readFileSync(path.resolve(rootDir, file), "utf-8"),
    );

    const obj = Object();
    const ignoredStyles = Object();

    const root = Object();
    obj["root"] = root;

    theme["tokenColors"].forEach((item) => {
      const style = Object();
      const settings = item["settings"];
      if (!settings) {
        return;
      }
      Object.entries(settings).forEach(([key, value]) => {
        switch (key) {
          case "background": {
            const flutterColor = convertColor(value);
            if (flutterColor) {
              style["backgroundColor"] = flutterColor;
            }
            break;
          }
          case "fontStyle": {
            value.split(" ").forEach((v) => {
              switch (v) {
                case "":
                  style["fontStyle"] = "FontStyle.normal";
                  style["fontWeight"] = "FontWeight.normal";
                  break;
                case "bold":
                  style["fontWeight"] = "FontWeight.bold";
                  break;
                case "italic":
                  style["fontStyle"] = "FontStyle.italic";
                  break;
                case "normal":
                  style["fontWeight"] = "FontWeight.normal";
                  break;
                case "regular":
                  style["fontWeight"] = "FontWeight.w500";
                case "strikethrough":
                  style["decoration"] = "TextDecoration.lineThrough";
                  break;
                case "underline":
                  style["decoration"] = "TextDecoration.underline";
                  break;
                default:
                  console.log(`fontStyle ignored: ${v}`);
              }
            });
            break;
          }
          case "foreground": {
            const flutterColor = convertColor(value);
            if (flutterColor) {
              style["color"] = flutterColor;
            }
            break;
          }
          case "text-decoration": {
            if (value === "underline") {
              style["decoration"] = "TextDecoration.underline";
              break;
            }
            console.log(`text-decoration ignored: ${value}`);
            break;
          }
          case "-webkit-font-smoothing":
          case "content": {
            // ignore
            break;
          }
          default:
            console.log(`prop ignored: ${key}`);
        }
      });

      let scope = item["scope"];
      if (!scope) {
        Object.assign(root, style);
        return;
      }
      if (typeof scope == "string") {
        scope = [scope];
      }

      scope.forEach((scope) => {
        const hlScope = tmHlScopeMap[scope];
        if (hlScope) {
          obj[hlScope] = style;
        } else {
          ignoredStyles[scope] = style;
          // console.log(`scope ignored: ${scope}`);
        }
      });
    });

    if (!root["backgroundColor"]) {
      root["backgroundColor"] = convertColor(
        theme["colors"]?.["editor.background"],
      );
    }
    if (!root["color"]) {
      root["color"] = convertColor(
        theme["colors"]?.["foreground"] ??
        theme["colors"]?.["editor.foreground"],
      );
    }

    const tmHlScopeMapEntries = Object.entries(tmHlScopeMap).sort(
      ([a, _], [b, __]) => b.length - a.length,
    );
    const ignoredStyleEntries = Object.entries(ignoredStyles).sort(
      ([a, _], [b, __]) => a.length - b.length,
    );
    for (const [scope, style] of ignoredStyleEntries) {
      for (const [tmScope, hlScope] of tmHlScopeMapEntries) {
        if (scope.startsWith(tmScope) && !obj[hlScope]) {
          obj[hlScope] = style;
          break;
        }
      }
    }

    const keywordScopes = [
      "keyword",
      "type",
      "doctag",
      "template-tag",
      "template-variable",
      "variable.language_",
    ];
    for (const scope of keywordScopes) {
      if (!obj[scope]) {
        for (const s of keywordScopes) {
          if (obj[s]) {
            obj[scope] = obj[s];
            break;
          }
        }
      }
    }
    const titleScopes = [
      "title",
      "title.class_",
      "title.class_.inherited__",
      "title.function_",
    ];
    for (const scope of titleScopes) {
      if (!obj[scope]) {
        for (const s of titleScopes) {
          if (obj[s]) {
            obj[scope] = obj[s];
            break;
          }
        }
      }
      if (obj[scope]?.["fontStyle"] === "FontStyle.italic") {
        obj[scope]["fontStyle"] = "FontStyle.normal";
      }
    }
    if (!obj["attribute"]) {
      if (obj["attr"]) {
        obj["attribute"] = obj["attr"];
      }
    }
    const literalScopes = [
      "literal",
      "variable",
      "operator",
      "number",
      "meta",
      "attr",
      "attribute",
      "selector-attr",
      "selector-class",
      "selector-id",
    ];
    for (const scope of literalScopes) {
      if (!obj[scope]) {
        for (const s of literalScopes) {
          if (obj[s]) {
            obj[scope] = obj[s];
            break;
          }
        }
      }
    }
    if (!obj["regexp"]) {
      if (obj["string"]) {
        obj["regexp"] = obj["string"];
      }
    }
    const commentScopes = ["comment", "code", "formula"];
    for (const scope of commentScopes) {
      if (!obj[scope]) {
        for (const s of commentScopes) {
          if (obj[s]) {
            obj[scope] = obj[s];
            break;
          }
        }
      }
    }
    const symbolScopes = ["symbol", "built_in"];
    for (const scope of symbolScopes) {
      if (!obj[scope]) {
        for (const s of symbolScopes) {
          if (obj[s]) {
            obj[scope] = obj[s];
            break;
          }
        }
      }
      if (obj[scope]?.["fontStyle"] === "FontStyle.italic") {
        obj[scope]["fontStyle"] = "FontStyle.normal";
      }
    }
    const nameScopes = ["name", "quote", "selector-tag", "selector-pseudo"];
    for (const scope of nameScopes) {
      if (!obj[scope]) {
        for (const s of nameScopes) {
          if (obj[s]) {
            obj[scope] = obj[s];
            break;
          }
        }
      }
    }

    let code = `
      ${NOTICE_COMMENT}
      // ignore_for_file: file_names

      import 'package:flutter/painting.dart';
      const ${varName} = {`;
    Object.entries(obj).forEach(([selector, v]) => {
      code += `'${selector}': TextStyle(${Object.entries(v)
        .map(([k, v]) => `${k}:${v}`)
        .join(",")}),`;
    });
    code += "};";

    fs.writeFileSync(path.resolve(destDir, `${fileName}.dart`), code);
  });

  all[1] += "};";
  fs.writeFileSync(
    `${pathToFlutterHighlighting}/lib/tm_themes/theme_map.dart`,
    all.join("\n"),
  );
}

style();
