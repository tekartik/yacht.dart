library;

//
// utils
//

///
/// Returns `true` if [rune] represents a whitespace character.
///
/// The definition of whitespace matches that used in [String.trim] which is
/// based on Unicode 6.2. This maybe be a different set of characters than the
/// environment's [RegExp] definition for whitespace, which is given by the
/// ECMAScript standard: http://ecma-international.org/ecma-262/5.1/#sec-15.10
///
/// from quiver
///
bool isWhitespace(int rune) => ((rune >= 0x0009 && rune <= 0x000D) ||
    rune == 0x0020 ||
    rune == 0x0085 ||
    rune == 0x00A0 ||
    rune == 0x1680 ||
    rune == 0x180E ||
    (rune >= 0x2000 && rune <= 0x200A) ||
    rune == 0x2028 ||
    rune == 0x2029 ||
    rune == 0x202F ||
    rune == 0x205F ||
    rune == 0x3000 ||
    rune == 0xFEFF);

bool beginsWithWhitespaces(String text) {
  if (text.isEmpty) {
    return false;
  }
  return isWhitespace(text.runes.first);
}

bool endsWithWhitespaces(String text) {
  if (text.isEmpty) {
    return false;
  }
  return isWhitespace(text.runes.last);
}

bool beginOrEndWithWhiteSpace(String text) {
  if (text.isEmpty) {
    return false;
  }
  var runes = text.runes;
  return isWhitespace(runes.first) || isWhitespace(runes.last);
}

// Character constants.
const int _lf = 10;
const int _cr = 13;

bool hasLineFeed(String text) {
  return (text.codeUnits.contains(_cr) || text.codeUnits.contains(_lf));
}

bool isSingleLineText(String text) => !hasLineFeed(text);

bool isWhitespaceLine(String text) {
  return text.trim().isEmpty;
}

List<String> _wordSplit(String input) {
  var out = <String>[];
  var sb = StringBuffer();

  void addCurrent() {
    if (sb.length > 0) {
      out.add(sb.toString());
      sb = StringBuffer();
    }
  }

  for (var rune in input.runes) {
    if (isWhitespace(rune)) {
      addCurrent();
    } else {
      sb.writeCharCode(rune);
    }
  }
  addCurrent();
  return out;
}

/// Trim text
String utilsTrimText(String text, [bool keepExternalSpaces = false]) {
  if (text.isEmpty) {
    return text;
  }
  // remove and/trailing space
  var runes = text.runes;
  var hasWhitespaceBefore = isWhitespace(runes.first);
  var hasWhitespaceAfter = isWhitespace(runes.last);
  var list = _wordSplit(text);
  var sb = StringBuffer();
  if (keepExternalSpaces && hasWhitespaceBefore) {
    sb.write(' ');
  }
  if (list.isNotEmpty) {
    sb.write(list.join(' '));
    if (keepExternalSpaces && hasWhitespaceAfter) {
      sb.write(' ');
    }
  }
  return sb.toString();
}
