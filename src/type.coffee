class IType
  # uniquely determining a type.
  typeID: () ->
  # used for hashing a type object. this provides an *equal* comparison for types.
  signature: () ->
  # for determining whether this is is a composite type.
  isGeneric: () -> # is this a generic type.
  # for determining whether this is a composite type. useful for resolve.
  isComposite: () ->
  # for resolving complex data type.
  resolve: (obj, resolver) ->
  # determine whether <this> is a sub type of type
  isSubTypeOf: (type) ->
  # used for determining assignment relationship.
  isAssignableFrom: (type) ->
  # determine whether obj is a type of <this>.
  isa: (obj) ->
  # convert throws an error.
  convert: (obj) ->
  # the same as another type (signature can aid in this comparison).
  equal: (type) ->



class Type
  @typeID: 0
  constructor: (@options = {}) ->
    @typeID = Type.typeID++
    @_setupBaseType @options.base
    @_isa = if @options.isa then @options.isa else (x) -> true
    @converters = []
    for [ type , convert ] in @options.converters or []
      @addConverter type, convert
  _setupBaseType: (type) ->
    if @options.base instanceof Type
      @baseType = @options.base
  _setupConstraint: (constraint) ->
    if @options.constraint
      @_constraint = @options.constraint
  addConverter: (type, converter) ->
    if type instanceof Type and (typeof(converter) == 'function' or (converter instanceof Function))
      @converters.push [ type , converter ]
    else
      throw new Error("invalid_converter: #{type}, #{converter}")
  # check whether a value is a member of the particular type.
  isa: (x) ->
    @_baseIsa(x) and @_isa(x) and @_constraintIsa(x)
  signature: () -> # returns the signature of the type... we want this to be calculatable?
    "@typeID"
  # for resolving compound types.
  outerIsa: (x) ->
    @isa x
  resolveType: (x, typeSpace) ->
    @
  _baseIsa: (x) ->
    if @baseType
      @baseType.isa x
    else
      true
  _constraintIsa: (x) ->
    if @_constraint
      @_constraint.check x
    else
      true
  # validation / conversion related functions.
  # strictly speaking, validation occurs when conversion is successful.
  convert: (x) ->
    for [ type , converter ] in @converters
      if type.isa x
        try
          return converter x
        catch e
          continue
    throw new Error("no_matching_converter_type (out of #{@converters.length}): #{x}")
  validate: (x) ->
    try
      @convert x
      true
    catch e
      false
  # generic related functions
  isGeneric: () -> false
  specialize: (args...) ->
    if not @isGeneric()
      throw new Error("type_cannot_specialize:not_generic")
    @_specialize(args...)
  # type comparison.
  equal: (type) -> false
  greater: (type) -> true # for type sorting.
  # contains means that this type is a more generic type than the parameter type.
  contains: (type) ->
    @equal(type) or type.inherits(@)
  inherits: (type) -> # type is part of the base hierarchy (base, or base's base, etc)
    if @baseType
      @baseType == type or @baseType.inherits(type)
    else
      false
  substituable: (type) -> # the right hand side must be matches the needs of the left hand side.
    @equal type

module.exports = Type


