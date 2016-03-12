Check = require '../src/check'
{ assert } = require 'chai'

describe 'Check test', ->
  # check is not meant to be used directly...
  it 'can do stuff', ->
    check =Check.compile
      params: [
        {
          name: { symbol: 'foo'}
          type: { symbol: 'integer' }
        }
      ]
      body:
        type: 'binary'
        op: { symbol: '==' }
        lhs: { symbol: 'foo' }
        rhs: { type: 'integer', value: 10 }




###
  it 'can create symbol exp', ->
    sym = Check.Symbol('foo')
    assert.equal 'foo', sym.compile()

  it 'can create literal exp', ->
    lit = Check.Literal('hello')
    assert.equal '"hello"', lit.compile()
    assert.equal '1', Check.Literal(1).compile()
    assert.equal 'null', Check.Literal(null).compile()

  it 'can create binary exp', ->
    op = Check.Symbol('==')
    sym = Check.Symbol('foo')
    lit = Check.Literal(10)
    assert.equal '(foo==10)', Check.Binary(op, sym, lit).compile()

  it 'can create procedure exp', ->
    op = Check.Symbol('==')
    sym = Check.Symbol('foo')
    lit = Check.Literal(10)
    proc = Check.Procedure [ sym ] , Check.Binary(op, sym, lit)
    assert.equal true, proc.compile()(10)

  it 'can compile equal check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $eq:
          lhs: { $symbol: 'foo' }
          rhs: { $literal: 2 }
    assert.ok check.check(2)
    assert.notOk check.check(1)

  it 'can compile not equal check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $ne:
          lhs: { $symbol: 'foo' }
          rhs: { $literal: 2 }
    assert.ok check.check(3)
    assert.notOk check.check(2)

  it 'can compile greater check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $gt:
          lhs: { $symbol: 'foo' }
          rhs: { $literal: 2 }
    assert.ok check.check(3)
    assert.notOk check.check(2)

  it 'can compile greater equal check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $gte:
          lhs: { $symbol: 'foo' }
          rhs: { $literal: 2 }
    assert.ok check.check(2)
    assert.ok check.check(3)
    assert.notOk check.check(1)

  it 'can compile less check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $lt:
          lhs: { $symbol: 'foo' }
          rhs: { $literal: 2 }
    assert.ok check.check(1)
    assert.ok check.check(1)

  it 'can compile less equal check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $lte:
          lhs: { $symbol: 'foo' }
          rhs: { $literal: 2 }
    assert.ok check.check(2)

  it 'can compile not check', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $not:
          $lte:
            lhs: { $symbol: 'foo' }
            rhs: { $literal: 2 }
    assert.ok check.check(3)

  it 'can compile member', ->
    check = Check.compile
      $params: [ { $symbol: 'ary' } ]
      $body:
        $gte:
          lhs:
            $member:
              head: { $symbol: 'ary' }
              key: 'length'
          rhs:
            { $literal: 2 }
    assert.ok check.check [ 1 , 2 , 3 ]
    assert.ok check.check [ 1 , 2 ]
    assert.notOk check.check [ 1 ]

  it 'can compile and exp', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $and:
          lhs:
            $lte:
              lhs: { $symbol: 'foo' }
              rhs: { $literal: 2 }
          rhs:
            $eq:
              lhs: { $symbol: 'foo' }
              rhs: { $literal: 2 }

    assert.ok check.check 2
    assert.notOk check.check 3
    assert.notOk check.check 1

  it 'can compile or exp', ->
    check = Check.compile
      $params: [ { $symbol: 'foo' } ]
      $body:
        $or:
          lhs:
            $lt:
              lhs: { $symbol: 'foo' }
              rhs: { $literal: 2 }
          rhs:
            $eq:
              lhs: { $symbol: 'foo' }
              rhs: { $literal: 2 }

    assert.ok check.check 2
    assert.ok check.check 1
    assert.notOk check.check 3
###
