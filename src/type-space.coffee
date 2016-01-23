Type = require './type'
ScalarType = require './scalar-type'
ArrayType = require './array-type'
ObjectType = require './object-type'
AnyType = require './any-type'

# generic type space vs base level resolver...
class TypeSpace
  resolve: (val) ->
    if val == undefined
      return ScalarType.Unit
    else if val == null
      return ScalarType.Null
    else if typeof(val) == 'number'
      if val % 1 == 0
        return ScalarType.Integer
      else
        return ScalarType.Float
    else if val.constructor.__$t
      type = val.constructor.__$t
      if type.isConstructor
        return type.resolve val, @
      else
        return type
    else
      throw new Error("unknown_type: #{val}")

Boolean.__$t = ScalarType.Boolean

Number.__$t = ScalarType.Float

String.__$t = ScalarType.String

Date.__$t = ScalarType.Date

Array.__$t = ArrayType

Object.__$t = ObjectType

module.exports = TypeSpace

