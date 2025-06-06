/**
 * white, #fff, #ffffff, rgba(0,0,0,0) -> Flutter color
 */
export function convertColor(
  color: string,
  variables: Record<string, string> = {},
): string | undefined {
  if (color === "inherit") return;
  if (color.startsWith("rgba(")) return `Color.fromRGBO${color.slice(4)}`;

  let match = color.match(/^var\(([^)]*)/);
  if (match) {
    color = variables[match[1]] ?? color;
  }

  let rgb = "";

  if (color.includes("url(")) {
    // Find the first pattern matches CSS color
    // FIXME: background image
    const c = /#[0-9a-fA-F]{3,6}/.exec(color);
    if (!c) return;
    rgb = c[0].slice(1);
  } else if (color === "white") {
    rgb = "ffffff";
  } else if (color === "black") {
    rgb = "000000";
  } else if (color === "navy") {
    rgb = "000080";
  } else if (color === "gold") {
    rgb = "ffd700";
  } else if (color.startsWith("#")) {
    rgb = color.slice(1).toLowerCase();
    if (rgb.length === 3) {
      rgb = rgb
        .split("")
        .map((x) => x + x)
        .join("");
    } else if (rgb.length === 4) {
      const argb = [rgb[3], rgb[0], rgb[1], rgb[2]]
        .map((x) => x.repeat(2))
        .join("");
      return `Color(0x${argb})`;
    } else if (rgb.length === 8) {
      return `Color(0x${rgb})`;
    }
  }

  if (rgb) {
    return `Color(0xff${rgb})`;
  } else {
    console.log(`color ignored: ${color}`);
    return undefined;
  }
}
