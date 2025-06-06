import fs from "fs";
import path from "path";
import _ from "lodash";
import postcss from "postcss";
import { NOTICE_COMMENT } from "./common.js";
import { convertColor } from "./color.js";

const pathToNodeModules = "../node_modules";
const pathToFlutterHighlighting = "../../flutter_highlighting";

const rootDir = `${pathToNodeModules}/highlight.js/styles`;
const destDir = `${pathToFlutterHighlighting}/lib/themes`;

function normalizeThemeName(name) {
  if (/^\d/.test(name)) {
    name = "theme" + name;
  }
  return _.camelCase(name + "Theme").replace(/a11y/i, "a11y");
}

/**
 * flutter_highlight/lib/themes/*
 * flutter_highlight/lib/theme_map.dart
 */
export function style() {
  let all = [NOTICE_COMMENT, "const themeMap = {"];

  // ["agate.css"]
  fs.readdirSync(rootDir).forEach(file => {
    if (path.extname(file) != ".css") return;
    if (file === "darkula.css") return; // Deprecated
    if (file.endsWith(".min.css")) return;

    const fileName = path.basename(file, ".css");
    const varName = normalizeThemeName(fileName);

    all[0] += `import 'themes/${fileName}.dart';`;
    all[1] += `'${fileName}': ${varName},`;

    const ast = postcss.parse(fs.readFileSync(path.resolve(rootDir, file)));
    // console.log(ast);

    const obj = {};
    const variables = Object();
    ast.walkRules((rule, index) => {
      // FIXME: a11y media query
      if (rule.parent.type === "atrule" && rule.parent.name === "media") {
        return;
      }

      rule.selectors.forEach((selector) => {
        if (/\s+/.test(selector)) {
          // FIXME: nested selector
          console.log(`nested selector: ${selector}`);
          return;
        }
        if (selector === ".hljs") selector = "root";
        selector = selector.replace(".hljs-", "");

        const style = {};
        const localVariables = Object();
        rule.nodes.forEach((item) => {
          if (item.type === "comment") {
            return;
          } else if (item.type === "decl") {
            if (item.prop.startsWith("--")) {
              localVariables[item.prop] = item.value.trim();
              return;
            }
            switch (item.prop) {
              case "color": {
                const flutterColor = convertColor(item.value, {
                  ...variables,
                  ...localVariables,
                });

                if (flutterColor) {
                  style.color = flutterColor;
                }
                break;
              }
              case "background":
              case "background-color": {
                const flutterColor = convertColor(item.value, {
                  ...variables,
                  ...localVariables,
                });
                if (flutterColor) {
                  style.backgroundColor = flutterColor;
                }
                break;
              }
              case "font-style":
                style.fontStyle = `FontStyle.${item.value}`;
                break;
              case "font-weight":
                if (item.value === "bolder") {
                  item.value = "bold"; // FIXME:
                }
                if (item.value === "bold") {
                  style.fontWeight = `FontWeight.bold`;
                  break;
                } else if (item.value === "normal") {
                  style.fontWeight = "FontWeight.normal";
                  break;
                }
                style.fontWeight = `FontWeight.w${item.value}`;
                break;
              case "text-decoration":
                if (item.value === "underline") {
                  style.decoration = "TextDecoration.underline";
                  break;
                }
                console.log(`text-decoration ignored: ${item.value}`);
                break;
              case "background-image":
              case "display":
              case "width":
              case "padding":
                // ignore
                break;
              default:
                console.log(`prop ignored: ${item.prop}`);
            }
          } else {
            console.log(`rule ignored: ${item.type}`);
          }
        });

        if (selector === ":root") {
          Object.assign(variables, localVariables);
        }

        const styleEntries = Object.entries(style);

        if (styleEntries.length) {
          if (!obj[selector]) {
            obj[selector] = style;
          } else {
            Object.assign(obj[selector], style);
          }
        }
      });
    });

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
  fs.writeFileSync(`${pathToFlutterHighlighting}/lib/theme_map.dart`, all.join("\n"));
}

style()
