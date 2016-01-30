util = require './util'

####################
# ERROR
####################

CannotConvertError = util._class
  __super__: Error
  constructor: (@type, @value, context = CannotConvertError) ->
    @name = 'CannotConvert'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

CannotImplicitConvertError = util._class
  __super__: Error
  constructor: (@type, @value, context = CannotImplicitConvertError) ->
    @name = 'CannotImplicitConvert'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

InvalidValueError = util._class
  __super__: Error
  constructor: (@type, @value, context = InvalidValueError) ->
    @name = 'InvalidValue'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

NotTypeOfError = util._class
  __super__: Error
  constructor: (@type, @value, context = InvalidValueError) ->
    @name = 'NotTypeOf'
    @message = "{type: #{@type}, value: #{@value}}"
    Error.captureStackTrace @, context

ConversionNotSupportedError = util._class
  __super__: Error
  constructor: (@type, context = ConversionNotSupportedError) ->
    @name = 'ConversionNotSupported'
    @message = "for #{@type}"
    Error.captureStackTrace @, context

ConvertError = util._class
  __super__: Error
  constructor: (context = ConvertError) ->
    @name = 'ConvertError'
    @errors = {}
    Error.captureStackTrace @, context
  append: (err) ->
    if err instanceof ConvertError
      for key, val of err.errors
        if err.errors.hasOwnProperty(key)
          @push key, val
  push: (path, error) ->
    @errors[path] = error
    @message = @formatMessage()
    return
  hasErrors: () ->
    Object.keys(@errors).length > 0
  formatMessage: () ->
    errors =
      for key, error of @errors
        "#{key}: #{error}"
    errors.join(";")

module.exports =
  ConvertError: ConvertError
  ConversionNotSupportedError: ConversionNotSupportedError
  NotTypeOfError: NotTypeOfError
  InvalidValueError: InvalidValueError
  CannotImplicitConvertError: CannotImplicitConvertError
  CannotConvertError: CannotConvertError

