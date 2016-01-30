Type = require './type'
util = require './util'

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
  makePrimitiveType: PrimitiveType
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

