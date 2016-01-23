Type = require './type'
PropertyType = require './property-type'

class ProcedureType extends Type
  native: (proc, type) ->
    proc.__$t = type
    proc
  constructor: (@arguments, @return, @options) ->
    super @options
  signature: () ->
    args =
      for type in @arguments.concat([@return])
        type.signature()
    args.join('->')
  isGeneric: () ->
    for arg in @arguments
      if arg.isGeneric()
        return true
    @return.isGeneric()
  isa: (proc) ->
    if @outerIsa proc
      if proc.__$t and @equal(proc.__$t)
        true
      else # we are not going to try to derive function type for now until we think it makes sense.
        false
    else
      false
  outerIsa: (proc) ->
    typeof(proc) == 'function' or (proc instanceof Function)
  resolveType: (proc) ->
    throw new Error("procedure_type_resolve_unsupported")
  convert: (x) ->
    throw new Error("procedure_type_convert_unsupported")
  _specialize: (args) -> # for now don't worry about linking it back.
    normalized = @merge args
    new ProcedureType normalized, @return, @options
  merge: (args) ->
    if args.length != @arguments.length
      throw new Error("procedure_type_merge: not_same_length")
    for item, i in args
      if item instanceof PropertyType
        item
      else
        @arguments[i]

module.exports = FunctionType

