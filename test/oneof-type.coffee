Type = require '../src'
{ assert } = require 'chai'

describe 'One Of Type test', ->

  intOrString = Type.OneOfType [ Type.Integer, Type.String ]

  it 'can check', ->
    assert.ok intOrString.isa 10
    assert.ok intOrString.isa 'this is a string'

  it 'can assert', ->

    assert.throws ->
      intOrString.assert [ 'not', 'an', 'int', 'or', 'string' ]


  it 'can convert', ->
    assert.equal 10, intOrString.convert '10'

  it 'can assign from', ->

    assert.ok intOrString.canAssignFrom Type.Integer
    assert.ok intOrString.canAssignFrom Type.String
    assert.notOk intOrString.canAssignFrom Type.Boolean

    intOrNull = Type.OneOfType [ Type.Integer, Type.Null ]
    assert.ok intOrNull.canAssignFrom Type.OneOfType [ Type.Null, Type.Integer ] # order of the oneOfType doesn't matter.
    assert.ok intOrNull.canAssignFrom Type.Integer
    assert.ok intOrNull.canAssignFrom Type.Null

