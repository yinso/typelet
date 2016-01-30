util = require './util'
Type = require './type'

####################
# PROPERTY TYPES - USED FOR BOTH OBJECT & FUNCTION
####################
class PropertyType extends Type
  constructor: (name, type, defaultVal) ->
    if not (@ instanceof PropertyType)
      if arguments.length == 2
        return new PropertyType name, type
      else
        return new PropertyType name, type, defaultVal
    options =
      typeID: Type.typeID++
      name: name
      innerType: type
    if arguments.length == 3
      testVal =
        if util._isFunction defaultVal
          defaultVal()
        else
          defaultVal
      if not type.isa testVal
        throw new Error("invalid_default_val: #{testVal} isn't a #{type}")
      options.defaultVal = defaultVal
    util._mixin @, options
  typeCategory: 'Property'
  isGeneric: () -> @innerType.isGeneric()
  isComposite: () -> @innerType.isComposite()
  canAssignFrom: (type) ->
    (type instanceof PropertyType) and @name == type.name and @innerType.canAssignFrom(type.innerType)
  build: PropertyType
  isa: (obj) -> @innerType.isa obj
  _convert: (obj, error, path , isExplicit) ->
    @innerType._convert obj, error, path , isExplicit
  _toString: (env) ->
    "#{@name}:#{@innerType._toString(env)}"
  equal: (type) ->
    (type instanceof PropertyType) and @innerType.equal(type.innerType)

util._mixin Type,
  makePropertyType: PropertyType

module.exports = PropertyType

