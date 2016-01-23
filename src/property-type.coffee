Type = require './type'

# can be used for object type as well as function parameters
class PropertyType extends Type
  constructor: (@name, @type, @default) ->
    if arguments.length == 3
      if not @type.isa(@default)
        throw new Error("invalid_default_for_property_type: #{@default}")
  signature: () ->
    "#{@name}: #{@type.signature()}"
  isa: (x) ->
    @type.isa x
  convert: (x) ->
    if @default and not x
      @default
    else
      @type.convert x
  equal: (type) ->
    (type instanceof PropertyType) and @name == type.name and @type.equal(type.type)
  isGeneric: () ->
    @type.isGeneric()
  _specialize: (type) ->
    new PropertyType @name, type, @default
  inspect: () ->
    @toString()
  toString: () ->
    if @default
      "#{@name}: #{@type.toString()} = #{@default.toString()}"
    else
      "#{@name}: #{@type.toString()}"

module.exports = PropertyType

