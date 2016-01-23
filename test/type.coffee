Type = require '../src/type2'
{ assert } = require 'chai'


describe 'Type test', ->

  it 'can check types', ->
    assert.ok Type.Unit.isa()
    assert.ok Type.Null.isa null
    assert.ok Type.Boolean.isa true
    assert.ok Type.Boolean.isa false
    assert.ok Type.Integer.isa 1
    assert.ok Type.Float.isa 1.5
    assert.ok Type.Date.isa new Date()
    assert.ok Type.String.isa 'this is a string'
    assert.ok Type.makeAnyType().isa 'this can be anything'
    assert.ok Type.makeArrayType(Type.Integer).isa [1, 2, 3]
    assert.ok Type.makeArrayType(Type.Float).isa [1.5, 2.5, 3.5]
    assert.notOk Type.makeArrayType(Type.Float).isa [1.5, 'hello', 3.5]
    assert.ok Type.makeObjectType([Type.makePropertyType('a',Type.Integer), Type.makePropertyType('b',Type.Float)]).isa {a: 1, b: 1.5}
  
  it 'can resolve types', ->
    assert.equal Type.Unit, Type.resolve()
    assert.equal Type.Null, Type.resolve(null)
    assert.equal Type.Integer, Type.resolve 1
    assert.equal Type.Float, Type.resolve 1.5
    assert.equal Type.Boolean, Type.resolve true
    assert.equal Type.Boolean, Type.resolve false
    assert.equal Type.Date, Type.resolve new Date()
    assert.ok Type.makeArrayType(Type.Integer).equal(Type.resolve [ 1 , 2 , 3 ])
    assert.ok Type.makeObjectType([Type.makePropertyType('a',Type.Integer),Type.makePropertyType('b',Type.Float)]).equal(Type.resolve({a:1, b: 1.5}))

  it 'can convert types', ->
    assert.equal 5, Type.Integer.convert '5'
    assert.equal 6, Type.Integer.convert 5.5 # this is explicit in the sense that users will call this function directly.
    assert.throws -> Type.Integer.convert 5.5, '$', false # this is implicit in the sense that it afford programmatic way to control an implicit behavior
    assert.throws -> Type.Integer.convert null
    assert.throws -> Type.Date.convert 'hello'

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

  it 'can work with generic binding', ->
    equal = (a, b) -> a == b
    typeA = Type.makeAnyType()
    typeEnv = Type.TypeEnv()
    typeEnv.push typeA
    typeEnv.bind typeA, Type.Integer
    assert.throws -> typeEnv.bind typeA, Type.Float
  
