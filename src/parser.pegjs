{
var Type = require('./type');
require('./primitive-type');
require('./any-type');
require('./array-type');
require('./property-type');
require('./object-type');
require('./oneof-type');
require('./procedure-type');
require('./type-trait');

function objectHelper(keyvals) {
  var result = {};
  for (var i = 0; i < keyvals.length; ++i) {
    result[keyvals[i][0]] = keyvals[i][1];
  }
  return result;
}

function numberHelper(num, frac, exp) {
  return parseFloat([num, frac, exp].join(''));
}

}
/************************************************************************
TopLevel
************************************************************************/
start
= _ types:TypeExp+ _ {
  return types[types.length - 1];
}

TypeExp
= PrimitiveTypeExp
/ ArrayTypeExp
/ ObjectTypeExp
/ OneOfTypeExp
/ ProcedureTypeExp

PrimitiveTypeExp
= 'unit' _ { return Type.baseEnv.get('unit'); }
/ 'null' _ { return Type.baseEnv.get('null'); }
/ 'boolean' _ { return Type.baseEnv.get('boolean'); }
/ 'bool' _ { return Type.baseEnv.get('boolean'); }
/ 'integer' _ { return Type.baseEnv.get('integer'); }
/ 'int' _ { return Type.baseEnv.get('integer'); }
/ 'float' _ { return Type.baseEnv.get('float'); }
/ 'string' _ { return Type.baseEnv.get('string'); }
/ 'date' _ { return Type.baseEnv.get('date'); }

/************************************************************************
ArrayTypeExp
************************************************************************/
ArrayTypeExp
= '[' _ inner:TypeExp _ ']' _ { return Type.baseEnv.get('array')(inner); }

/************************************************************************
ObjectTypeExp
************************************************************************/
ObjectTypeExp
= '{' _ props:PropTypeExp* _ '}' _ { return Type.baseEnv.get('object')(props); }

PropTypeExp
= key:propNameExp _ ':' _ type:TypeExp _ '=' _ defaultVal:ValueExp _ propTypeDelim? { return Type.baseEnv.get('property')(key, type, defaultVal); }
/ key:propNameExp _ ':' _ type:TypeExp _ propTypeDelim? { return Type.baseEnv.get('property')(key, type); }

propNameExp
= SymbolExp

propTypeDelim
= ','

/************************************************************************
OneOfTypeExp
************************************************************************/
OneOfTypeExp
= '(' _ types:_oneOfTypeItem* _ type:TypeExp _ ')' _ {
  if (types.length == 0) {
    return type;
  } else {
    return Type.baseEnv.get('oneOf')(types.concat([ type ]));
  }
}

_oneOfTypeItem
= _ type:TypeExp _ '|' _ { return type; }

/************************************************************************
ProcedureTypeExp
************************************************************************/
ProcedureTypeExp
= '(' _ argTypes:_argTypeItem* _ ')' _ '->' _ retType:TypeExp _ {
  return Type.baseEnv.get('procedure')(argTypes, retType);
}

_argTypeItem
= _ type:TypeExp _ ','? { return type; }


/************************************************************************
ValueExp
************************************************************************/
ValueExp
= UnitExp
/ NullExp
/ BoolExp
/ NumberExp
/ StringExp
/ ArrayExp

/************************************************************************
ArrayExp
************************************************************************/
ArrayExp
= '[' _ items:arrayItemExp* _ ']' { return items; }

arrayItemExp
= item:ValueExp _ keyValDelim? { return item; }

/************************************************************************
ObjectExp
************************************************************************/
ObjectExp
= '{' _ keyVals:keyValExp* _ '}' _ { return objectHelper(keyVals); }

keyValExp
= key:keyExp _ ':' _ val:ValueExp _ keyValDelim? { return [ key, val ]; }

keyValDelim
= ',' _ { return ',' }

keyExp
= s:SymbolExp { return s.value; }
/ s:StringExp { return s; }

UnitExp
= 'undefined' _ { return undefined; }

NullExp
= 'null' _ { return null; }

/************************************************************************
BoolExp
************************************************************************/
BoolExp
= 'true' _ { return true; }
/ 'false' _ { return false; }

/************************************************************************
NumberExp
************************************************************************/
NumberExp
= int:int frac:frac exp:exp _ {
  return numberHelper(int, frac, exp);
}
/ int:int frac:frac _     {
  return numberHelper(int, frac, '');
}
/ '-' frac:frac _ {
  return numberHelper('-', frac, '');
}
/ frac:frac _ {
  return numberHelper('', frac, '');
}
/ int:int exp:exp _      {
  return numberHelper(int, '', exp);
}
/ int:int _          {
  return numberHelper(int, '', '');
}

int
  = digits:digits { return digits.join(''); }
  / "-" digits:digits { return ['-'].concat(digits).join(''); }

frac
  = "." digits:digits { return ['.'].concat(digits).join(''); }

exp
  = e digits:digits { return ['e'].concat(digits).join(''); }

digits
  = digit+

e
  = [eE] [+-]?

digit
  = [0-9]

digit19
  = [1-9]

hexDigit
  = [0-9a-fA-F]

/************************************************************************
StringExp
************************************************************************/
StringExp
= '"' chars:doubleQuoteChar* '"' _ { return chars.join(''); }
/ "'" chars:singleQuoteChar* "'" _ { return chars.join(''); }

singleQuoteChar
= '"'
/ char

doubleQuoteChar
= "'"
/ char

char
// In the original JSON grammar: "any-Unicode-character-except-"-or-\-or-control-character"
= [^"'\\\0-\x1F\x7f]
/ '\\"'  { return '"';  }
/ "\\'"  { return "'"; }
/ "\\\\" { return "\\"; }
/ "\\/"  { return "/";  }
/ "\\b"  { return "\b"; }
/ "\\f"  { return "\f"; }
/ "\\n"  { return "\n"; }
/ "\\r"  { return "\r"; }
/ "\\t"  { return "\t"; }
/ whitespace
/ "\\u" digits:hexDigit4 {
  return String.fromCharCode(parseInt("0x" + digits));
}

hexDigit4
= h1:hexDigit h2:hexDigit h3:hexDigit h4:hexDigit { return h1+h2+h3+h4; }

/************************************************************************
SymbolExp
************************************************************************/
SymbolExp
= _ c1:symbol1stChar rest:symbolRestChar* _ { return [ c1 ].concat(rest).join(''); }

symbol1stChar
= [^ \t\n\r\-0-9\(\)\;\ \"\'\,\`\{\}\.\,\:\[\]]

symbolRestChar
= [^ \t\n\r\(\)\;\ \"\'\,\`\{\}\.\,\:\[\]]

/************************************************************************
Whitespace
************************************************************************/
_ "whitespace"
= whitespace*

// Whitespace is undefined in the original JSON grammar, so I assume a simple
// conventional definition consistent with ECMA-262, 5th ed.
whitespace
= comment
/ [ \t\n\r]


lineTermChar
= [\n\r\u2028\u2029]

lineTerm "end of line"
= "\r\n"
/ "\n"
/ "\r"
/ "\u2028" // line separator
/ "\u2029" // paragraph separator

sourceChar
= .

/************************************************************************
Comment
************************************************************************/
comment
= multiLineComment
/ singleLineComment

singleLineCommentStart
= '//' // c style

singleLineComment
= singleLineCommentStart chars:(!lineTermChar sourceChar)* lineTerm? {
  return {comment: chars.join('')};
}

multiLineComment
= '/*' chars:(!'*/' sourceChar)* '*/' { return {comment: chars.join('')}; }
