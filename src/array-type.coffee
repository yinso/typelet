util = require './util'
errLib = require './error'
Type = require './type'
AnyType = require './any-type'


####################
# ARRAY TYPES
####################
class ArrayType extends Type
  constructor: (innerType = AnyType()) ->
    if not (@ instanceof ArrayType)
      return new ArrayType innerType
    super()
    util._mixin @, { typeID: Type.typeID++ , innerType: innerType }
  typeCategory: 'Array'
  signature: () ->
  isGeneric: () -> @innerType.isGeneric()
  isComposite: () -> true
  canAssignFrom: (type) ->
    (type instanceof ArrayType) and @innerType.equal(type.innerType)
  build: ArrayType
  isa: (obj) ->
    if obj instanceof Array
      for item in obj
        if not @innerType.isa(item)
          return false
      return true
    else
      false
  outerIsa: (obj) -> obj instanceof Array
  _convert: (ary, error , path , isExplicit) ->
    e = new errLib.ConvertError()
    res =
      for item, i in ary
        @innerType._convert item, e, "#{path}/#{i}", isExplicit
    if e.hasErrors()
      error.append e
    else
      res
  resolve: (obj, resolver) ->
    current = null
    if obj.length == 0
      throw new Error("unable_to_resolve_array_type")
    for item, i in obj
      type = resolver.resolve item
      if i == 0
        current = type
      else if current.canAssignFrom type
        continue
      else if type.canAssignFrom current
        current = type
      else
        throw new Error("array_type_resolve:inner_types_incompatible: #{current} <> #{type}")
    return ArrayType current
  equal: (type) ->
    (type instanceof ArrayType) and @innerType.equal(type.innerType)
  _toString: (env) ->
    "Array<#{env.print(@innerType)}>"

Type.attachType Array, ArrayType()

Type.baseEnv.define 'array', ArrayType

module.exports = ArrayType
