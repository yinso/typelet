util = require './util'
errLib = require './error'
TypeEnv = require './type-env'
UnaryDispatcher = require './type-dispatcher'
AST = require 'astlet'

class TypeEnvironment extends AST.Environment

convertError = (context = convertError) ->
  new errLib.ConvertError context

class Type
  @typeID: 0
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
      throw new errLib.NotTypeOfError @, obj, context
    obj
  _assert: (obj, err, path = '$', context = @_assert) ->
    if not @isa obj
      err.push path, new errLib.NotTypeOfError @, obj, context
    else
      obj
  outerIsa: (obj) ->
    @isa obj
  # convert throws an error.
  convert: (obj, options = {}) ->
    { path , isExplicit , context } = util._extend options,
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
      error.push path, new errLib.ConversionNotSupportedError(@)
    try
      type = Type.resolve obj
      converter = @_converter.get [ type ]
      if not converter
        error.push path, new errLib.CannotConvertError(@, obj)
      else if converter.isExplicit and not isExplicit
        error.push path, new errLib.CannotImplicitConvertError(@, obj)
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
    if not util._isFunction(converter)
      throw new Error("Type.setConvert:no_converter_specified")
    @_converter.set [ type ] , { converter: converter , isExplicit: explicit }
  equal: (type) ->
  inspect: () -> @toString()
  toString: () ->
    @_toString new TypeEnv()
  _toString: (envs) ->
    '<IType>'

createType = (ctor, options) ->
  if not util._isFunction ctor
    throw new Error("invalid_constructor: #{ctor}")
  if not (ctor.prototype instanceof Type)
    util._class
      constructor: ctor
      __super__: Type
  util._new ctor, options

attachType = (ctor, type) ->
  Object.defineProperty ctor, '__$t',
    value: type
    enumerable: false
    writable: false
    configurable: false

util._mixin Type,
  createType: createType
  attachType: attachType
  convertError: convertError
  TypeEnv: TypeEnv
  baseEnv: new TypeEnvironment()
  makeDispatcher: UnaryDispatcher

module.exports = Type
