# loads JSON schema and convert into a typespace for validation.

Type = require './type'
util = require './util'
TypeEnv = require './type-env'

# all type can have a definition for inside the document... we will support that later.

class Schema
  constructor: (schema = {}) ->
    if not (@ instanceof Schema)
      return new Schema schema
    @env = new TypeEnv()
    @load schema
  load: (schema) ->
    # the top level is going to be treated as a collection of objects.
    @top = schema
    for key, item of schema.definitions or {}
      @define key, item
  define: (name, schema) ->
    @env.define name, @buildOne schema
  has: (name) ->
    @env.has name
  get: (name) ->
    @env.get name
  buildOne: (schema) ->
    type =
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
            @_typeOneOf schema
          else if schema.$ref
            @_ref schema
          else if schema.oneOf
            @_oneOf schema
          else
            throw new Error("Compiler:unknown_type: #{schema.type}")
    if schema.default
      Type.baseEnv.get('property') null, type, schema.default
    else
      type
  _integer: (schema) ->
    Type.baseEnv.get('integer')
  _float: (schema) ->
    Type.baseEnv.get('float')
  _boolean: (schema) ->
    Type.baseEnv.get('boolean')
  _null: (schema) ->
    Type.baseEnv.get('null')
  _string: (schema) ->
    Type.baseEnv.get('string')
  _typeOneOf: (schema) ->
    types =
      for type in schema.type
        @buildOne { type: type }
    Type.baseEnv.get('oneOf') types
  _oneOf: (schema) ->
    types =
      for type in schema.oneOf or []
        @buildOne type
    Type.baseEnv.get('oneOf') types
  _array: (schema) ->
    itemType = @buildOne schema.items
    Type.baseEnv.get('array') itemType
  _object: (schema) ->
    props =
      for key, inner of (schema.properties or {})
        Type.baseEnv.get('property') key, @buildOne(inner)
    Type.baseEnv.get('object') props
  _array: (schema) ->
    itemType = @buildOne schema.items
    Type.baseEnv.get('array') itemType
  _object: (schema) ->
    props =
      for key, inner of (schema.properties or {})
        Type.baseEnv.get('property') key, @buildOne(inner)
    Type.baseEnv.get('object') props
  _ref: (schema) ->
    # for now, assume the refs just follow the following #/definitions/<name> pattern.
    name = @_parseRef schema.$ref
    @env.get name
  _parseRef: (ref) ->
    # we will only support
    parsed = ref.split '/'
    parsed[parsed.length - 1]

util._mixin Type,
  Schema: Schema

module.exports = Schema
