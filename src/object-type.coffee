util = require './util'
errLib = require './error'
Type = require './type'
PropertyType = require './property-type'

####################
# OBJECT TYPES.
####################
class ObjectType extends Type
  constructor: (properties = []) ->
    if not (@ instanceof ObjectType)
      return new ObjectType properties
    super()
    keys = {}
    for prop in properties
      if not (prop instanceof Type) and prop.typeCategory == 'Property'
        throw new Error("invalid_property_type: #{prop}")
      if keys.hasOwnProperty(prop.name)
        throw new Error("duplicate_key: #{prop}")
      keys[prop.name] = prop
    options =
      typeID: Type.typeID++
      properties: properties
    util._mixin @, options
  typeCategory: 'Object'
  isGeneric: () ->
    for prop in @properties
      if prop.isGeneric()
        return true
    false
  isComposite: () -> true
  build: ObjectType
  isa: (obj) ->
    if @outerIsa obj
      for prop in @properties
        if not prop.isa obj[prop.name]
          return false
      return true
    else
      false
  outerIsa: (obj) -> obj instanceof Object
  _convert: (obj, error, path , isExplicit) ->
    result = {};
    for prop in @properties
      result[prop.name] = prop._convert obj[prop.name], "#{path}/#{prop.name}", isExplicit
    result
  canAssignFrom: (type) ->
    if type instanceof ObjectType
      sorted = @_sortedProperties()
      sortedB = type._sortedProperties()
      if sortedB.length < sorted.length
        false
      for prop, i in sorted
        if not prop.canAssignFrom(sortedB[i])
          return false
      true
    else
      false
  resolve: (obj, resolver) ->
    props =
      for key, val of obj
        PropertyType key, resolver.resolve(val)
    ObjectType props
  _sortedProperties: () ->
    [].concat(@properties).sort (a, b) -> a.name > b.name
  equal: (type) ->
    if type instanceof ObjectType
      if @properties.length != type.properties.length
        return false
      sortedA = @_sortedProperties()
      sortedB = type._sortedProperties()
      for prop, i in sortedA
        if not prop.equal(sortedB[i])
          return false
      return true
    else
      false
  _toString: (env) ->
    props =
      for prop in @properties
        prop._toString(env)
    "Object[#{props.join(',')}]"

Type.attachType Object, ObjectType()

util._mixin Type,
  makeObjectType: ObjectType

module.exports = ObjectType
