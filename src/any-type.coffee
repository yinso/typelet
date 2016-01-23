Type = require './type'

class TypeVariable extends Type
  @typeVarID: 0
  constructor: () ->
    super()
    @typeVarID = TypeVariable.typeVarID++
    @resolved = null
  signature: () -> # this need to do without the typeVarID?
    "any$#{@typeVarID}"
  isa: (x) -> true # anything can fit into a TypeVariable.
  isGeneric: () -> true
  convert: (x) -> x # or throw error - don't know which way yet.
  equal: (type) -> @ == type
  greater: (type) ->
    if type instanceof TypeVariable
      false
    else
      true

module.exports = TypeVariable

