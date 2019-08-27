import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

import 'image_properties.dart';

typedef CustomRender = Widget Function(dom.Node node, List<Widget> children);
typedef CustomTextStyle = TextStyle Function(
  dom.Node node,
  TextStyle baseStyle,
);
typedef CustomTextAlign = TextAlign Function(dom.Element elem);
typedef CustomEdgeInsets = EdgeInsets Function(dom.Node node);
typedef OnLinkTap = void Function(String url);
typedef OnImageTap = void Function(String source);

const OFFSET_TAGS_FONT_SIZE_FACTOR =
    0.7; //The ratio of the parent font for each of the offset tags: sup or sub

const subsupcode = {    ' ': [' ', ' '], '0': ['\u2070', '\u2080'],    '1': ['\u00B9', '\u2081'],    '2': ['\u00B2', '\u2082'],    '3': ['\u00B3', '\u2083'],    '4': ['\u2074', '\u2084'],    '5': ['\u2075', '\u2085'],    '6': ['\u2076', '\u2086'],    '7': ['\u2077', '\u2087'],    '8': ['\u2078', '\u2088'],    '9': ['\u2079', '\u2089'],    'a': ['\u1d43', '\u2090'],    'b': ['\u1d47', '\u2086'],    'c': ['\u1d9c', '\ua700'],    'd': ['\u1d48', '\u2094'],    'e': ['\u1d49', '\u2091'],    'f': ['\u1da0', '\u0532'],    'g': ['\u1d4d', '\u2089'],    'h': ['\u02b0', '\u2095'],    'i': ['\u2071', '\u1d62'],    'j': ['\u02b2', '\u2c7c'],    'k': ['\u1d4f', '\u2096'],    'l': ['\u02e1', '\u2097'],    'm': ['\u1d50', '\u2098'],    'n': ['\u207f', '\u2099'],    'o': ['\u1d52', '\u2092'],    'p': ['\u1d56', '\u209a'],    'q': ['?', '?'],    'r': ['\u02b3', '\u1d63'],    's': ['\u02e2', '\u209b'],    't': ['\u1d57', '\u209c'],    'u': ['\u1d58', '\u1d64'],    'v': ['\u1d5b', '\u1d65'],    'w': ['\u02b7', '\u1d65\u1d65'],    'x': ['\u02e3', '\u2093'],    'y': ['\u02b8', '\u1d67'],    'z': ['\u1dbb', '\u2082'],    'A': ['\u1d2c', '\2090'],    'B': ['\u1d2e', '\u2088'],    'C': ['\u1d9c', '\ua700'],    'D': ['\u1d30', '\u2094'],    'E': ['\u1d31', '\u2091'],    'F': ['\u1da0', '\u0532'],    'G': ['\u1d33', '\u2089'],    'H': ['\u1d34', '\u2095'],    'I': ['\u1d35', '\u1d62'],    'J': ['\u1d36', '\u2c7c'],    'K': ['\u1d37', '\u2096'],    'L': ['\u1d38', '\u2097'],    'M': ['\u1d39', '\u2098'],    'N': ['\u1d3a', '\u2099'],    'O': ['\u1d3c', '\u2092'],    'P': ['\u1d3e', '\u209a'],    'Q': ['?', '?'],    'R': ['\u1d3f', '\u1d63'],    'S': ['\u02e2', '\u209b'],    'T': ['\u1d40', '\u209c'],    'U': ['\u1d41', '\u1d64'],    'V': ['\u2c7d', '\u1d65'],    'W': ['\u1d42', '\u1d65\u1d65'],    'X': ['\u02e3', '\u2093'],    'Y': ['\u02b8', '\u1d67'],    'Z': ['\u1dbb', '\u2082'],    '+': ['\u207A', '\u208A'],    '-': ['\u207B', '\u208B'],    '=': ['\u207C', '\u208C'],    '(': ['\u207D', '\u208D'],    ']': ['\u207E', '\u208E'],    ':alpha': ['\u1d45', '?'],    ':beta': ['\u1d5d', '\u1d66'],    ':gamma': ['\u1d5e', '\u1d67'],    ':delta': ['\u1d5f', '?'],    ':epsilon': ['\u1d4b', '?'],    ':theta': ['\u1dbf', '?'],    ':iota': ['\u1da5', '?'],    ':pho': ['?', '\u1d68'],    ':phi': ['\u1db2', '?'],    ':psi': ['\u1d60', '\u1d69'],    ':chi': ['\u1d61', '\u1d6a'],    ':coffee': ['\u2615', '\u2615']};
Iterable<String> subsupcodekeys = subsupcode.keys.toList().reversed;
const namedColors = {"AliceBlue": "#F0F8FF","AntiqueWhite": "#FAEBD7","Aqua": "#00FFFF","Aquamarine": "#7FFFD4","Azure": "#F0FFFF","Beige": "#F5F5DC","Bisque": "#FFE4C4","Black": "#000000","BlanchedAlmond": "#FFEBCD","Blue": "#0000FF","BlueViolet": "#8A2BE2","Brown": "#A52A2A","BurlyWood": "#DEB887","CadetBlue": "#5F9EA0","Chartreuse": "#7FFF00","Chocolate": "#D2691E","Coral": "#FF7F50","CornflowerBlue": "#6495ED","Cornsilk": "#FFF8DC","Crimson": "#DC143C","Cyan": "#00FFFF","DarkBlue": "#00008B","DarkCyan": "#008B8B","DarkGoldenRod": "#B8860B","DarkGray": "#A9A9A9","DarkGrey": "#A9A9A9","DarkGreen": "#006400","DarkKhaki": "#BDB76B","DarkMagenta": "#8B008B","DarkOliveGreen": "#556B2F","DarkOrange": "#FF8C00","DarkOrchid": "#9932CC","DarkRed": "#8B0000","DarkSalmon": "#E9967A","DarkSeaGreen": "#8FBC8F","DarkSlateBlue": "#483D8B","DarkSlateGray": "#2F4F4F","DarkSlateGrey": "#2F4F4F","DarkTurquoise": "#00CED1","DarkViolet": "#9400D3","DeepPink": "#FF1493","DeepSkyBlue": "#00BFFF","DimGray": "#696969","DimGrey": "#696969","DodgerBlue": "#1E90FF","FireBrick": "#B22222","FloralWhite": "#FFFAF0","ForestGreen": "#228B22","Fuchsia": "#FF00FF","Gainsboro": "#DCDCDC","GhostWhite": "#F8F8FF","Gold": "#FFD700","GoldenRod": "#DAA520","Gray": "#808080","Grey": "#808080","Green": "#008000","GreenYellow": "#ADFF2F","HoneyDew": "#F0FFF0","HotPink": "#FF69B4","IndianRed ": "#CD5C5C","Indigo ": "#4B0082","Ivory": "#FFFFF0","Khaki": "#F0E68C","Lavender": "#E6E6FA","LavenderBlush": "#FFF0F5","LawnGreen": "#7CFC00","LemonChiffon": "#FFFACD","LightBlue": "#ADD8E6","LightCoral": "#F08080","LightCyan": "#E0FFFF","LightGoldenRodYellow": "#FAFAD2","LightGray": "#D3D3D3","LightGrey": "#D3D3D3","LightGreen": "#90EE90","LightPink": "#FFB6C1","LightSalmon": "#FFA07A","LightSeaGreen": "#20B2AA","LightSkyBlue": "#87CEFA","LightSlateGray": "#778899","LightSlateGrey": "#778899","LightSteelBlue": "#B0C4DE","LightYellow": "#FFFFE0","Lime": "#00FF00","LimeGreen": "#32CD32","Linen": "#FAF0E6","Magenta": "#FF00FF","Maroon": "#800000","MediumAquaMarine": "#66CDAA","MediumBlue": "#0000CD","MediumOrchid": "#BA55D3","MediumPurple": "#9370DB","MediumSeaGreen": "#3CB371","MediumSlateBlue": "#7B68EE","MediumSpringGreen": "#00FA9A","MediumTurquoise": "#48D1CC","MediumVioletRed": "#C71585","MidnightBlue": "#191970","MintCream": "#F5FFFA","MistyRose": "#FFE4E1","Moccasin": "#FFE4B5","NavajoWhite": "#FFDEAD","Navy": "#000080","OldLace": "#FDF5E6","Olive": "#808000","OliveDrab": "#6B8E23","Orange": "#FFA500","OrangeRed": "#FF4500","Orchid": "#DA70D6","PaleGoldenRod": "#EEE8AA","PaleGreen": "#98FB98","PaleTurquoise": "#AFEEEE","PaleVioletRed": "#DB7093","PapayaWhip": "#FFEFD5","PeachPuff": "#FFDAB9","Peru": "#CD853F","Pink": "#FFC0CB","Plum": "#DDA0DD","PowderBlue": "#B0E0E6","Purple": "#800080","RebeccaPurple": "#663399","Red": "#FF0000","RosyBrown": "#BC8F8F","RoyalBlue": "#4169E1","SaddleBrown": "#8B4513","Salmon": "#FA8072","SandyBrown": "#F4A460","SeaGreen": "#2E8B57","SeaShell": "#FFF5EE","Sienna": "#A0522D","Silver": "#C0C0C0","SkyBlue": "#87CEEB","SlateBlue": "#6A5ACD","SlateGray": "#708090","SlateGrey": "#708090","Snow": "#FFFAFA","SpringGreen": "#00FF7F","SteelBlue": "#4682B4","Tan": "#D2B48C","Teal": "#008080","Thistle": "#D8BFD8","Tomato": "#FF6347","Turquoise": "#40E0D0","Violet": "#EE82EE","Wheat": "#F5DEB3","White": "#FFFFFF","WhiteSmoke": "#F5F5F5","Yellow": "#FFFF00","YellowGreen": "#9ACD32","aliceblue": "#f0f8ff","antiquewhite": "#faebd7","aqua": "#00ffff","aquamarine": "#7fffd4","azure": "#f0ffff","beige": "#f5f5dc","bisque": "#ffe4c4","black": "#000000","blanchedalmond": "#ffebcd","blue": "#0000ff","blueviolet": "#8a2be2","brown": "#a52a2a","burlywood": "#deb887","cadetblue": "#5f9ea0","chartreuse": "#7fff00","chocolate": "#d2691e","coral": "#ff7f50","cornflowerblue": "#6495ed","cornsilk": "#fff8dc","crimson": "#dc143c","cyan": "#00ffff","darkblue": "#00008b","darkcyan": "#008b8b","darkgoldenrod": "#b8860b","darkgray": "#a9a9a9","darkgrey": "#a9a9a9","darkgreen": "#006400","darkkhaki": "#bdb76b","darkmagenta": "#8b008b","darkolivegreen": "#556b2f","darkorange": "#ff8c00","darkorchid": "#9932cc","darkred": "#8b0000","darksalmon": "#e9967a","darkseagreen": "#8fbc8f","darkslateblue": "#483d8b","darkslategray": "#2f4f4f","darkslategrey": "#2f4f4f","darkturquoise": "#00ced1","darkviolet": "#9400d3","deeppink": "#ff1493","deepskyblue": "#00bfff","dimgray": "#696969","dimgrey": "#696969","dodgerblue": "#1e90ff","firebrick": "#b22222","floralwhite": "#fffaf0","forestgreen": "#228b22","fuchsia": "#ff00ff","gainsboro": "#dcdcdc","ghostwhite": "#f8f8ff","gold": "#ffd700","goldenrod": "#daa520","gray": "#808080","grey": "#808080","green": "#008000","greenyellow": "#adff2f","honeydew": "#f0fff0","hotpink": "#ff69b4","indianred ": "#cd5c5c","indigo ": "#4b0082","ivory": "#fffff0","khaki": "#f0e68c","lavender": "#e6e6fa","lavenderblush": "#fff0f5","lawngreen": "#7cfc00","lemonchiffon": "#fffacd","lightblue": "#add8e6","lightcoral": "#f08080","lightcyan": "#e0ffff","lightgoldenrodyellow": "#fafad2","lightgray": "#d3d3d3","lightgrey": "#d3d3d3","lightgreen": "#90ee90","lightpink": "#ffb6c1","lightsalmon": "#ffa07a","lightseagreen": "#20b2aa","lightskyblue": "#87cefa","lightslategray": "#778899","lightslategrey": "#778899","lightsteelblue": "#b0c4de","lightyellow": "#ffffe0","lime": "#00ff00","limegreen": "#32cd32","linen": "#faf0e6","magenta": "#ff00ff","maroon": "#800000","mediumaquamarine": "#66cdaa","mediumblue": "#0000cd","mediumorchid": "#ba55d3","mediumpurple": "#9370db","mediumseagreen": "#3cb371","mediumslateblue": "#7b68ee","mediumspringgreen": "#00fa9a","mediumturquoise": "#48d1cc","mediumvioletred": "#c71585","midnightblue": "#191970","mintcream": "#f5fffa","mistyrose": "#ffe4e1","moccasin": "#ffe4b5","navajowhite": "#ffdead","navy": "#000080","oldlace": "#fdf5e6","olive": "#808000","olivedrab": "#6b8e23","orange": "#ffa500","orangered": "#ff4500","orchid": "#da70d6","palegoldenrod": "#eee8aa","palegreen": "#98fb98","paleturquoise": "#afeeee","palevioletred": "#db7093","papayawhip": "#ffefd5","peachpuff": "#ffdab9","peru": "#cd853f","pink": "#ffc0cb","plum": "#dda0dd","powderblue": "#b0e0e6","purple": "#800080","rebeccapurple": "#663399","red": "#ff0000","rosybrown": "#bc8f8f","royalblue": "#4169e1","saddlebrown": "#8b4513","salmon": "#fa8072","sandybrown": "#f4a460","seagreen": "#2e8b57","seashell": "#fff5ee","sienna": "#a0522d","silver": "#c0c0c0","skyblue": "#87ceeb","slateblue": "#6a5acd","slategray": "#708090","slategrey": "#708090","snow": "#fffafa","springgreen": "#00ff7f","steelblue": "#4682b4","tan": "#d2b48c","teal": "#008080","thistle": "#d8bfd8","tomato": "#ff6347","turquoise": "#40e0d0","violet": "#ee82ee","wheat": "#f5deb3","white": "#ffffff","whitesmoke": "#f5f5f5","yellow": "#ffff00","yellowgreen": "#9acd32"};

class LinkTextSpan extends TextSpan {
  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.
  final String url;

  LinkTextSpan(
      {TextStyle style,
      this.url,
      String text,
      OnLinkTap onLinkTap,
      List<TextSpan> children})
      : super(
          style: style,
          text: text,
          children: children ?? <TextSpan>[],
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onLinkTap(url);
            },
        );
}

class LinkBlock extends Container {
  // final String url;
  // final EdgeInsets padding;
  // final EdgeInsets margin;
  // final OnLinkTap onLinkTap;
  final List<Widget> children;

  LinkBlock({
    String url,
    EdgeInsets padding,
    EdgeInsets margin,
    OnLinkTap onLinkTap,
    this.children,
  }) : super(
          padding: padding,
          margin: margin,
          child: GestureDetector(
            onTap: () {
              onLinkTap(url);
            },
            child: Column(
              children: children,
            ),
          ),
        );
}

class BlockText extends StatelessWidget {
  final RichText child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final String leadingChar;
  final Decoration decoration;

  BlockText({
    @required this.child,
    this.padding,
    this.margin,
    this.leadingChar = '',
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: this.padding,
      margin: this.margin,
      decoration: this.decoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          leadingChar.isNotEmpty ? Text(leadingChar) : Container(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ParseContext {
  List<dynamic> rootWidgetList; // the widgetList accumulator
  dynamic parentElement; // the parent spans accumulator
  int indentLevel = 0;
  int listCount = 0;
  String listChar = '•';
  String blockType; // blockType can be 'p', 'div', 'ul', 'ol', 'blockquote'
  bool condenseWhitespace = true;
  bool spansOnly = false;
  bool inBlock = false;
  TextStyle childStyle;

  ParseContext({
    this.rootWidgetList,
    this.parentElement,
    this.indentLevel = 0,
    this.listCount = 0,
    this.listChar = '•',
    this.blockType,
    this.condenseWhitespace = true,
    this.spansOnly = false,
    this.inBlock = false,
    this.childStyle,
  }) {
    childStyle = childStyle ?? TextStyle();
  }

  ParseContext.fromContext(ParseContext parseContext) {
    rootWidgetList = parseContext.rootWidgetList;
    parentElement = parseContext.parentElement;
    indentLevel = parseContext.indentLevel;
    listCount = parseContext.listCount;
    listChar = parseContext.listChar;
    blockType = parseContext.blockType;
    condenseWhitespace = parseContext.condenseWhitespace;
    spansOnly = parseContext.spansOnly;
    inBlock = parseContext.inBlock;
    childStyle = parseContext.childStyle ?? TextStyle();
  }
}

class HtmlRichTextParser extends StatelessWidget {
  HtmlRichTextParser({
    @required this.width,
    this.onLinkTap,
    this.renderNewlines = false,
    this.html,
    this.customEdgeInsets,
    this.customTextStyle,
    this.customTextAlign,
    this.onImageError,
    this.linkStyle = const TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blueAccent,
      decorationColor: Colors.blueAccent,
    ),
    this.imageProperties,
    this.onImageTap,
    this.showImages = true,
  });

  final double indentSize = 10.0;

  final double width;
  final onLinkTap;
  final bool renderNewlines;
  final String html;
  final CustomEdgeInsets customEdgeInsets;
  final CustomTextStyle customTextStyle;
  final CustomTextAlign customTextAlign;
  final ImageErrorListener onImageError;
  final TextStyle linkStyle;
  final ImageProperties imageProperties;
  final OnImageTap onImageTap;
  final bool showImages;

  // style elements set a default style
  // for all child nodes
  // treat ol, ul, and blockquote like style elements also
  static const _supportedStyleElements = [
    "b",
    "i",
    "address",
    "cite",
    "var",
    "em",
    "strong",
    "kbd",
    "samp",
    "tt",
    "code",
    "ins",
    "u",
    "small",
    "abbr",
    "acronym",
    "mark",
    "ol",
    "ul",
    "blockquote",
    "del",
    "s",
    "strike",
    "ruby",
    "rp",
    "rt",
    "bdi",
    "data",
    "time",
    "span",
    "big",
    "color"
  ];

  // specialty elements require unique handling
  // eg. the "a" tag can contain a block of text or an image
  // sometimes "a" will be rendered with a textspan and recognizer
  // sometimes "a" will be rendered with a clickable Block
  static const _supportedSpecialtyElements = [
    "a",
    "br",
    "table",
    "tbody",
    "caption",
    "td",
    "tfoot",
    "th",
    "thead",
    "tr",
    "q",
    "sub",
    "sup"
  ];

  // block elements are always rendered with a new
  // block-level widget, if a block level element
  // is found inside another block level element,
  // we simply treat it as a new block level element
  static const _supportedBlockElements = [
    "article",
    "aside",
    "body",
    "center",
    "dd",
    "dfn",
    "div",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "img",
    "li",
    "main",
    "nav",
    "noscript",
    "p",
    "pre",
    "section",
  ];

  static get _supportedElements => List()
    ..addAll(_supportedStyleElements)
    ..addAll(_supportedSpecialtyElements)
    ..addAll(_supportedBlockElements);

  // this function is called recursively for each child
  // however, the first time it is called, we make sure
  // to ignore the node itself, so we only pay attention
  // to the children
  bool _hasBlockChild(dom.Node node, {bool ignoreSelf = true}) {
    bool retval = false;
    if (node is dom.Element) {
      if (_supportedBlockElements.contains(node.localName) && !ignoreSelf)
        return true;
      node.nodes.forEach((dom.Node node) {
        if (_hasBlockChild(node, ignoreSelf: false)) retval = true;
      });
    }
    return retval;
  }

  // Parses an html string and returns a list of RichText widgets that represent the body of your html document.

  @override
  Widget build(BuildContext context) {
    String data = html;

    if (renderNewlines) {
      data = data.replaceAll("\n", "<br />");
    }
    dom.Document document = parser.parse(data);
    dom.Node body = document.body;

    List<Widget> widgetList = new List<Widget>();
    ParseContext parseContext = ParseContext(
      rootWidgetList: widgetList,
      childStyle: DefaultTextStyle.of(context).style,
    );

    // don't ignore the top level "body"
    _parseNode(body, parseContext, context);

    // filter out empty widgets
    List<Widget> children = [];
    widgetList.forEach((dynamic w) {
      if (w is BlockText) {
        if (w.child.text == null) return;
        TextSpan childTextSpan = w.child.text;
        if ((childTextSpan.text == null || childTextSpan.text.isEmpty) &&
            (childTextSpan.children == null || childTextSpan.children.isEmpty))
          return;
      } else if (w is LinkBlock) {
        if (w.children.isEmpty) return;
      } else if (w is LinkTextSpan) {
        if (w.text.isEmpty && w.children.isEmpty) return;
      }
      children.add(w);
    });

    return Column(
      children: children,
    );
  }

  // THE WORKHORSE FUNCTION!!
  // call the function with the current node and a ParseContext
  // the ParseContext is used to do a number of things
  // first, since we call this function recursively, the parseContext holds references to
  // all the data that is relevant to a particular iteration and its child iterations
  // it holds information about whether to indent the text, whether we are in a list, etc.
  //
  // secondly, it holds the 'global' widgetList that accumulates all the block-level widgets
  //
  // thirdly, it holds a reference to the most recent "parent" so that this iteration of the
  // function can add child nodes to the parent if it should
  //
  // each iteration creates a new parseContext as a copy of the previous one if it needs to
  void _parseNode(
      dom.Node node, ParseContext parseContext, BuildContext buildContext) {
    // TEXT ONLY NODES
    // a text only node is a child of a tag with no inner html
    if (node is dom.Text) {
      // WHITESPACE CONSIDERATIONS ---
      // truly empty nodes should just be ignored
      if (node.text.trim() == "" && node.text.indexOf(" ") == -1) {
        return;
      }

      // we might want to preserve internal whitespace
      // empty strings of whitespace might be significant or not, condense it by default
      String finalText = node.text;
      if (parseContext.condenseWhitespace) {
        finalText = condenseHtmlWhitespace(node.text);

        // if this is part of a string of spans, we will preserve leading
        // and trailing whitespace unless the previous character is whitespace
        if (parseContext.parentElement == null)
          finalText = finalText.trimLeft();
        else if (parseContext.parentElement is TextSpan ||
            parseContext.parentElement is LinkTextSpan) {
          String lastString = parseContext.parentElement.text ?? '';
          if (!parseContext.parentElement.children.isEmpty) {
            lastString = parseContext.parentElement.children.last.text ?? '';
          }
          if (lastString.endsWith(' ') || lastString.endsWith('\n')) {
            finalText = finalText.trimLeft();
          }
        }
      }

      // if the finalText is actually empty, just return (unless it's just a space)
      if (finalText.trim().isEmpty && finalText != " ") return;

      // NOW WE HAVE OUR TRULY FINAL TEXT
      // debugPrint("Plain Text Node: '$finalText'");

      // create a span by default
      TextSpan span = TextSpan(
          text: finalText,
          children: <TextSpan>[],
          style: parseContext.childStyle);

      // in this class, a ParentElement must be a BlockText, LinkTextSpan, Row, Column, TextSpan

      // the parseContext might actually be a block level style element, so we
      // need to honor the indent and styling specified by that block style.
      // e.g. ol, ul, blockquote
      bool treatLikeBlock =
          ['blockquote', 'ul', 'ol'].indexOf(parseContext.blockType) != -1;

      // if there is no parentElement, contain the span in a BlockText
      if (parseContext.parentElement == null) {
        // if this is inside a context that should be treated like a block
        // but the context is not actually a block, create a block
        // and append it to the root widget tree
        if (treatLikeBlock) {
          Decoration decoration;
          if (parseContext.blockType == 'blockquote') {
            decoration = BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.black38, width: 2.0)),
            );
            parseContext.childStyle = parseContext.childStyle.merge(TextStyle(
              fontStyle: FontStyle.italic,
            ));
          }
          BlockText blockText = BlockText(
            margin: EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: parseContext.indentLevel * indentSize),
            padding: EdgeInsets.all(2.0),
            decoration: decoration,
            child: RichText(
              textAlign: TextAlign.left,
              text: span,
            ),
          );
          parseContext.rootWidgetList.add(blockText);
        } else {
          parseContext.rootWidgetList
              .add(BlockText(child: RichText(text: span)));
        }

        // this allows future items to be added as children of this item
        parseContext.parentElement = span;

        // if the parent is a LinkTextSpan, keep the main attributes of that span going.
      } else if (parseContext.parentElement is LinkTextSpan) {
        // add this node to the parent as another LinkTextSpan
        parseContext.parentElement.children.add(LinkTextSpan(
          style:
              parseContext.parentElement.style.merge(parseContext.childStyle),
          url: parseContext.parentElement.url,
          text: finalText,
          onLinkTap: onLinkTap,
        ));

      } else if (parseContext.parentElement is List<TableRow>) {
      } else if (!(parseContext.parentElement.children is List<Widget>)) {
        parseContext.parentElement.children.add(span);
      } else {
        // Doing nothing... we shouldn't ever get here
      }
      return;
    }

    // OTHER ELEMENT NODES
    else if (node is dom.Element) {
      if (!_supportedElements.contains(node.localName)) {
        return;
      }

      // make a copy of the current context so that we can modify
      // pieces of it for the next iteration of this function
      ParseContext nextContext = new ParseContext.fromContext(parseContext);

      TextStyle childStyle = parseContext.childStyle ?? TextStyle();

      try {
        if (node.attributes["style"] != null) {
          node.attributes["style"].split(";").forEach((es) {
            String name = es.split(":")[0].trim();
            String value = es.split(":")[1].trim();
            if (namedColors[value.toLowerCase()] != null) {
              value = namedColors[value.toLowerCase()];
            }
            if ("color" == name) {
              Color textColor = parseColor(value, null);
              childStyle = childStyle.merge(TextStyle(color: textColor));
              nextContext.childStyle = childStyle;
            } else if ("background" == name) {
              Color textColor = parseColor(value, null);
              childStyle = childStyle.merge(TextStyle(backgroundColor: textColor));
              nextContext.childStyle = childStyle;
            }

          });
        }
      } catch (e1) {
        // ignoring exception
      }

      // handle style elements
      if (_supportedStyleElements.contains(node.localName)) {


        switch (node.localName) {
          //"b","i","em","strong","code","u","small","abbr","acronym"
          case "b":
          case "strong":
            childStyle =
                childStyle.merge(TextStyle(fontWeight: FontWeight.bold));
            break;
          case "i":
          case "address":
          case "cite":
          case "var":
          case "em":
            childStyle =
                childStyle.merge(TextStyle(fontStyle: FontStyle.italic));
            break;
          case "kbd":
          case "samp":
          case "tt":
          case "code":
            childStyle = childStyle.merge(TextStyle(fontFamily: 'monospace'));
            break;
          case "ins":
          case "u":
            childStyle = childStyle
                .merge(TextStyle(decoration: TextDecoration.underline));
            break;
          case "abbr":
          case "acronym":
            childStyle = childStyle.merge(TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ));
            break;
          case "big":
            childStyle = childStyle.merge(TextStyle(fontSize: 20.0));
            break;
          case "small":
            childStyle = childStyle.merge(TextStyle(fontSize: 10.0));
            break;
          case "mark":
            childStyle = childStyle.merge(
                TextStyle(backgroundColor: Colors.yellow, color: Colors.black));
            break;
          case "del":
          case "s":
          case "strike":
            childStyle = childStyle
                .merge(TextStyle(decoration: TextDecoration.lineThrough));
            break;
          case "ol":
            nextContext.indentLevel += 1;
            nextContext.listChar = '#';
            nextContext.listCount = 0;
            nextContext.blockType = 'ol';
            break;
          case "ul":
            nextContext.indentLevel += 1;
            nextContext.listChar = '•';
            nextContext.listCount = 0;
            nextContext.blockType = 'ul';
            break;
          case "blockquote":
            nextContext.indentLevel += 1;
            nextContext.blockType = 'blockquote';
            break;
          case "color":
            String colorStr = node.attributes["color"];
            Color color = Colors.black;
            color = parseColor(colorStr, color);
            childStyle = childStyle.merge(TextStyle(color: color));
            break;
          case "ruby":
          case "rt":
          case "rp":
          case "bdi":
          case "data":
          case "time":
          case "span":
            //No additional styles
            break;
        }

        if (customTextStyle != null) {
          final TextStyle customStyle = customTextStyle(node, childStyle);
          if (customStyle != null) {
            childStyle = customStyle;
          }
        }

        nextContext.childStyle = childStyle;
      }

      // handle specialty elements
      else if (_supportedSpecialtyElements.contains(node.localName)) {
        // should support "a","br","table","tbody","thead","tfoot","th","tr","td"

        switch (node.localName) {
          case "sub":
          case "sup":
            TextStyle parentStyle = parseContext.childStyle.merge(TextStyle(fontSize: parseContext.childStyle.fontSize));

            String nodeText = node.text.trim();
            StringBuffer newText = StringBuffer();
            List<String> keysList = subsupcodekeys.toList();
            int index = 0;
            while(nodeText.length > 0 ) {
              if (nodeText.trim().length == 0) {
                break;
              }
              subsupcodekeys.forEach((s) {

                try {
                  if (nodeText.length > 0) {
                    if (nodeText.indexOf(s) == 0) {
                      newText.write(node.localName == "sup"
                          ? subsupcode[s][0]
                          : subsupcode[s][1]);
                      nodeText = nodeText.substring(s.length);
                    }
                  }
                } catch(err) {

                }
              });
              if (nodeText.length > 0) {
                if (subsupcode[nodeText.substring(0, 1)] == null) {
                  nodeText = nodeText.substring(1);
                }
              }
            }
            node.text = ""; // modify to render no child

            TextSpan text = TextSpan(text: newText.toString(), children: <TextSpan>[], style: parentStyle);
            nextContext.parentElement.children.add(text);
            break;
          case "a":
            // if this item has block children, we create
            // a container and gesture recognizer for the entire
            // element, otherwise, we create a LinkTextSpan
            String url = node.attributes['href'] ?? null;

            if (_hasBlockChild(node)) {
              LinkBlock linkContainer = LinkBlock(
                url: url,
                margin: EdgeInsets.only(
                    left: parseContext.indentLevel * indentSize),
                onLinkTap: onLinkTap,
                children: <Widget>[],
              );
              nextContext.parentElement = linkContainer;
              nextContext.rootWidgetList.add(linkContainer);
            } else {
              TextStyle _linkStyle = parseContext.childStyle.merge(linkStyle);
              LinkTextSpan span = LinkTextSpan(
                style: _linkStyle,
                url: url,
                onLinkTap: onLinkTap,
                children: <TextSpan>[],
              );
              if (parseContext.parentElement is TextSpan) {
                nextContext.parentElement.children.add(span);
              } else {
                // start a new block element for this link and its text
                BlockText blockElement = BlockText(
                  margin: EdgeInsets.only(
                      left: parseContext.indentLevel * indentSize, top: 10.0),
                  child: RichText(text: span),
                );
                parseContext.rootWidgetList.add(blockElement);
                nextContext.inBlock = true;
              }
              nextContext.childStyle = linkStyle;
              nextContext.parentElement = span;
            }
            break;

          case "br":
            if (parseContext.parentElement != null &&
                parseContext.parentElement is TextSpan) {
              parseContext.parentElement.children
                  .add(TextSpan(text: '\n', children: []));
            }
            break;

          case "table":
            // new block, so clear out the parent element
            parseContext.parentElement = null;
            nextContext.parentElement = <TableRow>[];
            double border = 0;
            if (node.attributes['border'] != null) {
              border = double.parse(node.attributes['border']);
            }

            if(node.nodes.length > 0 && (node.nodes[0] is dom.Element) && (node.nodes[0] as dom.Element).localName == "caption") {
              String caption = node.nodes[0].children[0].text;
              node.nodes[0].children[0].text = "";
              nextContext.rootWidgetList.add(
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(caption, style: TextStyle(fontWeight: FontWeight.bold),),
                )
              );
            }

            nextContext.rootWidgetList.add(
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Table(
                  border: border > 0 ? TableBorder.all(width: border) : null,
                  children: nextContext.parentElement,
                )
              )
            );
            break;

          // we don't handle tbody, thead, or tfoot elements separately for now
          case "tbody":
          case "thead":
          case "tfoot":
            break;

          case "td":
          case "th":
            int colspan = 1;
            double border = 0;
            if (node.attributes['colspan'] != null) {
              colspan = int.tryParse(node.attributes['colspan']);
            }

            if (node.parent.parent.attributes['border'] != null || node.parent.parent.parent.attributes['border'] != null ) {
              border = double.parse(node.parent.parent.attributes['border']?? node.parent.parent.parent.attributes['border']);
            }
            nextContext.childStyle = nextContext.childStyle.merge(TextStyle(
                fontWeight: (node.localName == 'th')
                    ? FontWeight.bold
                    : FontWeight.normal));

            if (node.localName == "th") {
              print("Bg Color is ${nextContext.childStyle.backgroundColor}");
            }
            RichText text =
                RichText(text: TextSpan(text: '', children: <TextSpan>[], style: nextContext.childStyle));
//            Expanded cell = Expanded(
//              flex: colspan,
//              child: Container(padding: EdgeInsets.all(1.0), child: text),
//            );
            TableCell cell = TableCell(child: Padding(padding: EdgeInsets.all(2), child: text));
            nextContext.parentElement.children.add(cell);
            nextContext.parentElement = text.text;
            break;

          case "tr":

            TableRow row = TableRow(
              children: <Widget>[]
            );
            nextContext.parentElement.add(row);
            nextContext.parentElement = row;
            break;

          // treat captions like a row with one expanded cell
          case "caption":
            // create the row
            // create an expanded cell

            break;
          case "q":
            if (parseContext.parentElement != null &&
                parseContext.parentElement is TextSpan) {
              parseContext.parentElement.children
                  .add(TextSpan(text: '"', children: []));
              TextSpan content = TextSpan(text: '', children: []);
              parseContext.parentElement.children.add(content);
              parseContext.parentElement.children
                  .add(TextSpan(text: '"', children: []));
              nextContext.parentElement = content;
            }
            break;
        }

        if (customTextStyle != null) {
          final TextStyle customStyle =
              customTextStyle(node, nextContext.childStyle);
          if (customStyle != null) {
            nextContext.childStyle = customStyle;
          }
        }
      }

      // handle block elements
      else if (_supportedBlockElements.contains(node.localName)) {
        // block elements only show up at the "root" widget level
        // so if we have a block element, reset the parentElement to null
        parseContext.parentElement = null;
        TextAlign textAlign = TextAlign.left;
        if (customTextAlign != null) {
          textAlign = customTextAlign(node) ?? textAlign;
        }

        EdgeInsets _customEdgeInsets;
        if (customEdgeInsets != null) {
          _customEdgeInsets = customEdgeInsets(node);
        }

        switch (node.localName) {
          case "hr":
            parseContext.rootWidgetList
                .add(Divider(height: 1.0, color: Colors.black38));
            break;
          case "img":
            if (showImages) {
              if (node.attributes['src'] != null) {
                if (node.attributes['src'].startsWith("data:image") &&
                    node.attributes['src'].contains("base64,")) {
                  precacheImage(
                    MemoryImage(
                      base64.decode(
                        node.attributes['src'].split("base64,")[1].trim(),
                      ),
                    ),
                    buildContext,
                    onError: onImageError,
                  );
                  parseContext.rootWidgetList.add(GestureDetector(
                    child: Image.memory(
                      base64.decode(
                          node.attributes['src'].split("base64,")[1].trim()),
                      width: imageProperties?.width ??
                          ((node.attributes['width'] != null)
                              ? double.tryParse(node.attributes['width'])
                              : null),
                      height: imageProperties?.height ??
                          ((node.attributes['height'] != null)
                              ? double.tryParse(node.attributes['height'])
                              : null),
                      scale: imageProperties?.scale ?? 1.0,
                      matchTextDirection:
                          imageProperties?.matchTextDirection ?? false,
                      centerSlice: imageProperties?.centerSlice,
                      filterQuality:
                          imageProperties?.filterQuality ?? FilterQuality.low,
                      alignment: imageProperties?.alignment ?? Alignment.center,
                      colorBlendMode: imageProperties?.colorBlendMode,
                      fit: imageProperties?.fit,
                      color: imageProperties?.color,
                      repeat: imageProperties?.repeat ?? ImageRepeat.noRepeat,
                      semanticLabel: imageProperties?.semanticLabel,
                      excludeFromSemantics:
                          (imageProperties?.semanticLabel == null)
                              ? true
                              : false,
                    ),
                    onTap: () {
                      if (onImageTap != null) {
                        onImageTap(node.attributes['src']);
                      }
                    },
                  ));
                } else {
                  precacheImage(
                    NetworkImage(node.attributes['src']),
                    buildContext,
                    onError: onImageError,
                  );
                  parseContext.rootWidgetList.add(GestureDetector(
                    child: Image.network(
                      node.attributes['src'],
                      width: imageProperties?.width ??
                          ((node.attributes['width'] != null)
                              ? double.parse(node.attributes['width'])
                              : null),
                      height: imageProperties?.height ??
                          ((node.attributes['height'] != null)
                              ? double.parse(node.attributes['height'])
                              : null),
                      scale: imageProperties?.scale ?? 1.0,
                      matchTextDirection:
                          imageProperties?.matchTextDirection ?? false,
                      centerSlice: imageProperties?.centerSlice,
                      filterQuality:
                          imageProperties?.filterQuality ?? FilterQuality.low,
                      alignment: imageProperties?.alignment ?? Alignment.center,
                      colorBlendMode: imageProperties?.colorBlendMode,
                      fit: imageProperties?.fit,
                      color: imageProperties?.color,
                      repeat: imageProperties?.repeat ?? ImageRepeat.noRepeat,
                      semanticLabel: imageProperties?.semanticLabel,
                      excludeFromSemantics:
                          (imageProperties?.semanticLabel == null)
                              ? true
                              : false,
                    ),
                    onTap: () {
                      if (onImageTap != null) {
                        onImageTap(node.attributes['src']);
                      }
                    },
                  ));
                }
                if (node.attributes['alt'] != null) {
                  parseContext.rootWidgetList.add(BlockText(
                      margin:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                      padding: EdgeInsets.all(0.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: node.attributes['alt'],
                            style: nextContext.childStyle,
                            children: <TextSpan>[],
                          ))));
                }
              }
            }
            break;
          case "li":
            String leadingChar = parseContext.listChar;
            if (parseContext.blockType == 'ol') {
              // nextContext will handle nodes under this 'li'
              // but we want to increment the count at this level
              parseContext.listCount += 1;
              leadingChar = parseContext.listCount.toString() + '.';
            }
            BlockText blockText = BlockText(
              margin: EdgeInsets.only(
                  left: parseContext.indentLevel * indentSize, top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: '',
                  style: nextContext.childStyle,
                  children: <TextSpan>[],
                ),
              ),
              leadingChar: '$leadingChar  ',
            );
            parseContext.rootWidgetList.add(blockText);
            nextContext.parentElement = blockText.child.text;
            nextContext.spansOnly = true;
            nextContext.inBlock = true;
            break;

          case "h1":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h2":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h3":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h4":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 20.0, fontWeight: FontWeight.w100),
            );
            continue myDefault;
          case "h5":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h6":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 18.0, fontWeight: FontWeight.w100),
            );
            continue myDefault;

          case "pre":
            nextContext.condenseWhitespace = false;
            continue myDefault;

          case "center":
            textAlign = TextAlign.center;
            // no break here
            continue myDefault;

          myDefault:
          default:
            Decoration decoration;
            if (parseContext.blockType == 'blockquote') {
              decoration = BoxDecoration(
                border:
                    Border(left: BorderSide(color: Colors.black38, width: 2.0)),
              );
              nextContext.childStyle = nextContext.childStyle.merge(TextStyle(
                fontStyle: FontStyle.italic,
              ));
            }
            BlockText blockText = BlockText(
              margin: node.localName != 'body'
                  ? _customEdgeInsets ??
                      EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          left: parseContext.indentLevel * indentSize)
                  : EdgeInsets.zero,
              padding: EdgeInsets.all(2.0),
              decoration: decoration,
              child: RichText(
                textAlign: textAlign,
                text: TextSpan(
                  text: '',
                  style: nextContext.childStyle,
                  children: <TextSpan>[],
                ),
              ),
            );
            parseContext.rootWidgetList.add(blockText);
            nextContext.parentElement = blockText.child.text;
            nextContext.spansOnly = true;
            nextContext.inBlock = true;
        }

        if (customTextStyle != null) {
          final TextStyle customStyle =
              customTextStyle(node, nextContext.childStyle);
          if (customStyle != null) {
            nextContext.childStyle = customStyle;
          }
        }
      }

      node.nodes.forEach((dom.Node childNode) {
        _parseNode(childNode, nextContext, buildContext);
      });
    }
  }

  Paint _getPaint(Color color) {
    Paint paint = new Paint();
    paint.color = color;
    return paint;
  }

  String condenseHtmlWhitespace(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", " ");
    while (stringToTrim.indexOf("  ") != -1) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }

  bool _isNotFirstBreakTag(dom.Node node) {
    int index = node.parentNode.nodes.indexOf(node);
    if (index == 0) {
      if (node.parentNode == null) {
        return false;
      }
      return _isNotFirstBreakTag(node.parentNode);
    } else if (node.parentNode.nodes[index - 1] is dom.Element) {
      if ((node.parentNode.nodes[index - 1] as dom.Element).localName == "br") {
        return true;
      }
      return false;
    } else if (node.parentNode.nodes[index - 1] is dom.Text) {
      if ((node.parentNode.nodes[index - 1] as dom.Text).text.trim() == "") {
        return _isNotFirstBreakTag(node.parentNode.nodes[index - 1]);
      } else {
        return false;
      }
    }
    return false;
  }

  Color parseColor (String colorStr, Color color) {
    if (colorStr.startsWith("#")) {
      if (colorStr.length == 7) {
        color = Color(int.parse("ff${colorStr.substring(1)}", radix: 16));
      } else if (colorStr.length == 9) {
        color = Color(int.parse("${colorStr.substring(1)}", radix: 16));
      }
    }
    return color;
  }
}
