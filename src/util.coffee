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

module.exports =
  _extend: _extend
  _props: _props
  _mixin: _mixin
  _isFunction: _isFunction
  _class: _class
  _new: _new
  _inherits: _inherits

