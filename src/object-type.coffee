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
    options =
      typeID: Type.typeID++
      properties: {}
      ordered: []
    util._mixin @, options
    if properties instanceof Array
      for prop in properties
        @append prop
    else if properties instanceof Object
      for key, type of properties
        if properties.hasOwnProperty(key)
          if not (type instanceof Type)
            throw new Error("invalid_property_type: #{type}")
        @set key, type
    else
      throw new Error("invalid_object_type_properties: must_be_array_of_property_types_or_object_of_types")
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
      for prop in @ordered
        if not prop.isa obj[prop.name]
          return false
      return true
    else
      false
  outerIsa: (obj) -> obj instanceof Object
  _convert: (obj, error, path , isExplicit) ->
    result = {};
    for prop in @ordered
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
    [].concat(@ordered).sort (a, b) -> a.name > b.name
  equal: (type) ->
    if type instanceof ObjectType
      if @ordered.length != type.ordered.length
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
      for prop in @ordered
        prop._toString(env)
    "Object[#{props.join(',')}]"
  has: (key) ->
    @properties.hasOwnProperty(key)
  get: (key) ->
    if @has key
      @properties[key]
    else
      throw new Error("ObjectType.get:unknown_key: #{key}")
  set: (key, type) ->
    @append Type.PropertyType(key, type)
  append: (prop) ->
    if not (prop instanceof Type) and prop.typeCategory == 'Property'
      throw new Error("invalid_property_type: #{prop}")
    if @has prop.name
        throw new Error("object_type_duplicate_property: #{prop.name}")
    @properties[prop.name] = prop
    @ordered.push prop

Type.attachType Object, ObjectType()

util._mixin Type,
  ObjectType: ObjectType

module.exports = ObjectType

