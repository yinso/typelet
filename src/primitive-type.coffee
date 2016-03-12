Type = require './type'
util = require './util'
errLib = require './error'

####################
# PRIMITIVE TYPES
####################

class PrimitiveType extends Type
  constructor: (name, options = {}) ->
    if not (@ instanceof PrimitiveType)
      return new PrimitiveType name, options
    super()
    util._mixin @, util._extend({ name: name, typeID: Type.typeID++ }, options)
    if util._isFunction options.instanceof
      Type.attachType options.instanceof, @
  signature: () ->
    "1:#{@Type.typeID}"
  typeCategory: 'Primitive'
  isPrimitive: () -> false
  isComposite: () -> false
  isGeneric: () -> false
  isSubTypeOf: (type) -> false
  canAssignFrom: (type) -> type == @
  isa: (obj) -> typeof(obj) == @name.toLowerCase()
  equal: (type) -> type == @
  _toString: (env) -> @name


UnitType = PrimitiveType 'Unit',
  isa: (obj) -> obj == undefined

Type.baseEnv.define 'unit', UnitType

NullType = PrimitiveType 'Null',
  isa: (obj) -> obj == null

Type.baseEnv.define 'null', NullType

BooleanType = PrimitiveType 'Boolean',
  instanceof: Boolean

Type.baseEnv.define 'boolean', BooleanType

IntegerType = PrimitiveType 'Integer',
  isa: (obj) ->
    typeof(obj) == 'number' and Math.floor(obj) == obj

Type.baseEnv.define 'integer', IntegerType

FloatType = PrimitiveType 'Float',
  isa: (obj) ->
    typeof(obj) == 'number'
  instanceof: Number

Type.baseEnv.define 'float', FloatType

StringType = PrimitiveType 'String',
  instanceof: String

Type.baseEnv.define 'string', StringType

DateType = PrimitiveType 'Date',
  isa: (obj) ->
    obj instanceof Date
  instanceof: Date # this attaches the object constructor.

Type.baseEnv.define 'date', DateType

RegExpType = PrimitiveType 'RegExp',
  isa: (obj) ->
    obj instanceof RegExp
  instanceof: RegExp

Type.baseEnv.define 'regex', RegExpType

BooleanType.setConvert
  type: StringType
  converter: (s) ->
    if s == 'true'
      return true
    else if s == 'false'
      return false
    else
      throw new errLib.InvalidValueError BooleanType, s

IntegerType.setConvert
  type: StringType
  converter: (s) ->
    res = parseInt s
    if res.toString() == s
      return res
    else
      throw new errLib.InvalidValueError IntegerType, s

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
      throw new errLib.InvalidValueError FloatType, s

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
      throw new errLib.InvalidValueError(s, DateType)

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

util._mixin Type,
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

module.exports = PrimitiveType
