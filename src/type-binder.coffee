class TypeBinder
  constructor: () ->
    @binders = []
  canAssignFrom: (lhs, rhs) ->
    try
      @assignFrom lhs, rhs
      true
    catch e
      false
  canAssignTo: (lhs, rhs) ->
    @canAssignFrom rhs, lhs
  assignFrom: (lhs, rhs) ->
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
  assignTo: (lhs, rhs) ->
    @canAssignFrom rhs, lhs

module.exports = TypeBinder

