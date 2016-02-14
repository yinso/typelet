Type = require '../src/type'
Builder = require '../src/json-schema'
{ assert } = require 'chai'

describe 'json schema test', ->
  buildr = Builder()

  it 'can build integer type', ->
    type = buildr.build type: 'integer'
    assert.ok Type.Integer.equal type

  it 'can build float type', ->
    type = buildr.build type: 'number'
    assert.ok Type.Float.equal type

  it 'can build string type', ->
    type = buildr.build type: 'string'
    assert.ok Type.String.equal type

  it 'can build boolean type', ->
    type = buildr.build type: 'boolean'
    assert.ok Type.Boolean.equal type

  it 'can build null type', ->
    type = buildr.build type: 'null'
    assert.ok Type.Null.equal type

  it 'can build one of type', ->
    type = buildr.build type: [ 'integer', 'null' ]
    assert.ok Type.OneOfType( [ Type.Integer, Type.Null ] ).equal type
    assert.ok type.isa null
    assert.ok type.isa 10

  it 'can build one of type (oneOf parameter)', ->
    type = buildr.build oneOf: [
        { type: 'integer' }
        { type: 'null' }
      ]
    assert.ok Type.OneOfType( [ Type.Integer, Type.Null ] ).equal type
    assert.ok type.isa null
    assert.ok type.isa 10

  it 'can build array type', ->
    type = buildr.build
      type: 'array'
      items:
        type: 'integer'
    assert.ok Type.ArrayType(Type.Integer).equal type

  it 'can build object type', ->
    type = buildr.build
      type: 'object'
      properties:
        foo:
          type: 'integer'
        bar:
          type: 'number'
    expected = Type.ObjectType { foo: Type.Integer, bar: Type.Float }
    console.log 'json-schema object type', expected, type
    assert.ok expected.equal type


