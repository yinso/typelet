Type = require './type'

# 5.3.1.  additionalItems and items
# 5.3.2.  maxItems
# 5.3.3.  minItems
# 5.3.4.  uniqueItems

# note that items and additionalItems are too flexible, and made this into a tuple (at least the first part).
# enum might not apply

# array type should also be an instance rather than just a class... hmmm...

class ArrayType extends Type
  @isConstructor: true
  @outerIsa: (x) ->
    x instanceof Array
  @resolve: (x, typeSpace) ->
    inner = null
    for item, i in x
      if i == 0
        inner = typeSpace.resolve item
      else
        next = typeSpace.resolve item
        if inner.contains(next)
          continue
        else if next.contains(inner)
          inner = next
        else
          throw new Error("un_assignable_type: #{inner} <!> #{next}")
    new ArrayType inner, @options
  constructor: (@inner, @options = {}) ->
    super @options
  signature: () ->
    "Array<#{@inner.signature()}>"
  isa: (x) ->
    if @outerIsa x
      for item in x
        if not @inner.isa x
          return false
      true
    else
      false
  convert: (x) ->
    if x instanceof Array
      for item, i in x
        @inner.cnvert item
    else
      throw new Error("not_a_valid_array: #{x}")
  equal: (type) ->
    if type instanceof ArrayType
      @inner.equal(type.inner)  
    else
      false
  isGeneric: () ->
    @inner.isGeneric x
  _specialize: (inner) ->
    new ArrayType inner, @options
  inspect: () ->
    @toString()
  toString: () ->
    "Array[#{@inner.toString()}]"

module.exports = ArrayType

