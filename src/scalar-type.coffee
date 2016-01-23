Type = require './type'

class ScalarType extends Type
  constructor: (options) ->
    if not options.isa and (options.typeof and options.instanceof)
      options.isa = (x) ->
        (typeof(x) == options.typeof) or (x instanceof options.instanceof)
    @name = options.name or @typeID
    super options
  signature: () ->
    "#{@name}$#{@typeID}"
  equal: (type) ->
    @ == type
  inspect: () ->
    @toString()
  toString: () ->
    "#{@name}"

# can convert from string and integer - we need to deal with a conversion framework...
# so each type has a hashtable that holds a list of 

ScalarType.String = StringType = new ScalarType
  name: 'string'
  typeof: 'string'
  instanceof: String

ScalarType.Unit = UnitType = new ScalarType
  name: 'unit'
  isa: (x) -> x == undefined
  converters: [
    [
      StringType
      (x) ->
        if x == 'undefined'
          return undefined
        else
          throw new Error("unable_to_convert: #{x}")
    ]
  ]

ScalarType.Null = NullType = new ScalarType
  name: 'null'
  isa: (x) -> x == null
  converters: [
    [
      StringType
      (x) ->
        if x == 'null'
          return null
        else
          throw new Error("unable_to_convert: #{x}")
    ]
  ]

ScalarType.Float = FloatType = new ScalarType
  name: 'float'
  typeof: 'number'
  instanceof: Number
  converters: [
    [
      new ScalarType {
        base: StringType
        constraint:
          check: (x) ->
            x.match /^[+|-]?\d+(\.\d+)?([e|E]\d+)?$/
      }
      parseFloat
    ]
  ]

ScalarType.Integer = IntegerType = new ScalarType
  base: FloatType
  name: 'integer'
  typeof: 'number'
  instanceof: Number
  constraint:
    check: (x) ->
      Math.floor(x) == x
  converters: [
    [
      new ScalarType {
        base: StringType
        constraint: 
          check: (x) ->
            x.match /^[+|-]?\d+$/
      }
      parseInt
    ]
  ]

ScalarType.Boolean = BooleanType = new ScalarType
  name: 'bool'
  typeof: 'boolean'
  instanceof: Boolean
  converters: [
    [
      StringType
      (x) ->
        if x == 'true'
          return true
        else if x == 'false'
          return false
        else
          throw new Error("invalid_boolean_value: #{x}")
    ]
    [
      IntegerType
      (x) ->
        if x == 0
          return false
        else
          return true
    ]
  ]


ScalarType.Date = DateType = new ScalarType
  name: 'date'
  isa: (x) -> x instanceof Date
  converters: [ 
    [
      StringType
      (x) -> new Date x
    ]
    [
      IntegerType
      (x) -> new Date x
    ]
  ]

addConverters = (type, converters) ->
  for [ isa , converter ] in converters or []
    type.addConverter isa , converter

addConverters StringType, [
  [
    UnitType
    (x) -> 'undefined'
  ]
  [
    NullType
    (x) -> 'null'
  ]
  [
    BooleanType
    (x) ->
      if x == 'true'
        'true'
      else
        'false'
  ]
  [
    IntegerType
    (x) ->
      x.toString()
  ]
  [
    FloatType
    (x) -> x.toString()
  ]
  [
    DateType
    (x) -> x.toISOString()
  ]
]

module.exports = ScalarType

