Type = require '../src/type'
Builder = require '../src/json-schema'
{ assert } = require 'chai'

describe 'json schema test', ->
  buildr = Builder()

  it 'can build integer type', ->
    type = buildr.buildOne type: 'integer'
    assert.ok Type.Integer.equal type

  it 'can build float type', ->
    type = buildr.buildOne type: 'number'
    assert.ok Type.Float.equal type

  it 'can build string type', ->
    type = buildr.buildOne type: 'string'
    assert.ok Type.String.equal type

  it 'can build boolean type', ->
    type = buildr.buildOne type: 'boolean'
    assert.ok Type.Boolean.equal type

  it 'can build null type', ->
    type = buildr.buildOne type: 'null'
    assert.ok Type.Null.equal type

  it 'can build one of type', ->
    type = buildr.buildOne type: [ 'integer', 'null' ]
    assert.ok Type.OneOfType( [ Type.Integer, Type.Null ] ).equal type
    assert.ok type.isa null
    assert.ok type.isa 10

  it 'can build one of type (oneOf parameter)', ->
    type = buildr.buildOne oneOf: [
        { type: 'integer' }
        { type: 'null' }
      ]
    assert.ok Type.OneOfType( [ Type.Integer, Type.Null ] ).equal type
    assert.ok type.isa null
    assert.ok type.isa 10

  it 'can build array type', ->
    type = buildr.buildOne
      type: 'array'
      items:
        type: 'integer'
    assert.ok Type.ArrayType(Type.Integer).equal type

  it 'can build object type', ->
    type = buildr.buildOne
      type: 'object'
      properties:
        foo:
          type: 'integer'
        bar:
          type: 'number'
    expected = Type.ObjectType { foo: Type.Integer, bar: Type.Float }
    console.log 'json-schema object type', expected, type
    assert.ok expected.equal type

  it 'can build a complex schema', ->
    env = buildr.build
      definitions:
        foo:
          type: 'number'
        bar:
          type: 'object'
          properties:
            foo:
              $ref: '#/definitions/foo'
            baz:
              type: 'number'
        baz:
          type: 'object'
          properties:
            xyz:
              $ref: '#/definitions/bar'
            abc:
              type: 'array'
              items:
                type: 'boolean'
        abc:
          type: 'integer'
          default: 50

    fooType = Type.Float
    assert.ok fooType.equal env.get('foo')
    barType = Type.ObjectType({foo: Type.Float, bar: Type.Float })
    assert.ok barType.equal env.get('bar')
    bazType = Type.ObjectType({xyz: barType, abc: Type.ArrayType(Type.Boolean)})
    assert.ok bazType.equal(env.get('baz'))
    abcType = env.get('abc')
    assert.ok abcType instanceof Type.PropertyType
    assert.ok abcType.innerType.equal Type.Integer
    assert.equal 50, abcType.convert()

