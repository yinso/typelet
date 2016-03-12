util = require './util'
errLib = require './error'
Type = require './type'

####################
# OneOf TYPES.
####################
class OneOfType extends Type
  constructor: (types) ->
    if not (@ instanceof OneOfType)
      return new OneOfType types
    super()
    if not (types instanceof Array)
      throw new Error("one_of_type_takes_array_of_types")
    if types.length == 0
      throw new Error("one_of_type_must_take_at_least_one_type")
    for type in types
      if not type instanceof Type
        throw new Error("one_of_type_take_only_types: #{type}")
    util._mixin @,
      typeID: Type.typeID++
      innerTypes: types
  category: 'OneOfType'
  sortedTypes: () ->
    [].concat(@innerTypes).sort (a, b) -> a.typeID < b.typeID
  isa: (obj) ->
    for type in @innerTypes
      if type.isa(obj)
        return true
    false
  _convert: (val, error, path, isExplicit) ->
    for type in @innerTypes
      try
        return type._convert val, new errLib.ConvertError(), path, isExplicit
      catch e
        continue
    error.push new errLib.CannotConvertError(@, val)
  canAssignFrom: (type) ->
    if type instanceof OneOfType
      @equal type
    else
      for inner in @innerTypes
        if inner.canAssignFrom type
          return true
      false
  equal: (type) ->
    if type instanceof OneOfType
      if @innerTypes.length != type.innerTypes.length
        return false
      sortedA = @sortedTypes()
      sortedB = type.sortedTypes()
      for type, i in sortedA
        if not type.equal(sortedB[i])
          return false
      true
    else
      false
  resolve: (obj, resolver) ->
    for type in @innerTypes
      try
        return type.resolve obj, resolver
      catch e
        continue
    throw new Error("unknown_type: #{obj}")
  _toString: (env) ->
    types =
      for type in @innerTypes
        type._toString(env)
    "OneOf[#{types.join(',')}]"

Type.baseEnv.define 'oneOf', OneOfType

module.exports = OneOfType
