Type = require './type'

# how do we make use of the named type?
# a named type would be used to construct objects...
# it ought to just be attached...
class TaggedType extends Type
  constructor: (@name, @args = []) ->
  # complex structure would depend on the cooperation of the caller
  # i.e. the caller ought to match the signature of the object against
  # 
  canConvert: (v) ->
    if v instanceof Object and v.__type == @name
      return true
    else
      false
  equal: (type) ->
    if type instanceof NamedType and @name == type.name and @args.length == type.args.length
      for t, i in @args
        if not t.equal(type.args[i])
          return false
      true
    else
      false

module.exports = TaggedType

