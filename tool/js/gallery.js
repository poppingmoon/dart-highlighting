import fs from "fs";
import path from "path";

import { NOTICE_COMMENT } from "./common.js";

export function example() {
  // Generate code example dart files
  let code = `
    ${NOTICE_COMMENT}
    // ignore_for_file: lines_longer_than_80_chars

    const exampleMap = {`;
  // ["dart"]
  fs.readdirSync("../vendor/highlight.js/test/detect").forEach(langName => {
    if (langName.endsWith(".js")) return;

    const content = fs
      .readFileSync(
        path.resolve(
          "../vendor/highlight.js/test/detect",
          langName,
          "default.txt"
        ),
        "utf8"
      )
      .replace(/\\/g, "\\\\")
      .replace(/'/g, "\\'")
      .replace(/\$/g, "\\$")
      .replace(/\n/g, "\\n");
    code += `'${langName}':'${content}',`;
  });
  code += "};";
  fs.writeFileSync("../flutter_highlighting/example/lib/example_map.dart", code);
}

example()
