Type = require '../src/'
{ assert } = require 'chai'

describe 'Any Type test', ->

  it 'can check', ->

    assert.ok Type.makeAnyType().isa 1
    assert.ok Type.makeAnyType().isa 'hello'
    assert.ok Type.makeAnyType().isa true
    assert.ok Type.makeAnyType().isa null
    assert.ok Type.makeAnyType().isa new Date()

  it 'can assign from', ->

    assert.ok Type.makeAnyType().canAssignFrom Type.Integer
    assert.ok Type.makeAnyType().canAssignFrom Type.String

