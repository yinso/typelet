Type = require './type'
PropertyType = require './property-type'

# 5.4.1.  maxProperties
# 5.4.2.  minProperties
# 5.4.3.  required (by default things are required)
# 5.4.4.  additionalProperties, properties and patternProperties
# 5.4.5.  dependencies

# enum, etc don't make sense here either. though they are propably supported...
# what I need to decide on is whether to have constraints for types... i.e. 

class RecordType extends Type
  @isConstructor: true
  @outerIsa: (obj) ->
    obj instanceof Object
  @resolve: (obj, typeSpace) ->
    props = []
    for key, val of obj
      if obj.hasOwnProperty(key)
        props.push new PropertyType(key, typeSpace.resolve(val))
    new RecordType props, @options
  constructor: (@properties, @options = {}) ->
    super @options
    for prop in @properties
      if not (prop instanceof PropertyType)
        throw new Error("invalid_property_type: #{prop}")
  signature: () ->
    props =
      for prop in @properties
        prop.signature()
    "Object<#{props.join(',')}>"
  isGeneric: () ->
    for type in @properties
      if type.isGeneric()
        return true
    false
    
  isa: (obj) ->
    if @outerIsa obj
      for prop in @properties
        if obj.hasOwnProperty(prop.name)
          if not prop.isa(obj[prop.name])
            return false
      true
    else
      false
  sorted: () ->
    [].concat(@properties).sort (p1, p2) ->
      if p1.name == p2.name
        0
      else if p1.name > p2.name
        1
      else
        -1
  equal: (type) ->
    if type instanceof RecordType
      if @properties.length == type.properties.length
        props = @sorted()
        props2 = type.sorted()
        for prop, i in props
          if not prop.equal(props2[i])
            return false
        true
      else
        false
    else
      false
  _specialize: (props) -> # creates another compound type...
    normalized = @merge props
    new RecordType normalized, @options
  merge: (props) ->
    if props.length != @properties.length
      throw new Error("record_type_merge: not_same_length")
    for item, i in props
      if item instanceof PropertyType
        item
      else
        @properties[i]
  inspect: () ->
    @toString()
  toString: () ->
    props =
      for prop in @properties
        prop.toString()
    "{#{props.join(', ')}}"

module.exports = RecordType

