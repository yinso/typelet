util = require './util'
Type = require './type'
####################
# TYPE VARIABLES
####################

class AnyType extends Type
  constructor: () ->
    if not (@ instanceof AnyType)
      return new AnyType()
    super()
    util._mixin @, { typeID: Type.typeID++ }
  typeCategory: 'TypeVar'
  signature: () ->
    "0" # all AnyType has the same signature
  isGeneric: () -> true
  isComposite: () -> false
  isPrimitive: () -> false
  canAssignFrom: (type) -> true # unless there are traits involved...
  _toString: (env) ->
    env.print @
  equal: (type) ->
    type instanceof AnyType
  isa: (obj) -> true

Type.baseEnv.define 'any', AnyType

module.exports = AnyType
