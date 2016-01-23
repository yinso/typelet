ScalarType = require './scalar-type'
AnyType = require './any-type'
ProcedureType = require './procedure-type'
ArrayType = require './array-type'
ObjectType = require './object-type'

typeA = new AnyType()
typeB = new AnyType()

EqTrait = new Trait 'Eq', [ typeA ] ,
  '==': ProcedureType.native(
    ((a, b) -> not EqTrait.run('!=', a, b)),
    new ProcedureType(
      '!=',
      [
        typeA
        typeA
      ],
      ScalarType.Boolean
    )
  )
  '!=': ProcedureType.native(
    ((a, b) -> not EqTrait.run('==', a, b)),
    new ProcedureType(
      '!=',
      [
        typeA
        typeA
      ],
      ScalarType.Boolean
    )
  )

# I want something that implements the traits.
EqTrait.implement [ ScalarType.Integer ] ,
  '==': (a, b) -> a == b
  '!=': (a, b) -> a != b

EqTrait.implement [ ScalarType.Float ] ,
  '==': (a, b) -> a == b
  '!=': (a, b) -> a != b

EqTrait.implement [ ScalarType.Boolean ] ,
  '==': (a, b) -> a == b
  '!=': (a, b) -> a != b

EqTrait.implement [ ScalarType.String ] ,
  '==': (a, b) -> a == b
  '!=': (a, b) -> a != b

EqTrait.implement [ ScalarType.Date ] ,
  '==': (a, b) -> a == b
  '!=': (a, b) -> a != b

# this one is uncertain, since ArrayType is NOT a type.
EqTrait.implement [ ArrayType ] ,
  '==': (a, b) ->
    if a.length != b.length
      return false
    for item, i in a
      if not EqTrait.run('==', item, b[i])
        return false
    true

