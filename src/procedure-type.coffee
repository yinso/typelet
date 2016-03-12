util = require './util'
errLib = require './error'
Type = require './type'
TypeBinder = require './type-binder'

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
        else if util._isFunction item
          normalized.push [ item() ]
        else
          normalized.push [ item ]
      else
        if item == undefined # this is required.
          normalized.push args[count++]
        else if optionalCount > 0
          normalized.push args[count++]
          optionalCount--
        else if util._isFunction item
          normalized.push item()
        else
          normalized.push item
    normalized


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
            if util._isFunction options.defaultVals[i]
              options.defaultVals[i]()
            else
              options.defaultVals[i]
          if not param.isa defaultVal
            throw new Error("Procedure:default_val_#{i}_not_match_type_#{param}")
    defaultOptions =
      typeID: Type.typeID++
      parameterTypes: params
      returnType: ret
      isVarArg: false
    util._mixin @, util._extend(defaultOptions, options)
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
    error = Type.convertError context
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
  equal: (type) ->
    if type instanceof ProcedureType
      if @parameterTypes.length != type.parameterTypes.length
        return false
      for param, i in @parameterTypes
        if not param.equal(type.parameterTypes[i])
          return false
      return @returnType.equal(type.returnType)
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
  util._mixin proc,
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

util._mixin Type,
  makeProc: makeProc

Type.baseEnv.define 'procedure', ProcedureType

module.exports = ProcedureType
