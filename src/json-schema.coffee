# loads JSON schema and convert into a typespace for validation.

Type = require './type'
util = require './util'
TypeEnv = require './type-env'

class Builder
  constructor: () ->
    if not (@ instanceof Builder)
      return new Builder()
  build: (schema, env = new TypeEnv()) ->
    # in this case, the top level schema has a different meaning...
    # it must have definitions as an object so it can create the more complex structures.
    # 
    if schema.hasOwnProperty('definitions') and (schema.definitions instanceof Object)
      for key, item of schema.definitions
        env.define key, @buildOne(item, env, schema)
    else
      @buildOne schema, env, schema
    env
  buildOne: (schema, env, top) ->
    type =
      switch schema.type
        when 'integer'
          @_integer schema, env, top
        when 'number'
          @_float schema, env, top
        when 'string'
          @_string schema, env, top
        when 'boolean'
          @_boolean schema, env, top
        when 'null'
          @_null schema, env, top
        when 'array'
          @_array schema, env, top
        when 'object'
          @_object schema, env, top
        else
          if schema.type instanceof Array
            @buildOneOfTypes schema, env, top
          else if schema.$ref
            @_ref schema, env, top
          else if schema.oneOf
            @buildOneOf schema, env, top
          else
            throw new Error("Compiler:unknown_type: #{schema.type}")
    if schema.default
      Type.PropertyType null, type, schema.default
    else
      type
  _integer: (schema, env, top) ->
    Type.Integer
  _float: (schema, env, top) ->
    Type.Float
  _boolean: (schema, env, top) ->
    Type.Boolean
  _null: (schema, env, top) ->
    Type.Null
  _string: (schema, env, top) ->
    Type.String
  buildOneOfTypes: (schema, env, top) ->
    types =
      for type in schema.type
        @buildOne { type: type }, env, top
    Type.OneOfType types
  buildOneOf: (schema, env, top) ->
    types =
      for type in schema.oneOf or []
        @buildOne type, env, top
    Type.OneOfType types
  _array: (schema, env, top) ->
    itemType = @buildOne schema.items, env, top
    Type.ArrayType itemType
  _object: (schema, env, top) ->
    props =
      for key, inner of (schema.properties or {})
        Type.PropertyType key, @buildOne(inner, env, top)
    Type.ObjectType props
  _ref: (schema, env, top) ->
    # for now, assume the refs just follow the following #/definitions/<name> pattern.
    name = @_parseRef schema.$ref
    env.get name
  _parseRef: (ref) ->
    parsed = ref.split '/'
    parsed[parsed.length - 1]

util._mixin Type,
  JsonSchema: Builder()

module.exports = Builder


