# things about Trait is that they need to be 
Type = require './type'
HashMap = require './hashmap'

class Trait
  constructor: (@name, @types, @methods = {}, @typeClass) ->
    @implementations = new HashMap()
  # trait by definition is generic, of course...
  isGeneric: () ->
    for type in @types
      if type.isGeneric()
        return true
    false # when it's false it's an instance/implement.
  isImplement: () ->
    not @isGeneric()
  implement: (types, methods) ->
    # the available types themselves might still make a trait.
    normalized = types
    trait = new Trait @name, normalized, methods, @typeClass
    @implementations.set normalized, trait
    trait
  merge: (types) ->
    if types.length != @types.length
      throw new Error("types_length_mismatch")
    for type, i in types
      if type instanceof Type
        type
      else
        @types[i]
  run: (op, args...) ->
    # we need to be able to qualify the types of the args, and then based on the types to determine
    # the actual types that we need.
    # keep in mind that 
    if args.length != @types.length
      throw new Error("invalid_argument_count: #{args.length} != #{@types.length}")
    if @isGeneric()
      throw new Error("generic_trait_not_implement")
    types =
      for item in args
        @typeClass.getType item
    res = @implementations.get types
    if res
      res.run op, args...
    else
      throw new Error("unmatched_arguments: #{args}")

class Implmementation
  constructor: (@name, @type, @methods) ->

module.exports = Trait

