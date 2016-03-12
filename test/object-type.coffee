Type = require '../src'
{ assert } = require 'chai'

describe 'Object test', ->

  fooType = Type.baseEnv.get('object') [
    Type.baseEnv.get('property')('foo', Type.baseEnv.get('integer'))
    Type.baseEnv.get('property')('bar', Type.baseEnv.get('string'))
  ]

  it 'can check', ->
    assert.ok fooType.isa { foo: 1, bar: 'hello' }
    assert.ok fooType.isa { foo: 10, bar: 'this is a subtype', baz: [ 'additional', 'prop', 'is', 'ok', 'for', 'subtype' ] }

  it 'can assert', ->
    fooType.assert { foo: 1, bar: 'hello' }
    assert.throws ->
      fooType.assert { foo: true, bar: 'this is a subtype', baz: [ 'additional', 'prop', 'is', 'ok', 'for', 'subtype' ] }

  it 'can resolve', ->
    assert.ok fooType.equal Type.resolve { foo: 1, bar: 'hello' }

  it 'can catch duplicate keys', ->
    assert.throws ->
      Type.baseEnv.get('object') [
        Type.baseEnv.get('property')('foo', Type.baseEnv.get('integer'))
        Type.baseEnv.get('property')('bar', Type.baseEnv.get('string'))
        Type.baseEnv.get('property')('foo', Type.baseEnv.get('boolean'))
      ]

  it 'can make simple objet types', ->
    type = Type.baseEnv.get('object')
      foo: Type.baseEnv.get('integer')
      bar: Type.baseEnv.get('string')
    assert.equal 2, type.ordered.length
    assert.ok Type.baseEnv.get('property')('foo', Type.baseEnv.get('integer')).equal type.get('foo')
    assert.ok Type.baseEnv.get('property')('bar', Type.baseEnv.get('string')).equal type.get('bar')

  it 'can assign from', ->
    objType1 = Type.baseEnv.get('object')([Type.baseEnv.get('property')('a',Type.baseEnv.get('integer'))])
    objType2 = Type.baseEnv.get('object')([Type.baseEnv.get('property')('b',Type.baseEnv.get('integer')),Type.baseEnv.get('property')('a',Type.baseEnv.get('integer'))])
    assert.ok objType1.canAssignFrom(objType2)
    assert.notOk objType2.canAssignFrom(objType1)
