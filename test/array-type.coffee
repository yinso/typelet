Type = require '../src/'
{ assert } = require 'chai'

describe 'Array type test', ->

  arrayOfInt = Type.ArrayType(Type.Integer)
  arrayOfFloat = Type.ArrayType Type.Float

  it 'can check', ->
    assert.ok arrayOfInt.isa [ 1 , 2 , 3 ]
    assert.ok arrayOfFloat.isa [ 1.5, 2.5 , 3.5 ]
    assert.notOk arrayOfFloat.isa [ 1.5, 'hello', 3.5 ]
  
  it 'can assert', ->

    assert.throws ->
      arrayOfInt.assert [ 'hello', 'world' ]

  it 'can resolve', ->
    assert.ok arrayOfInt.equal Type.resolve [ 1 , 2 , 3 ]

  it 'can convert', ->
    assert.deepEqual [ 1 , 2 , 3 ], arrayOfInt.convert [ '1', '2', '3' ]

  it 'can assign from', ->
    assert.ok arrayOfInt.canAssignFrom arrayOfInt
    assert.ok arrayOfFloat.canAssignFrom arrayOfFloat
    assert.notOk arrayOfFloat.canAssignFrom arrayOfInt


