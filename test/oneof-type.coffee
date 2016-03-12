Type = require '../src'
{ assert } = require 'chai'

describe 'One Of Type test', ->

  intOrString = Type.baseEnv.get('oneOf') [ Type.baseEnv.get('integer'), Type.baseEnv.get('string') ]

  it 'can check', ->
    assert.ok intOrString.isa 10
    assert.ok intOrString.isa 'this is a string'

  it 'can assert', ->

    assert.throws ->
      intOrString.assert [ 'not', 'an', 'int', 'or', 'string' ]


  it 'can convert', ->
    assert.equal 10, intOrString.convert '10'

  it 'can assign from', ->

    assert.ok intOrString.canAssignFrom Type.baseEnv.get('integer')
    assert.ok intOrString.canAssignFrom Type.baseEnv.get('string')
    assert.notOk intOrString.canAssignFrom Type.baseEnv.get('boolean')

    intOrNull = Type.baseEnv.get('oneOf') [ Type.baseEnv.get('integer'), Type.baseEnv.get('null') ]
    assert.ok intOrNull.canAssignFrom Type.baseEnv.get('oneOf') [ Type.baseEnv.get('null'), Type.baseEnv.get('integer') ] # order of the oneOfType doesn't matter.
    assert.ok intOrNull.canAssignFrom Type.baseEnv.get('integer')
    assert.ok intOrNull.canAssignFrom Type.baseEnv.get('null')
