# Typelet - an extensible type framework.

## Install

    npm install typelet

## Usage

    var Type = require('typelet');

Type checking:

    Type.baseEnv.get('integer').isa(1); // ==> true
    Type.baseEnv.get('integer').isa(1.5); // ==> false
    Type.baseEnv.get('float').isa(1.5); // ==> true

    // compound types.
    var intArrayType = Type.baseEnv.get('array')(Type.baseEnv.get('integer'))
    intArrayType.isa([1, 2, 3, 4, 5]); // ==> true
    var objFooType = Type.baseEnv.get('object')({ foo: Type.baseEnv.get('integer'), bar: Type.baseEnv.get('string') });
    objFooType.isa({foo: 1, bar: 'a string'}); // ==> true
    objFooType.isa({foo: 1, baz: 2}); // ==> false

Type checking via assert:

    Type.baseEnv.get('integer').assert(1); // OK
    Type.baseEnv.get('integer').assert(1.5); // throws
    intArrayType.assert([1, 'not an int']); // throws
    objFooType.assert({foo: 1, bar: 'a string'}); // OK
    objFooType.assert({foo: 1, bar: 'a string', baz: 2}); // OK - ObjectType is okay with additional attributes.
    objFooType.assert({foo: 1, bar: 2}); // throws

Type conversion:

    var val = Type.baseEnv.get('integer').convert('1'); // string -> int
    var val = Type.baseEnv.get('integer').convert('not an int'); // throws

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
    * unit (`Type.baseEnv.get('unit')`) - maps to `undefined` in JavaScript.
    * null (`Type.baseEnv.get('null')`) - maps to `null` in JavaScript.
    * boolean (`Type.baseEnv.get('boolean')`) maps to `true` and `false` in JavaScript.
    * integer (`Type.baseEnv.get('integer')`)
    * float (`Type.baseEnv.get('float')`) - `NaN` is not considered a number in this type system.
    * string (`Type.baseEnv.get('string')`)
    * date (`Type.baseEnv.get('date')`)
* Compound Types
    * array (`Type.baseEnv.get('array')(<type>)`)
    * object (`Type.baseEnv.get('object')({ key1: <type1>, key2: <type2>, ...})`)
    * disjoint union (`Type.baseEnv.get('oneOf')(<type1>, <type2>, ...)`)
    * procedure (`Type.baseEnv.get('procedure')([<argType1>, ...], <returnType>)`)
