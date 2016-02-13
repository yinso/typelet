Type = require '../src'
{ assert } = require 'chai'

describe 'Procedure test', ->

  it 'can assign from procedure types', ->
    # procedure types follow the contravariant(args) and covariant(ret)
    p1 = Type.makeProcedureType([Type.Integer,Type.Integer],Type.Integer)
    p2 = Type.makeProcedureType([Type.Integer,Type.Integer],Type.makeAnyType())
    #assert.notOk p1.canAssignFrom p1
    #assert.ok p2.canAssignFrom p1

  it 'can handle procedure subtypes', ->
    p1 = Type.makeProcedureType([Type.Integer,Type.Integer],Type.Integer)
    typeA = Type.makeAnyType()
    p2 = Type.makeProcedureType([typeA, typeA], typeA)
    assert.ok p2.canAssignFrom p1

  it 'can make procedures with preconditions', ->
    # keep in mind that it doesn't have invariant checks.
    add = Type.makeProc [Type.Integer, Type.Integer], Type.Integer, (a, b) -> a + b
    
    # we can still allow for explicit conversion though... that would require an additional call.
    # i.e. even as we add these converters we want to mark some of them being only available during explicit calls.
    # that means they are two separate functions... one used internally and the other used externally (or just pass in an additional flag).
    assert.equal 3, add.check(1, 2)
    assert.equal 5, add.check(3, 2)
    assert.equal 3, add.convert(1, '2')
    assert.throws -> add.check(1, 'hello') # 'hello' cannot be converted to integer
    assert.throws -> add.check(1, 1.5) # 1.5 cannot be converted to integer (loss of precision)

  it 'can assign arguments for procedure types', ->
    p1 = Type.makeProcedureType([Type.Integer, Type.Integer], Type.Integer)
    assert.ok p1.canAssignArgumentsFrom [1, 2]
    objType = Type.makeObjectType([Type.makePropertyType('b',Type.Integer),Type.makePropertyType('a',Type.Integer)])
    p2 = Type.makeProcedureType [ objType , Type.String ], Type.Float
    assert.ok p2.canAssignArgumentsFrom [ {a: 1, b: 2, c: 'test'}, 'hello' ]

  it 'can work with generic binding', ->
    equal = (a, b) -> a == b
    typeA = Type.makeAnyType()
    typeEnv = Type.TypeEnv()
    typeEnv.push typeA
    typeEnv.bind typeA, Type.Integer
    assert.throws -> typeEnv.bind typeA, Type.Float

  it 'can create traits', ->
    tA = Type.makeAnyType()
    eq = Type.makeTypeTrait
      name: 'Eq'
      types: [ tA ]
      procedures:
        '==': Type.makeProcedureType [ tA , tA ] , Type.Boolean
        '!=': Type.makeProc [ tA , tA ], Type.Boolean, (a, b) -> not (eq.runProcedure '==', a, b)
    assert.ok eq
    intEq = eq.implement
      types: [ Type.Integer ]
      procedures:
        '==': Type.makeProc [ Type.Integer, Type.Integer ], Type.Boolean, (a, b) -> a == b
        '!=': Type.makeProc [ Type.Integer, Type.Integer ], Type.Boolean, (a, b) -> a != b
    assert.ok intEq
    

