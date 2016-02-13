Type = require './type'
util = require './util'
errLib = require './error'

class TypeBinder
  constructor: () ->
    if not (@ instanceof TypeBinder)
      return new TypeBinder()
    @binders = []
  canAssignFrom: (lhs, rhs) ->
    try
      @assignFrom lhs, rhs
      true
    catch e
      false
  canAssignTo: (lhs, rhs) ->
    @canAssignFrom rhs, lhs
  assignFrom: (lhs, rhs, i = 0) ->
    for binder in @binders
      if binder.lhs == lhs
        if binder.rhs.canAssignFrom rhs
          return
        else if rhs.canAssignFrom binder.rhs
          binder.rhs = rhs
        else
          throw new Error("TypeBinder.cannotRebind at #{i}: #{lhs} <- #{rhs}")
      else
        continue
      throw new Error("TypeBinder:bindingFailed at #{i}: #{lhs} <!= #{rhs}")
    @binders.push { lhs: lhs , rhs: rhs }
  assignTo: (lhs, rhs, i = 0) ->
    @canAssignFrom rhs, lhs, i

util._mixin Type,
  makeTypeBinder: TypeBinder

module.exports = TypeBinder

