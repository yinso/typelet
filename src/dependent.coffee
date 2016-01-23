Type = require './type'

# not every type should have constraint?
class DependentType extends Type
  constructor: (@baseType, @constraint) ->
    super()
  isa: (v) ->
    @baseType.isa(v) and @constraint(v)
  isGeneric: () ->
    @baseType.isGeneric()
  

moduele.exports = DependentType

