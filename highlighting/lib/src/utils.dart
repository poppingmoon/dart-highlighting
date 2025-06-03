/// Extends builtin String.substring function
///
/// RangeError: Value not in range
String substring(String input, int startIndex, [int? endIndex]) {
  int start = startIndex;
  int end = endIndex ?? input.length;

  if (start > end) {
    final tmp = start;
    start = end;
    endIndex = tmp;
  }

  if (start < 0 || start > input.length) {
    start = 0;
  }

  if (end < 0 || end > input.length) {
    end = input.length;
  }

  return input.substring(start, end);
}
