# Typelet - an extensible type framework.

## Install

    npm install typelet

## Usage

    var Type = require('typelet');
    
Type checking:

    Type.Integer.isa(1); // ==> true
    Type.Integer.isa(1.5); // ==> false
    Type.Float.isa(1.5); // ==> true
    
    // compound types.
    var intArrayType = Type.ArrayType(Type.Integer)
    intArrayType.isa([1, 2, 3, 4, 5]); // ==> true
    var objFooType = Type.ObjectType({ foo: Type.Integer, bar: Type.String });
    objFooType.isa({foo: 1, bar: 'a string'}); // ==> true
    objFooType.isa({foo: 1, baz: 2}); // ==> false

Type checking via assert:

    Type.Integer.assert(1); // OK
    Type.Integer.assert(1.5); // throws
    intArrayType.assert([1, 'not an int']); // throws
    objFooType.assert({foo: 1, bar: 'a string'}); // OK
    objFooType.assert({foo: 1, bar: 'a string', baz: 2}); // OK - ObjectType is okay with additional attributes.
    objFooType.assert({foo: 1, bar: 2}); // throws

Type conversion:

    var val = Type.Integer.convert('1'); // string -> int
    var val = Type.Integer.convert('not an int'); // throws

JSON Schema support (limited at this time):

    var schema = Type.Schema({
      definitions: {
        foo: { type: 'integer' },
	bar: {
	  type: 'object',
	  properties: {
	    foo: { $ref: '#/definitions/foo' },
	    baz: { type: 'number' }
	  }
	},
	baz: {
	  type: 'object'
	  properties: {
	    xyz: { $ref: '#/definitions/bar' },
	    abc: {
	      type: 'array',
	      items: { type: 'boolean' }
	    }
	  }
	},
	abc: {
	  type: 'integer',
	  default: 50
	}
      }
    });
    schema.get('foo').isa(1) // true
    schema.get('bar').isa({ foo: 1, bar: 2.5 }) // true
    schema.get('baz').isa({ xyz: { foo: 1, bar: 2.5 }, abc: [ true, false, true ] }) // true
    schema.get('abc').isa(10) // true
    schema.get('abc').convert() // ==> 50, default val works.

## Built-In Types

Built-in types currently follows JavaScript built-in types.

* Scalar Types
    * unit (`Type.Unit`) - maps to `undefined` in JavaScript.
    * null (`Type.Null`) - maps to `null` in JavaScript.
    * boolean (`Type.Boolean`) maps to `true` and `false` in JavaScript.
    * integer (`Type.Integer`)
    * float (`Type.Float`) - `NaN` is not considered a number in this type system.
    * string (`Type.String`)
    * date (`Type.Date`)
* Compound Types
    * array (`Type.ArrayType(<type>)`)
    * object (`Type.ObjectType({ key1: <type1>, key2: <type2>, ...})`)
    * disjoint union (`Type.OneOf(<type1>, <type2>, ...)`)
    * procedure (`Type.ProcedureType([<argType1>, ...], <returnType>)`)

