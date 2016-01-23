Type = require './type'

class OneOfType extends Type
  constructor: (@list, @options) ->
    super @options
    for type in @list
      if not (type instanceof Type)
        throw new Error("invalid_one_of_type_param: #{type}")
  signature: () ->
    list =
      for type in @list
        type.signature()
    "OneOf<#{list.join(',')}>"
  isa: (x) ->
    for type in @list
      if type.isa x
        return true
    false
  convert: (x) ->
    for type in @list
      try
        return type.convert(x)
      catch e
        continue
    throw new Error("invalid_one_of_conversion: #{x}")
  isGeneric: () ->
    for type in @list
      if type.isGeneric()
        return true
    false
  _specialize: (list) ->
    normalized = @merge list
    new OneOfType normalized, @options
  merge: (list) ->
    if list.length != @list.length
      throw new Error("one_of_type:list_must_be_equal_length")
    for type, i in list
      if type instanceof Type
        type
      else
        @list[i]

module.exports = OrType

