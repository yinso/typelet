class Ref
  ref: () ->

Ref.Call = class CallRef extends Ref
  constructor: (@func, @args) ->
  ref: (v) ->
    @func.ref(v).apply v, @args

# can be used for .length, for example.
class MemberRef extends Ref
  constructor: (@inner, @key) ->
  value: () ->
    v = @inner[@name]
    if typeof(v) == 'function' or (v instanceof Function)
      object = @inner
      name = @key
      (args...) ->
        object[name] args...
    else
      v

module.exports = Ref

