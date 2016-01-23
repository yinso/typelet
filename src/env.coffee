
class Environment
  constructor: (@prev = null) ->
    if not (this instanceof Environment)
      return new Environment(@prev)
    @inner = {}
  has: (name) ->
    if @inner.hasOwnProperty(name)
      true
    else if @prev
      @prev.has name
    else
      false
  get: (name) ->
    if @inner.hasOwnProperty(name)
      @inner[name]
    else if @prev
      @prev.get name
    else
      throw new Error("unknown_type: #{name}")
        

module.exports = Environment
