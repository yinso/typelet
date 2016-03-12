Type = require '../src/type'
Schema = require '../src/json-schema'
{ assert } = require 'chai'

describe 'json schema test', ->
  schema = null

  it 'can construct Schema', ->
    schema = Schema()

  it 'can build integer type', ->
    schema.define 'int', { type: 'integer' }
    assert.ok Type.baseEnv.get('integer').equal schema.get('int')

  it 'can build float type', ->
    schema.define 'float', { type: 'number' }
    assert.ok Type.baseEnv.get('float').equal schema.get('float')

  it 'can build string type', ->
    schema.define 'string', { type: 'string' }
    assert.ok Type.baseEnv.get('string').equal schema.get('string')

  it 'can build boolean type', ->
    schema.define 'boolean', { type: 'boolean' }
    assert.ok Type.baseEnv.get('boolean').equal schema.get('boolean')

  it 'can build null type', ->
    schema.define 'null', { type: 'null' }
    assert.ok Type.baseEnv.get('null').equal schema.get('null')

  it 'can build one of type', ->
    schema.define 'int_or_null', { type: [ 'integer', 'null' ] }
    assert.ok Type.baseEnv.get('oneOf')([ Type.baseEnv.get('integer'), Type.baseEnv.get('null') ]).equal schema.get('int_or_null')
    assert.ok schema.get('int_or_null').isa null
    assert.ok schema.get('int_or_null').isa 10

  it 'can build one of type (oneOf parameter)', ->
    schema.define 'int_or_null2', oneOf: [
        { type: 'integer' }
        { type: 'null' }
      ]
    assert.ok Type.baseEnv.get('oneOf')( [ Type.baseEnv.get('null'), Type.baseEnv.get('integer') ] ).equal schema.get('int_or_null')
    assert.ok schema.get('int_or_null').isa null
    assert.ok schema.get('int_or_null').isa 10

  it 'can build array type', ->
    schema.define 'int_array',
      type: 'array'
      items:
        type: 'integer'
    assert.ok Type.baseEnv.get('array')(Type.baseEnv.get('integer')).equal schema.get('int_array')

  it 'can build object type', ->
    schema.define 'obj_foobar',
      type: 'object'
      properties:
        foo:
          type: 'integer'
        bar:
          type: 'number'
    expected = Type.baseEnv.get('object') { foo: Type.baseEnv.get('integer'), bar: Type.baseEnv.get('float') }
    console.log 'json-schema object type', expected, schema.get('obj_foobar')
    assert.ok expected.equal schema.get('obj_foobar')

  it 'can build a complex schema', ->
    schema2 = Schema
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

    fooType = Type.baseEnv.get('float')
    assert.ok fooType.equal schema2.get('foo')
    barType = Type.baseEnv.get('object')({foo: Type.baseEnv.get('float'), bar: Type.baseEnv.get('float') })
    assert.ok barType.equal schema2.get('bar')
    bazType = Type.baseEnv.get('object')({xyz: barType, abc: Type.baseEnv.get('array')(Type.baseEnv.get('boolean'))})
    assert.ok bazType.equal(schema2.get('baz'))
    abcType = schema2.get('abc')
    assert.ok abcType instanceof Type.baseEnv.get('property')
    assert.ok abcType.innerType.equal Type.baseEnv.get('integer')
    assert.equal 50, abcType.convert()
