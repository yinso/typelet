typeID = 0


_extend = (objs...) ->
  res = {}
  for obj in objs
    for key, val of obj
      if obj.hasOwnProperty(key)
        res[key] = val
  res

_props = (obj, config = {}) ->
  res = {}
  for key, val of obj
    if obj.hasOwnProperty(key)
      res[key] =
        value: val
        writable: ((config.writable instanceof Array) and key in config.writable)
        configurable: ((config.configurable instanceof Array) and key in config.configurable)
        enumerable: ((config.enumerable instanceof Array) and key in config.enumerable)
  res

_mixin = (obj, options) ->
  Object.defineProperties obj, _props options

_isFunction = (func) ->
  typeof(func) == 'function' or func instanceof Function

_class = (options = {}) ->
  ctor =
    if options.hasOwnProperty('constructor') and _isFunction(options.constructor)
      options.constructor
    else
      () ->
  parent =
    if _isFunction options.__super__
      options.__super__
    else
      Object
  ctor.prototype = _new parent, _extend({ constructor: ctor }, options)
  _mixin ctor, __super__: parent
  ctor

_new = (ctor, options, configs) ->
  if not _isFunction ctor
    throw new Error("_new_requires_ctor_to_be_function")
  Object.create ctor.prototype, _props options, configs

_inherits = (_class, _ancestor) ->
  if not (_isFunction(class) and _isFunction(_ancestor))
    throw new Error("inherit_expects_functions")
  _class.prototype instanceof _ancestor

####################
# ERROR
####################

CannotConvertError = _class
  __super__: Error
  constructor: (@type, @value, context = CannotConvertError) ->
    @name = 'CannotConvert'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

CannotImplicitConvertError = _class
  __super__: Error
  constructor: (@type, @value, context = CannotImplicitConvertError) ->
    @name = 'CannotImplicitConvert'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

InvalidValueError = _class
  __super__: Error
  constructor: (@type, @value, context = InvalidValueError) ->
    @name = 'InvalidValue'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

NotTypeOfError = _class
  __super__: Error
  constructor: (@type, @value, context = InvalidValueError) ->
    @name = 'NotTypeOf'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

ConversionNotSupportedError = _class
  __super__: Error
  constructor: (@type, context = ConversionNotSupportedError) ->
    @name = 'ConversionNotSupported'
    @message = "for #{@type}"
    Error.captureStackTrace @, context

ConvertError = _class
  __super__: Error
  constructor: (context = ConvertError) ->
    @name = 'ConvertError'
    @errors = {}
    Error.captureStackTrace @, context
  append: (err) ->
    if err instanceof ConvertError
      for key, val of err.errors
        if err.errors.hasOwnProperty(key)
          @push key, val
  push: (path, error) ->
    @errors[path] = error
    @message = @formatMessage()
    return
  hasErrors: () ->
    Object.keys(@errors).length > 0
  formatMessage: () ->
    errors =
      for key, error of @errors
        "#{key}: #{error}"
    errors.join(";")

convertError = (context = convertError) ->
  new ConvertError context

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
    _mixin, @, _extend defaultOpts, options
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
    else if type.baseType instanceof Type
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

class Type
  constructor: (options = { noConvert: false }) ->
    if not (this instanceof Type)
      return new Type()
    if options.noConvert
      @_converter = null
    else
      @_converter = new UnaryDispatcher { length: 1 }
  # uniquely determining a type.
  # used for hashing a type object. this provides an *equal* comparison for types.
  signature: () ->
  # for determining whether this is is a composite type.
  isGeneric: () -> # is this a generic type.
  # for determining whether this is a composite type. useful for resolve.
  isAnyType: () ->
    true
  isComposite: () ->
  # for resolving complex data type.
  isPrimitive: () ->
  resolve: (obj, resolver) -> @
  # determine whether <this> is a sub type of type
  isSubTypeOf: (type) ->
  # used for determining assignment relationship.
  canAssignFrom: (type) -> false
  # determine whether obj is a type of <this>.
  canAssignTo: (type) -> 
    type.canAssignFrom @
  isa: (obj) ->
  assert: (obj, context) ->
    if not @isa obj
      throw new NotTypeOf @, obj, context
    obj
  _assert: (obj, err, path = '$', context = @_assert) ->
    if not @isa obj
      err.push path, new NotTypeOfError @, obj, context
    else
      obj
  outerIsa: (obj) ->
    @isa obj
  # convert throws an error.
  convert: (obj, options = {}) ->
    { path , isExplicit , context } = _extend options,
      path: '$'
      isExplicit: true
      context: @convert
    err = convertError(context)
    res = @_convert obj, err, path, isExplicit
    if err.hasErrors()
      throw err
    else
      res
  _convert: (obj, error, path, isExplicit) ->
    if @isa obj
      return obj
    if not @_converter
      error.push path, new ConversionNotSupportedError(@)
    try
      type = Type.resolve obj
      converter = @_converter.get [ type ]
      if not converter
        error.push path, new CannotConvertError(@, obj)
      else if converter.isExplicit and not isExplicit
        error.push path, new CannotImplicitConvertError(@, obj)
      else
        converter.converter obj
    catch e
      error.push path, e
  setConvert: (options = {}) ->
    type = options.type
    converter = options.converter
    explicit = options.explicit or false
    if not (type instanceof Type)
      throw new Error("Type:setConvert:no_type_specified")
    if not _isFunction(converter)
      throw new Error("Type.setConvert:no_converter_specified")
    @_converter.set [ type ] , { converter: converter , isExplicit: explicit }
  equal: (type) ->
  inspect: () -> @toString()
  toString: () ->
    @_toString new TypeEnv()
  _toString: (envs) ->
    '<IType>'

createType = (ctor, options) ->
  if not _isFunction ctor
    throw new Error("invalid_constructor: #{ctor}")
  if not (ctor.prototype instanceof Type)
    _class 
      constructor: ctor
      __super__: Type
  _new ctor, options

attachType = (ctor, type) ->
  Object.defineProperty ctor, '__$t',
    value: type
    enumerable: false
    writable: false
    configurable: false

####################
# PRIMITIVE TYPES
####################

class PrimitiveType extends Type
  constructor: (name, options = {}) ->
    if not (@ instanceof PrimitiveType)
      return new PrimitiveType name, options
    super()
    _mixin @, _extend({ name: name, typeID: typeID++ }, options)
    if _isFunction options.instanceof
      attachType options.instanceof, @
  signature: () ->
    "1:#{@typeID}"
  typeCategory: 'Primitive'
  isPrimitive: () -> false
  isComposite: () -> false
  isGeneric: () -> false
  isSubTypeOf: (type) -> false
  canAssignFrom: (type) -> type == @
  isa: (obj) -> typeof(obj) == @name.toLowerCase()
  equal: (type) -> type == @
  _toString: (env) -> @name


UnitType = Type.Unit = PrimitiveType 'Unit',
  isa: (obj) -> obj == undefined

NullType = Type.Null = PrimitiveType 'Null',
  isa: (obj) -> obj == null

BooleanType = Type.Boolean = PrimitiveType 'Boolean',
  instanceof: Boolean

IntegerType = Type.Integer = PrimitiveType 'Integer',
  isa: (obj) ->
    typeof(obj) == 'number' and Math.floor(obj) == obj

FloatType = Type.Float = PrimitiveType 'Float',
  isa: (obj) ->
    typeof(obj) == 'number'
  instanceof: Number

StringType = Type.String = PrimitiveType 'String',
  instanceof: String

DateType = Type.Date = PrimitiveType 'Date',
  isa: (obj) ->
    obj instanceof Date
  instanceof: Date # this attaches the object constructor.

RegExpType = Type.RegExp = PrimitiveType 'RegExp',
  isa: (obj) ->
    obj instanceof RegExp
  instanceof: RegExp

IntegerType.setConvert
  type: StringType
  converter: (s) ->
    res = parseInt s
    if res.toString() == s
      return res
    else
      throw new InvalidValueError IntegerType, s

IntegerType.setConvert
  type: FloatType
  converter: (i) -> Math.round(i)
  explicit: true # must be explicitly converted.

FloatType.setConvert
  type: StringType
  converter: (s) ->
    res = parseFloat s
    if res.toString() == s
      return res
    else
      throw new InvalidValueError FloatType, s

FloatType.setConvert
  type: IntegerType
  converter: (i) -> i # strictly speaking Type.resolve will still return Integer. but practically it doesn't really matter.

DateType.setConvert
  type: StringType
  converter: (s) ->
    ts = Date.parse s
    if not isNaN(ts)
      new Date ts
    else
      throw new InvalidValueError(s, DateType)

DateType.setConvert
  type: IntegerType
  converter: (i) -> new Date(i)

StringType.setConvert
  type: UnitType
  converter: () -> ''

StringType.setConvert
  type: NullType
  converter: () -> 'null'

StringType.setConvert
  type: IntegerType
  converter: (i) -> i.toString()

StringType.setConvert
  type: FloatType
  converter: (f) -> f.toString()

StringType.setConvert
  type: DateType
  converter: (d) -> d.toISOString()

StringType.setConvert
  type: BooleanType
  converter: (b) -> b.toString()

####################
# TYPE VARIABLES
####################

class AnyType extends Type
  constructor: () ->
    if not (@ instanceof AnyType)
      return new AnyType()
    super()
    _mixin @, { typeID: typeID++ }
  typeCategory: 'TypeVar'
  signature: () ->
    "0" # all AnyType has the same signature
  isGeneric: () -> true
  isComposite: () -> false
  isPrimitive: () -> false
  canAssignFrom: (type) -> true # unless there are traits involved...
  _toString: (env) ->
    env.print @
  equal: (type) ->
    type instanceof AnyType
  isa: (obj) -> true

####################
# ARRAY TYPES
####################
class ArrayType extends Type
  constructor: (innerType = AnyType()) ->
    if not (@ instanceof ArrayType)
      return new ArrayType innerType
    super()
    _mixin @, { typeID: typeID++ , innerType: innerType }
  typeCategory: 'Array'
  signature: () ->
  isGeneric: () -> @innerType.isGeneric()
  isComposite: () -> true
  canAssignFrom: (type) ->
    (type instanceof ArrayType) and @innerType.equal(type.innerType)
  build: ArrayType
  isa: (obj) ->
    if obj instanceof Array
      for item in obj
        if not @innerType.isa(item)
          return false
      return true
    else
      false
  outerIsa: (obj) -> obj instanceof Array
  _convert: (ary, error , path , isExplicit) ->
    e = new ConvertError()
    res =
      for item, i in ary
        @innerType._convert item, e, "#{path}/#{i}", isExplicit
    if e.hasErrors()
      error.append e
    else
      res
  resolve: (obj, resolver) ->
    current = null
    if obj.length == 0
      throw new Error("unable_to_resolve_array_type")
    for item, i in obj
      type = resolver.resolve item
      if i == 0
        current = type
      else if current.canAssignFrom type
        continue
      else if type.canAssignFrom current
        current = type
      else
        throw new Error("array_type_resolve:inner_types_incompatible: #{current} <> #{type}")
    return ArrayType current
  equal: (type) ->
    (type instanceof ArrayType) and @innerType.equal(type.innerType)
  _toString: (env) ->
    "Array<#{env.print(@innerType)}>"

attachType Array, ArrayType()

####################
# PROPERTY TYPES - USED FOR BOTH OBJECT & FUNCTION
####################
class PropertyType extends Type
  constructor: (name, type, defaultVal) ->
    if not (@ instanceof PropertyType)
      if arguments.length == 2
        return new PropertyType name, type
      else
        return new PropertyType name, type, defaultVal
    options =
      typeID: typeID++
      name: name
      innerType: type
    if arguments.length == 3
      testVal =
        if _isFunction defaultVal
          defaultVal()
        else
          defaultVal
      if not type.isa testVal
        throw new Error("invalid_default_val: #{testVal} isn't a #{type}")
      options.defaultVal = defaultVal
    _mixin @, options
  typeCategory: 'Property'
  isGeneric: () -> @innerType.isGeneric()
  isComposite: () -> @innerType.isComposite()
  canAssignFrom: (type) ->
    (type instanceof PropertyType) and @name == type.name and @innerType.canAssignFrom(type.innerType)
  build: PropertyType
  isa: (obj) -> @innerType.isa obj
  _convert: (obj, error, path , isExplicit) ->
    @innerType._convert obj, error, path , isExplicit
  _toString: (env) ->
    "#{@name}:#{@innerType._toString(env)}"
  equal: (type) ->
    (type instanceof PropertyType) and @innerType.equal(type.innerType)

####################
# OBJECT TYPES.
####################
class ObjectType extends Type
  constructor: (properties = []) ->
    if not (@ instanceof ObjectType)
      return new ObjectType properties
    super()
    keys = {}
    for prop in properties
      if not (prop instanceof Type) and prop.typeCategory == 'Property'
        throw new Error("invalid_property_type: #{prop}")
      if keys.hasOwnProperty(prop.name)
        throw new Error("duplicate_key: #{prop}")
      keys[prop.name] = prop
    options =
      typeID: typeID++
      properties: properties
    _mixin @, options
  typeCategory: 'Object'
  isGeneric: () ->
    for prop in @properties
      if prop.isGeneric()
        return true
    false
  isComposite: () -> true
  build: ObjectType
  isa: (obj) ->
    if @outerIsa obj
      for prop in @properties
        if not prop.isa obj[prop.name]
          return false
      return true
    else
      false
  outerIsa: (obj) -> obj instanceof Object
  _convert: (obj, error, path , isExplicit) ->
    result = {};
    for prop in @properties
      result[prop.name] = prop._convert obj[prop.name], "#{path}/#{prop.name}", isExplicit
    result
  canAssignFrom: (type) ->
    if type instanceof ObjectType
      sorted = @_sortedProperties()
      sortedB = type._sortedProperties()
      if sortedB.length < sorted.length
        false
      for prop, i in sorted
        if not prop.canAssignFrom(sortedB[i])
          return false
      true
    else
      false
  resolve: (obj, resolver) ->
    props =
      for key, val of obj
        PropertyType key, resolver.resolve(val)
    ObjectType props
  _sortedProperties: () ->
    [].concat(@properties).sort (a, b) -> a.name > b.name
  equal: (type) ->
    if type instanceof ObjectType
      if @properties.length != type.properties.length
        return false
      sortedA = @_sortedProperties()
      sortedB = type._sortedProperties()
      for prop, i in sortedA
        if not prop.equal(sortedB[i])
          return false
      return true
    else
      false
  _toString: (env) ->
    props =
      for prop in @properties
        prop._toString(env)
    "Object[#{props.join(',')}]"

attachType Object, ObjectType()

####################
# OneOf TYPES.
####################
class OneOfType extends Type
  constructor: (types...) ->
    if not (@ instanceof OneOfType)
      return new OneOfType types...
    super()
    for type in types
      if not type instanceof Type
        throw new Error("one_of_type_take_only_types: #{type}")
    _mixin @,
      typeID: typeID++
      innerTypes: types
  category: 'OneOfType'
  sortedTypes: () ->
    [].concat(@innerTypes).sort (a, b) -> a.typeID < b.typeID
  isa: (obj) ->
    for type in @innerTypes
      if type.isa(obj)
        return true
    false
  _convert: (val, error, path, isExplicit) ->
    for type in @innerTypes
      try
        return type._convert val, new ConvertError(), path, isExplicit
      catch e
        continue
    error.push new CannotConvertError(@, val)
  canAssignFrom: (type) ->
    if type instanceof OneOfType
      @equal type
    else
      for inner in @innerTypes
        if inner.canAssignFrom type
          return true
      false
  equal: (type) ->
    if type instanceof OneOfType
      if @innerTypes.length != type.innerTypes.length
        return false
      sortedA = @sortedTypes()
      sortedB = type.sortedTypes()
      for type, i in sortedA
        if not type.equal(sortedB[i])
          return false
      true
    else
      false
  resolve: (obj, resolver) ->
    for type in @innerTypes
      try
        return type.resolve obj, resolver
      catch e
        continue
    throw new Error("unknown_type: #{obj}")
  _toString: (env) ->
    types =
      for type in @innerTypes
        type._toString(env)
    "OneOf[#{types.join(',')}]"

# it is important to realize that the defaultVals must be reconstructed for each use.
class Arity
  constructor: (@length, @isVarArg, @defaultVals = []) ->
    @minLength = 0
    for val in @defaultVals
      if val != undefined
        @minLength++
  normalize: (args) ->
    # the simpliest case.
    if args.length == @length
      if @isVarArg
        @normalizeVarArgs args
      else
        return args
    else if args.length < @minLength
      throw new Error("arity_less_than_minimum: #{@minLength}")
    else if args.length > @length
      if not @isVarArg
        throw new Error("arity_not_vararg")
      else
        return @normalizeVarArgs args
    else # this falls into the *in-between* situation.
      @normalizeInBetween args
  normalizeVarArgs: (args) ->
    normalized = []
    rest = []
    for item, i in args
      if i < @length - 1
        normalized.push item
      else
        rest.push item
    normalized.push rest
    normalized
  normalizeInBetween: (args) ->
    # the way to think about it is the following...
    # [ undefined , item , undefined , item , undefined ]
    # => [ consume, optional , consume , optional , consume ]
    # if args.length == 3 => we need to match 1 , 3 , 5 ( all required )
    # if args.length == 4 => match 1 , 2 , 3 , 5 (3 required and 1st optional)
    # if args.length == 5 => match 1 , 2 , 3 , 4 , 5
    # in order for us to match them the right way, we need track the how many we have that exceeds the required counts.
    normalized = []
    optionalCount = args.length - @minLength
    count = 0
    for item, i in @defaultVals
      if i == @length - 1 and @isVarArg
        if item == undefined
          normalized.push [ args[count++] ]
        else if optionalCount > 0
          normalized.push [ args[count++] ]
          optionalCount--
        else if _isFunction item
          normalized.push [ item() ]
        else
          normalized.push [ item ]
      else
        if item == undefined # this is required.
          normalized.push args[count++]
        else if optionalCount > 0
          normalized.push args[count++]
          optionalCount--
        else if _isFunction item
          normalized.push item()
        else
          normalized.push item
    normalized


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

# although it's nice to care about the default values, we don't really care
# about the prop names...
class ProcedureType extends Type
  constructor: (params, ret, options = {}) ->
    if not (@ instanceof ProcedureType)
      return new ProcedureType params, ret, options
    super noConvert: true
    id = 0
    for param, i in params
      if not (param instanceof Type)
        throw new Error("Procedure:param_#{i}_not_type: #{param}")
    if not (ret instanceof Type)
        throw new Error("Procedure:ret_not_type: #{ret}")
    if options.isVarArg
      if not (params[params.length - 1] instanceof ArrayType)
        throw new Error("Procedure:vararg_require_last_param_to_be_array")
    if options.defaultVals instanceof Array
      if not params.length == options.defaultVals.length
        throw new Error("Procedure.default_Vals_not_equal_param_length: #{params.length} != #{options.defaultVals.length}")
      for param, i in params
        if options.defaultVals[i] != undefined # when it's undefined it isn't passed in.
          defaultVal =
            if _isFunction options.defaultVals[i]
              options.defaultVals[i]()
            else
              options.defaultVals[i]
          if not param.isa defaultVal
            throw new Error("Procedure:default_val_#{i}_not_match_type_#{param}")
    defaultOptions =
      typeID: typeID++
      parameterTypes: params
      returnType: ret
      isVarArg: false
    _mixin @, _extend(defaultOptions, options)
  typeCategory: 'ProcedureType'
  isGeneric: () ->
    for param in @parameterTypes
      if param.isGeneric()
        return true
    @returnType.isGeneric()
  isComposite: () -> false
  isPrimitive: () -> false
  isTask: false
  resolve: (obj, resolver) ->
    if obj.__$t
      obj.__$t
    else
      throw new Error("procedure_type_doesnt_support_resolve")
  arity: () ->
    new Arity @parameterTypes.length, @isVarArg, @defaultVals
  normalize: (args) ->
    arity = @arity()
    arity.normalize args
  assertArguments: (args, context = @assertArguments) ->
    normalized = @normalize args
    error = convertError context
    for param, i in @parameterTypes
      param._assert normalized[i], error, "$/#{i}"
    if error.hasErrors()
      throw error
    else
      normalized
  assertResult: (res, context = @assertResult) ->
    @returnType.assert res, context
  convertArguments: (args) ->
    normalized = @normalize args
    errors = []
    result = []
    for param, i in @parameterTypes
      result.push param._convert(normalized[i], errors)
    if errors.length > 0
      e = new Error("invalid_arguments: #{errors}")
      e.errors = errors
      throw e
    else
      result
  isa: (obj) ->
    if obj.__$t == @
      true
    else
      false
  canAssignArgumentsFrom: (args, resolver = Type) ->
    @canAssignArgumentTypesFrom (resolver.resolve(arg) for arg in args)
  canAssignArgumentTypesFrom: (argTypes) ->
    if @parameterTypes.length != argTypes.length
      return false
    binder = new TypeBinder()
    for type, i in @parameterTypes
      if not binder.canAssignFrom type, argTypes[i]
        return false
    true
  canAssignFrom: (type) ->
    if type instanceof ProcedureType
      if @parameterTypes.length != type.parameterTypes.length
        return false
      binder = new TypeBinder()
      # contra-variance # we need our binder to allow that as well (and bind the returntype at the same time).
      for param, i in @parameterTypes
        if not binder.canAssignFrom type.parameterTypes[i], param
          return false
      binder.canAssignTo @returnType, type.returnType
    else
      false
  _toString: (env) ->
    params =
      for param in @parameterTypes
        param._toString env
    "(#{params.join(',')}) -> #{@returnType._toString(env)}"

# let's start to create some generic procedures for use.

makeProc = (argsTypes, retType, proc, options = {}) ->
  procType = ProcedureType argsTypes, retType, options
  _mixin proc,
    __$t: procType
    convert: (args...) ->
      converted = procType.convertArguments args
      res = proc converted...
      if procType.returnType.isa res
        return res
      else
        throw new Error("postcondition: #{res} is not of type #{procType.returnType}")
    check: (args...) ->
      asserted = procType.assertArguments args, proc
      procType.assertResult proc asserted...
  proc

class TraitType extends Type
  constructor: (options) ->
    if not (@ instanceof TraitType)
      return new TraitType options
    typeVars = ArrayType(AnyType())
    if not typeVars.isa options.types
      throw new Error("Trait.types must be an array of type variables")
    if not options.name
      throw new Error("Trait must be supplied with a name")
    if not (options.procedures instanceof Object) and Object.keys(options.procedures) > 0
      throw new Error("Trait must implement procedures")
    super()
    _mixin @,
      name: options.name
      types: options.types
      procedures: options.procedures
  isGeneric: () ->
    return typeVars.length > 0
  implement: (options) ->
    # when we are implementing - what are we doing?
    # we are providing a particular type's implementation
    # first thing we do is that we need to bind the list of the 
    binder = new TypeBinder @types
    

_mixin Type,
  createType: createType
  attachType: attachType
  convertError: convertError
  TypeEnv: TypeEnv
  makeProc: makeProc
  makeDispatcher: UnaryDispatcher
  makePrimitiveType: PrimitiveType
  makeAnyType: AnyType
  makeArrayType: ArrayType
  makePropertyType: PropertyType
  makeObjectType: ObjectType
  makeOneOfType: OneOfType
  makeProcedureType: ProcedureType
  makeTraitType: TraitType
  resolve: (obj) ->
    if obj == undefined
      UnitType
    else if obj == null
      NullType
    else if typeof(obj) == 'number'
      if Math.floor(obj) == obj
        IntegerType
      else
        FloatType
    else if obj.__$t instanceof Type
      obj.__$t
    else if obj.constructor.__$t instanceof Type
      obj.constructor.__$t.resolve(obj, Type)
    else
      throw new Error("unknown_type: #{obj}")

module.exports = Type




