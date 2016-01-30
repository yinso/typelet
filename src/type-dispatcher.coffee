

####################
# Type Dispatcher
# used for dispatching based on a given type
####################


# time to deal with validation. and that requires sorting of the types...
# the simplest is to just add them together...
# but we want to make sure that we can sort things correctly...
# and by that we 

# dispatching for unrelated type is pretty straight forward.
# 
# now let's talk about what it takes to dispatch types that are related.
#
# Vehicle
#   LandBound
#     Motorcycle
#     Car
#     Truck
#     Bicycle
#   OceanBound
#     Ship
#       Powerboat
#       Yacht
#     Canoe
# 
# sorting against a single topology is pretty straight forward.
# 1 - specific -> general -> in case of a non-hit, we will have to travel backwards.
# 2 - general -> specific -> a single miss means it doesn't exist.
# 
# Float
#   Int
#     Natural
#       Month
#
# <general_to_specific>
# if Float
#   if Int
#     if Natural
#       if Month
#         Month_add
#       else
#         Natural_add
#     else
#       Int_add
#   else
#     Float_add
# 
# <specific_to_general> -> this still requires that the type falls within the top level hierarchy?
# if Month
#   Month_add
# else if Natural
#   Natural_add
# else if Int
#   Int_add
# else
#   Float_add
# 
# strictly specific the above are the same amount of test?
# 
# if we have every types direct entry -> then we can do the following.
# 
# # this way we can dispatch on a single object. -> it depends on the baseType, which ought to exist for every type object then.
# get (type):
#   if dict.has type
#     goto next
#   else if type.baseType
#     get(type.baseType)
#   else
#     error()
# 
# now how do we extend this to multiple parameters?
#
# if we do two parameters. add(Float, Float) -> Float (don't worry about this for now...)
# 
# add(Month, Float) -> Float
# add(Month, Int) -> Int
# add(Month, Natural) -> Natural
# add(Month, Month) -> Month
#
# add(Natural, Float) -> Float
# add(Natural, Int) -> Int
# add(Natural, Month) -> Natural
# add(Natural, Natural) -> Natural
#
# add(Int, Float) -> Flaot
# add(Int, Natural) -> Int
# add(Int, Month) -> Int
# add(Int, Int) -> Int
# 
# add(Float, Int) -> Float
# add(Float, Natural) -> Float
# add(Float, Month) -> Float
# add(Float, Float) -> Float
# 
# if we left -> right, then we can have the following.
#
# Month:
#   Month: add(Month, Month)
#   Natural: add(Month, Natural)
#   Int: add(Month, Int)
#   Float: add(Month, Float)
# 
# Natural:
#   Month: add(Natural, Month)
#   Natural: add(Natural, Natural)
#   Int: add(Natural, Int)
#   Float: add(Natural, Float)
#
# Int:
#   Month: add(Int, Month)
#   Natural: add(Int, Natural)
#   Int: add(Int, Int)
#   Float: add(Int, Float)
#
# Float:
#   Month: add(Float, Month)
#   Natural: add(Float, Natural)
#   Int: add(Float, Int)
#   Float: add(Float, Float)
#
# the above process can be repeated continuously... somewhat like currying.
# 
# That seems fine.
# 

# dispatch on a single parameter.
class UnaryDispatcher
  constructor: (options = {}) ->
    if not (@ instanceof UnaryDispatcher)
      return new UnaryDispatcher options
    ###
    defaultOpts =
      items: {}
      overwrite: false
      onNotExistThrow: true
    util._mixin, @, util._extend defaultOpts, options
    ###
    @items = {}
    @overwrite = options.overwrite or false
    @onNotEixstThrow = (if options.onNotExitThrow then options.onNotExistThrow else true)
  _genKey: (type) ->
    type.toString()
  _get: (type, notExistThrow = @onNotExistThrow) ->
    key = @_genKey type
    if @items.hasOwnProperty(key)
      return @items[key]
    else if type.baseType
      return @_get type.baseType
    else if notExistThrow
      throw new Error("Dispatcher:get:type_not_found: #{type}")
    else
      null
  get: (types, notExistThrow = @onNotExistThrow) ->
    if types.length == 0
      throw new Error("Dispatcher.get:arity_underflow")
    head = types[0]
    tail = types.slice(1)
    res = @_get head, false
    if res instanceof UnaryDispatcher
      if tail.length == 0
        throw new Error("UnaryDispatcher.get:arity_underflow: #{types.length}")
      else
        res.get tail
    else if res
      if tail.length == 0
        return res
      else
        throw new Error("UnaryDispatcher.get:arity_overflow: #{types.length}")
    else
      if notExistThrow
        throw new Error("UnaryDispatcher.get:not_found: #{types}")
      else
        undefined
  _set: (type, val) ->
    key = @_genKey type
    if @items.hasOwnProperty(key) and not @overwrite
      throw new Error("Dispatcher:set:cannot_overwrite_due_to_setting")
    @items[key] = val
  set: (types, val) ->
    if types.length == 0
      throw new Error("Dispatcher:set: no_more_type")
    head = types[0]
    tail = types.slice(1)
    res = @_get head, false
    if res instanceof UnaryDispatcher
      if tail.length == 0
        throw new Error("UnaryDispatcher.set:invalid_arity_underflow: #{types.length}")
      else
        res.set(tail, val)
    else if res
      if tail.length == 0 # no more tail, so we can set!
        @_set head, val
      else
        throw new Error("UnaryDispatcher.set:invalid_arity_overflow: #{types.length}")
    else
      if tail.length == 0
        @_set head, val
      else
        innerDispatcher = new UnaryDispatcher { overwrite: @overwrite , onNotExistThrow: @onNotExistThrow }
        @_set head, innerDispatcher
        innerDispatcher.set tail, val

module.exports = UnaryDispatcher

