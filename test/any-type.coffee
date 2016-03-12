Type = require '../src/'
{ assert } = require 'chai'

describe 'Any Type test', ->

  it 'can check', ->

    assert.ok Type.baseEnv.get('any')().isa 1
    assert.ok Type.baseEnv.get('any')().isa 'hello'
    assert.ok Type.baseEnv.get('any')().isa true
    assert.ok Type.baseEnv.get('any')().isa null
    assert.ok Type.baseEnv.get('any')().isa new Date()

  it 'can assign from', ->

    assert.ok Type.baseEnv.get('any')().canAssignFrom Type.baseEnv.get('integer')
    assert.ok Type.baseEnv.get('any')().canAssignFrom Type.baseEnv.get('string')
