Type = require '../src'
{ assert } = require 'chai'

describe 'Object test', ->

  fooType = Type.ObjectType [
    Type.PropertyType('foo', Type.Integer)
    Type.PropertyType('bar', Type.String)
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
      Type.ObjectType [
        Type.PropertyType('foo', Type.Integer)
        Type.PropertyType('bar', Type.String)
        Type.PropertyType('foo', Type.Boolean)
      ]

  it 'can make simple objet types', ->
    type = Type.ObjectType
      foo: Type.Integer
      bar: Type.String
    assert.equal 2, type.properties.length
    assert.ok Type.PropertyType('foo', Type.Integer).equal type.properties[0]
    assert.ok Type.PropertyType('bar', Type.String).equal type.properties[1]

  it 'can assign from', ->
    objType1 = Type.ObjectType([Type.PropertyType('a',Type.Integer)])
    objType2 = Type.ObjectType([Type.PropertyType('b',Type.Integer),Type.PropertyType('a',Type.Integer)])
    assert.ok objType1.canAssignFrom(objType2)
    assert.notOk objType2.canAssignFrom(objType1)

