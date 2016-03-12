Type = require '../src/type'
{ assert } = require 'chai'

describe 'type binder test', ->

  it 'can ensure single typevar is bound only once.', ->

    tA = Type.baseEnv.get('any')()
    binder = Type.makeTypeBinder()
    assert.ok binder.canAssignFrom tA, Type.baseEnv.get('integer')
    assert.notOk binder.canAssignFrom tA, Type.baseEnv.get('string')

  it 'can assign only once', ->

    tA = Type.baseEnv.get('any')()
    binder = Type.makeTypeBinder()
    binder.assignFrom tA, Type.baseEnv.get('integer'), 0
    assert.throws -> binder.assignFrom tA, Type.baseEnv.get('string'), 1

  # we need to deal with
