Type = require '../src'
{ assert } = require 'chai'

describe 'Procedure test', ->

  it 'can assign from procedure types', ->
    # procedure types follow the contravariant(args) and covariant(ret)
    p1 = Type.baseEnv.get('procedure')([Type.baseEnv.get('integer'),Type.baseEnv.get('integer')],Type.baseEnv.get('integer'))
    p2 = Type.baseEnv.get('procedure')([Type.baseEnv.get('integer'),Type.baseEnv.get('integer')],Type.baseEnv.get('any')())
    #assert.notOk p1.canAssignFrom p1
    #assert.ok p2.canAssignFrom p1

  it 'can handle procedure subtypes', ->
    p1 = Type.baseEnv.get('procedure')([Type.baseEnv.get('integer'),Type.baseEnv.get('integer')],Type.baseEnv.get('integer'))
    typeA = Type.baseEnv.get('any')()
    p2 = Type.baseEnv.get('procedure')([typeA, typeA], typeA)
    assert.ok p2.canAssignFrom p1

  it 'can make procedures with preconditions', ->
    # keep in mind that it doesn't have invariant checks.
    add = Type.makeProc [Type.baseEnv.get('integer'), Type.baseEnv.get('integer')], Type.baseEnv.get('integer'), (a, b) -> a + b

    # we can still allow for explicit conversion though... that would require an additional call.
    # i.e. even as we add these converters we want to mark some of them being only available during explicit calls.
    # that means they are two separate functions... one used internally and the other used externally (or just pass in an additional flag).
    assert.equal 3, add.check(1, 2)
    assert.equal 5, add.check(3, 2)
    assert.equal 3, add.convert(1, '2')
    assert.throws -> add.check(1, 'hello') # 'hello' cannot be converted to integer
    assert.throws -> add.check(1, 1.5) # 1.5 cannot be converted to integer (loss of precision)

  it 'can assign arguments for procedure types', ->
    p1 = Type.baseEnv.get('procedure')([Type.baseEnv.get('integer'), Type.baseEnv.get('integer')], Type.baseEnv.get('integer'))
    assert.ok p1.canAssignArgumentsFrom [1, 2]
    objType = Type.baseEnv.get('object')([Type.baseEnv.get('property')('b',Type.baseEnv.get('integer')),Type.baseEnv.get('property')('a',Type.baseEnv.get('integer'))])
    p2 = Type.baseEnv.get('procedure') [ objType , Type.baseEnv.get('string') ], Type.baseEnv.get('float')
    assert.ok p2.canAssignArgumentsFrom [ {a: 1, b: 2, c: 'test'}, 'hello' ]

  it 'can work with generic binding', ->
    equal = (a, b) -> a == b
    typeA = Type.baseEnv.get('any')()
    typeEnv = Type.TypeEnv()
    typeEnv.push typeA
    typeEnv.bind typeA, Type.baseEnv.get('integer')
    assert.throws -> typeEnv.bind typeA, Type.baseEnv.get('float')

  it 'can create traits', ->
    tA = Type.baseEnv.get('any')()
    eq = Type.makeTypeTrait
      name: 'Eq'
      types: [ tA ]
      procedures:
        '==': Type.baseEnv.get('procedure') [ tA , tA ] , Type.baseEnv.get('boolean')
        '!=': Type.makeProc [ tA , tA ], Type.baseEnv.get('boolean'), (a, b) -> not (eq.runProcedure '==', a, b)
    assert.ok eq
    intEq = eq.implement
      types: [ Type.baseEnv.get('integer') ]
      procedures:
        '==': Type.makeProc [ Type.baseEnv.get('integer'), Type.baseEnv.get('integer') ], Type.baseEnv.get('boolean'), (a, b) -> a == b
        '!=': Type.makeProc [ Type.baseEnv.get('integer'), Type.baseEnv.get('integer') ], Type.baseEnv.get('boolean'), (a, b) -> a != b
    assert.ok intEq
