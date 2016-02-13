Type = require '../src/type'
{ assert } = require 'chai'

describe 'type binder test', ->
  
  it 'can ensure single typevar is bound only once.', ->
    
    tA = Type.makeAnyType()
    binder = Type.makeTypeBinder()
    assert.ok binder.canAssignFrom tA, Type.Integer
    assert.notOk binder.canAssignFrom tA, Type.String
  
  it 'can assign only once', ->
    
    tA = Type.makeAnyType()
    binder = Type.makeTypeBinder()
    binder.assignFrom tA, Type.Integer, 0
    assert.throws -> binder.assignFrom tA, Type.String, 1
    
  # we need to deal with 
  
