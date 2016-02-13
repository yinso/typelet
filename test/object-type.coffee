Type = require '../src'
{ assert } = require 'chai'

describe 'Object test', ->

  fooType = Type.makeObjectType [
    Type.makePropertyType('foo', Type.Integer)
    Type.makePropertyType('bar', Type.String)
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
      Type.makeObjectType [
        Type.makePropertyType('foo', Type.Integer)
        Type.makePropertyType('bar', Type.String)
        Type.makePropertyType('foo', Type.Boolean)
      ]

  it 'can make simple objet types', ->
    Type.makeObjectType
      foo: Type.Integer
      bar: Type.String

  it 'can assign from', ->
    objType1 = Type.makeObjectType([Type.makePropertyType('a',Type.Integer)])
    objType2 = Type.makeObjectType([Type.makePropertyType('b',Type.Integer),Type.makePropertyType('a',Type.Integer)])
    assert.ok objType1.canAssignFrom(objType2)
    assert.notOk objType2.canAssignFrom(objType1)

