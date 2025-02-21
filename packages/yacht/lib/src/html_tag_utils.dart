library;

//
// tags
//

List<String> voidTags = [
  'area',
  'base',
  'br',
  'col',
  'embed',
  'hr',
  'img',
  'input',
  'keygen',
  'link',
  'menuitem',
  'meta',
  'param',
  'source',
  'track',
  'wbr'
];

// source https://developer.mozilla.org/en/docs/Web/HTML/Inline_elemente
List<String> inlineTags = [
  'b',
  'big',
  'i',
  'small',
  'tt',
  'abbr',
  'acronym',
  'cite',
  'code',
  'dfn',
  'em',
  'kbd',
  'strong',
  'samp',
  'time',
  'var',
  'a',
  'bdo',
  'br',
  'img',
  'map',
  'object',
  'q',
  'script',
  'span',
  'sub',
  'sup',
  'button',
  'input',
  'label',
  'select',
  'textarea'
];

List<String> innerInlineTags = [
  'meta', 'title', 'link', // for head
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6', // for title
  ...inlineTags
];

// private definition
List<String> rawTags = ['script', 'style'];

bool isHeadTag(String tag) {
  switch (tag) {
    case 'meta':
    case 'title':
    case 'link':
    case 'style':
    case 'script':
    case 'noscript':
    case 'base':
      return true;
  }
  return false;
}
