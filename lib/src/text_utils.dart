library yacht.src.text_utils.dart;

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

bool beginWithWhiteSpace(String text) {
  return isWhitespace(text.runes.first);
}

bool endWithWhiteSpace(String text) {
  return isWhitespace(text.runes.last);
}

// Character constants.
const int _LF = 10;
const int _CR = 13;

bool hasLineFeed(String text) {
  return (text.codeUnits.contains(_CR) || text.codeUnits.contains(_LF));
}

bool isSingleLineText(String text) => !hasLineFeed(text);

bool isWhitespaceLine(String text) {
  return text.trim().isEmpty;
}
