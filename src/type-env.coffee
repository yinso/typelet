
####################
# TYPE Environment
####################

class TypeEnv
  constructor: (prev = null) ->
    if not (@ instanceof TypeEnv)
      return new TypeEnv prev
    @inner = {}
    @id = 0
    @prev = prev
    @binders = []
  bind: (typeVar, typeVal) ->
    for [ key, val ] in @binders
      if key == typeVar and not val.equal(typeVal)
        throw new Error("duplicate_binding: #{key} already bound to #{val}")
    @binders.push [ typeVar, typeVal ]
  push: (type, key = undefined) ->
    if key
      if @inner.hasOwnProperty(key)
        throw new Error("duplicate_key: #{key}")
      else
        @inner[key] = type
        return key
    else
      for k, val of @inner
        if val == type
          return k
      key = @id++
      @inner[key] = type
      key
  getKey: (type) ->
    for key, val of @inner
      if val == type
        return key
    throw new Error("unknown_type: #{type}")
  print: (type) ->
    if type.typeCategory != 'TypeVar'
      type.toString()
    else
      key = @push type
      "T_#{key}"

module.exports = TypeEnv
