# loads JSON schema and convert into a typespace for validation.

Type = require './type'
util = require './util'

class Builder
  constructor: () ->
    if not (@ instanceof Builder)
      return new Builder()
  build: (schema) ->
    switch schema.type
      when 'integer'
        @_integer schema
      when 'number'
        @_float schema
      when 'string'
        @_string schema
      when 'boolean'
        @_boolean schema
      when 'null'
        @_null schema
      when 'array'
        @_array schema
      when 'object'
        @_object schema
      else
        if schema.type instanceof Array
          @_oneOfTypes schema
        else if schema.oneOf
          @_oneOf schema
        else
          throw new Error("Compiler:unknown_type: #{schema.type}")
  _integer: (schema) ->
    Type.Integer
  _float: (schema) ->
    Type.Float
  _boolean: (schema) ->
    Type.Boolean
  _null: (schema) ->
    Type.Null
  _string: (schema) ->
    Type.String
  _oneOfTypes: (schema) ->
    types =
      for type in schema.type
        @build type: type
    Type.OneOfType types
  _oneOf: (schema) ->
    types =
      for type in schema.oneOf or []
        @build type
    Type.OneOfType types
  _array: (schema) ->
    itemType = @build schema.items
    Type.ArrayType itemType
  _object: (schema) ->
    props =
      for key, inner of (schema.properties or {})
        Type.PropertyType key, @build inner
    Type.ObjectType props

util._mixin Type,
  JsonSchema: Builder()

module.exports = Builder


